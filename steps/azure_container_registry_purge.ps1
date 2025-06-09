# get image name from webapp config
function GetImageName {
    param (
        $AppName,
        $ResourceGroup,
        $Slot
    )

    if ($null -eq $Slot) {
        $containerConfig = Invoke-Command -ScriptBlock {
            az webapp config container show --name $AppName --resource-group $ResourceGroup
        }
    } else {
        $containerConfig = Invoke-Command -ScriptBlock {
            az webapp config container show --name $AppName --resource-group $ResourceGroup --slot $Slot
        }
    }

    $containerConfig=$containerConfig | ConvertFrom-Json
    $imageName=""
    foreach ($config in $containerConfig) {
        if ($config.name -eq "DOCKER_CUSTOM_IMAGE_NAME") {
            $imageName=$config.value
            break
        }
    }
    if ($imageName -eq "") {
        Write-Host "no image name found for " $app.Name $app.Value
        Exit -1
    }
    Write-Output $imageName.Split("|")[1]
}

# get repo out of a string in the form:
# <domain>/<repo>:<tag>
function GetImageRepo {
    param (
        [string]$image
    )
    $i = $image.IndexOf("/")
    $imageWithTag = $image.Substring($i + 1)
    return $imageWithTag.Split(":")[0]
}

# get tag out of a string in the form:
# <domain>/<repo>:<tag>
function GetImageTag {
    param (
        [string]$image
    )
    $i = $image.IndexOf("/")
    $imageWithTag = $image.Substring($i + 1)
    return $imageWithTag.Split(":")[1]
}

# pull in configuration from environment
$dryRun=$env:DRY_RUN
$hasStagingSlots=$env:HAS_STAGING_SLOTS
$keepDays=[int]::Parse($env:KEEP_LAST_X_DAYS)
$keepFromDate=(Get-Date).AddDays(-$keepDays)
$repos= $env:REPOSITORIES | ConvertFrom-Json
$resourceGroupsBySubRaw= $env:RESOURCE_GROUP_BY_SUB | ConvertFrom-Json
$resourceGroupsBySub=@{
    "dev" = $resourceGroupsBySubRaw.dev;
    "test" = $resourceGroupsBySubRaw.test;
    "training" = $resourceGroupsBySubRaw.training;
    "prod" = $resourceGroupsBySubRaw.prod;
}

$acrSubId="edb1ff78-90da-4901-a497-7e79f966f8e2"
$appSubsByName=@{
    "dev" = "962e477c-0f3b-4372-97fc-a198a58e259e";
    "test" = "76cf28c6-6fda-42f1-bcd9-6d7dbed704ef";
    "training" = "dbfbfbbf-eb6f-457b-9c0c-fe3a071975bc";
    "prod" = "d1d6c393-2fe3-40af-ac27-f5b6bad36735";
}

Write-Host "##[group]Configuration"

Write-Host "Dry run" $dryRun
Write-Host "Has staging slots" $hasStagingSlots
Write-Host "Keep images from" $keepFromDate.ToString("yyyy/MM/dd HH:mm")
$subsStr = $appSubsByName | Out-String
Write-Host "Subscriptions:" $subsStr
$rgsStr = $resourceGroupsBySub | Out-String
Write-Host "Resource Groups:" $rgsStr
$reposStr = $repos | Out-String
Write-Host "Repositories:"
Write-Host $reposStr

Write-Host "##[endgroup]"

$inUseImages=@()
$inUseImageAppNames=@{}

foreach ($sub in $appSubsByName.GetEnumerator()) {
    Write-Host "##[group] Subscription" $sub.Name
    $subId = $sub.Value
    Invoke-Command -ScriptBlock {
        az account set --subscription $subId
    }
    if ($? -eq $false) {
        Write-Error "Error setting subscription"
        Exit -1
    }

    $resourceGroups = $resourceGroupsBySub[$sub.Name]
    Write-Host "Resource groups in subscription" $resourceGroups

    foreach ($rg in $resourceGroups) {
        Write-Host "fetch apps in " $rg
        $apps=Invoke-Command -ScriptBlock {
            az webapp list --query "[].{name: name}" -o tsv --resource-group $rg
        }
        if ($null -eq $apps) {
            continue
        }
        $apps=$apps.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)
        foreach ($app in $apps) {
            Write-Host "get image config for:" $app "(" $rg ")"
            $imageName = GetImageName -AppName $app -ResourceGroup $rg
            $inUseImages+=$imageName

            if ($inUseImageAppNames[$imageName] -isnot [array]) {
                $inUseImageAppNames[$imageName]=@() # initialise an array for this image name
            }
            $inUseImageAppNames[$imageName] += $app

            if ($hasStagingSlots -eq $true) {
                $imageName = GetImageName -AppName $app -ResourceGroup $rg -Slot "staging"
                $inUseImages+=$imageName

                if ($inUseImageAppNames[$imageName] -isnot [array]) {
                    $inUseImageAppNames[$imageName]=@() # initialise an array for this image name
                }
                $inUseImageAppNames[$imageName] += $app + "(staging)"
            }
        }
    }
    Write-Host "##[endgroup]"
}

