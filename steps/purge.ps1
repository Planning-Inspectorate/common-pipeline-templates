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

$repos=@("crown/manage", "crown/portal")
$resourceGroupsBySub=@{
    "dev" = @("pins-rg-crown-dev");
    "test" = @("pins-rg-crown-test");
    "training" = @("pins-rg-crown-training");
}
$acrSubId="edb1ff78-90da-4901-a497-7e79f966f8e2"
$appSubsByName=@{
    "dev" = "962e477c-0f3b-4372-97fc-a198a58e259e";
    "test" = "76cf28c6-6fda-42f1-bcd9-6d7dbed704ef";
    "training" = "dbfbfbbf-eb6f-457b-9c0c-fe3a071975bc";
    "prod" = "d1d6c393-2fe3-40af-ac27-f5b6bad36735";
}

Write-Host "Configuration"
Write-Host "--------------------------------------"

$subsStr = $appSubsByName | Out-String
Write-Host "Subscriptions:" $subsStr
$rgsStr = $resourceGroupsBySub | Out-String
Write-Host "Resource Groups:" $rgsStr
$reposStr = $repos | Out-String
Write-Host "Repositories:"
Write-Host $reposStr

Write-Host "--------------------------------------"

$inUseImages=@()

foreach ($sub in $appSubsByName.GetEnumerator()) {
    Write-Host "sub" $sub.Name
    $subId = $sub.Value
    Invoke-Command -ScriptBlock {
        az account set --subscription $subId
    }
    if ($? -eq $false) {
        Write-Error "Error setting subscription"
        Exit -1
    }

    $resourceGroups = $resourceGroupsBySub[$sub.Name]

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
            $imageName = GetImageName -AppName $app -ResourceGroup $rg -Slot "staging"
            $inUseImages+=$imageName
        }
    }
}

# group in-use image tags by repository
$tagsByRepo=@{}

foreach ($repo in $repos) {
    $tagsByRepo[$repo]=@() # initialise an array per repo
}

foreach ($image in $inUseImages) {
    $repo = GetImageRepo -image $image
    $hash = GetImageTag -image $image
    if ($tagsByRepo[$repo] -contains $hash) {
        continue
    }
    $tagsByRepo[$repo] += $hash
}

Write-Host "Images in use by repo: "
$tagsByRepo | Out-String | Write-Host

Write-Host "Switching to ACR sub"

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
    $manifests=Invoke-Command -ScriptBlock {
        az acr manifest list-metadata --registry "pinscrsharedtoolinguks" --name "$repo" --output json
    }
    $manifests = manifests | ConvertFrom-Json

    $inUseTags = $tagsByRepo[$repo]

    foreach ($manifest in $manifests) {
        $digest = $manifest.digest
        $tags = $manifest.tags
        foreach ($tag in $tags) {
            if ($inUseTags -contains $tag) {
                $inUseDigests[$repo] += $digest
            } else {
                $notInUseDigests[$repo] += $digest
            }
        }
    }
}

Write-Host "Digests to keep:"
$inUseDigests | Out-String | Write-Host

Write-Host "Digests to delete:"
$notInUseDigests | Out-String | Write-Host