# group in-use image tags by repository
$tagsByRepo=@{}
# list of apps using each tag
$appsByRepoByTag=@{}

foreach ($repo in $repos) {
    $tagsByRepo[$repo]=@() # initialise an array per repo
    $appsByRepoByTag[$repo]=@{} # initialise a hash table per repo
}

foreach ($image in $inUseImages) {
    $repo = GetImageRepo -image $image
    $hash = GetImageTag -image $image
    if ($tagsByRepo[$repo] -contains $hash) {
        continue
    }
    $tagsByRepo[$repo] += $hash
    $appsByRepoByTag[$repo][$hash] = $inUseImageAppNames[$image]
}

Write-Host "##[debug]switching to ACR sub"

Invoke-Command -ScriptBlock {
    az account set --subscription $acrSubId
}
if ($? -eq $false) {
    Write-Error "Error setting subscription"
    Exit -1
}

Invoke-Command -ScriptBlock {
    az acr login --name "pinscrsharedtoolinguks"
}

# keyed by repo name
$inUseDigests=@{}
$notInUseDigests=@{}
foreach ($repo in $repos) {
    # initialise an array per repo
    $inUseDigests[$repo]=@()
    $notInUseDigests[$repo]=@()
}

# fetch manifests for each repo
foreach ($repo in $repos) {
    Write-Host "##[group]" $repo "checking images by digest"
    $manifests=Invoke-Command -ScriptBlock {
        az acr manifest list-metadata --registry "pinscrsharedtoolinguks" --name "$repo" --output json
    }
    $manifests = $manifests | ConvertFrom-Json

    $inUseTags = $tagsByRepo[$repo]
    $appsByTag = $appsByRepoByTag[$repo]

    foreach ($manifest in $manifests) {
        $digest = $manifest.digest
        $tags = $manifest.tags
        $keep = $false

        # check if any of the tags for this image are in use
        foreach ($tag in $tags) {
            if ($inUseTags -contains $tag) {
                $appsUsingDigest = $appsByTag[$tag]  | Join-String -Separator ','
                Write-Host "Keep" $digest "for" $repo "in use by" $appsUsingDigest "with tag" $tag
                $keep = $true
                break;
            }
        }
        if ($keep -ne $true) {
            # if last modified 'recently' (compared to keepFromDate) then keep the image
            $lastModified = [datetime]::ParseExact($manifest.lastUpdateTime, "MM/dd/yyyy HH:mm:ss", $null)
            if ($lastModified -gt $keepFromDate) {
                Write-Host "Keep" $digest "for" $repo "last modified" $lastModified.ToString("yyyy/MM/dd HH:mm")
                $keep=$true
            }
        }

        if ($keep -eq $true) {
            $inUseDigests[$repo] += $digest
        } else {
            $notInUseDigests[$repo] += $digest
        }
    }
    Write-Host "##[endgroup]"
}

foreach ($repo in $repos) {
    $inUse = $inUseDigests[$repo] | Out-String
    $notInUse = $notInUseDigests[$repo] | Out-String
    Write-Host "##[group]" $repo "to delete"
    Write-Host $repo
    Write-Host $notInUse
    Write-Host "##[endgroup]"
    Write-Host "##[group]" $repo "to keep"
    Write-Host $repo
    Write-Host $inUse
    Write-Host "##[endgroup]"
}

$deleted = 0

if ($dryRun -eq $true) {
    Write-Host "##[command]Dry run, not deleting images"
} else {
    Write-Host "##[group] Deleting images"
    foreach ($repo in $repos) {
        $digests = $notInUseDigests[$repo]
        foreach ($digest in $digests) {
            Write-Host "Deleting digest" $digest "for" $repo
            Invoke-Command -ScriptBlock {
                az acr repository delete --name "pinscrsharedtoolinguks" --image "$repo@$digest" --yes
            }
            $deleted++;
        }
    }
    Write-Host "##[endgroup]"
}

Write-Host "##[command]********************************"
Write-Host "##[command]Purge complete"
Write-Host "##[command]Deleted " $deleted " images"
Write-Host "##[command]********************************"

