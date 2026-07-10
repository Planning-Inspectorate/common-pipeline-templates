# Pipelines

This folder contains templates which can be used standalone as a pipeline, and each one implements some specific functionality.

## cd_app_deployment_zip

This pipeline implements Azure App Service deployment from a zip file.

## terraform_checks

This pipeline is for validating Terraform infrastructure-as-code. It will run:

- Branch name check
- Terraform format
- Terraform validate
- tflint
- checkov

To use this pipeline, create a pipeline in your project such as:

```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - infrastructure

pr:
  branches:
    include:
      - '*'
  paths:
    include:
      - infrastructure

resources:
  repositories:
    - repository: templates
      type: github
      endpoint: Planning-Inspectorate
      name: Planning-Inspectorate/common-pipeline-templates
      ref: refs/tags/release/3.27.0

extends:
  template: pipelines/terraform_checks.yml@templates
  parameters:
    workingDirectory: $(Build.Repository.LocalPath)/infrastructure
    tflintConfigPath: $(Build.Repository.LocalPath)/infrastructure/.tflint.hcl
```

Configuration options:

| Parameter        | Type   | Default                          | Description                        |
|------------------|--------|----------------------------------|------------------------------------|
| pool             | object | pins-odt-agent-pool              | The DevOps agent pool to use       |
| workingDirectory | string | `System.DefaultWorkingDirectory` | The working directory to use       |
| tflintConfigPath | string | N/A                              | The path to the `.tflint.hcl` file |
| gitFetchDepth    | number | 1                                | Configure the git fetch depth      |

## terraform_plan_apply

This pipeline is for deploying Terraform infrastructure-as-code. For each environment configured it will run separate plan and apply stages. It makes some assumptions about the Terraform code, such as that there is a folder with `.tfvars` files in for each environment.

To use this pipeline, create a pipeline in your project such as:

```yaml
trigger: none

pr: none

resources:
  pipelines:
    - pipeline: terraform-ci
      source: Infrastructure PR
      trigger:
        branches:
          include:
            - main
  repositories:
    - repository: templates
      type: github
      endpoint: Planning-Inspectorate
      name: Planning-Inspectorate/common-pipeline-templates
      ref: refs/tags/release/3.24.2

extends:
  template: pipelines/terraform_plan_apply.yml@templates
  parameters:
    serviceConnectionPrefix: Azure DevOps Pipelines - Inspector Programming - Infrastructure
    storageAccountName: pinssttfstateuksscheduli
    resourceGroupName: pins-rg-shared-terraform-uks
    containerPrefix: terraform-state-scheduling-
    workingDirectory: $(Build.Repository.LocalPath)/infrastructure
    environmentVarFilePath: $(Build.Repository.LocalPath)/infrastructure/environments
```

Configuration options:

| Parameter                           | Type     | Default                             | Description                                                                                                                                                                                                                                            |
|-------------------------------------|----------|-------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| automaticDeploymentEnvironments     | object   | `Dev`                               | Environments deployed automatically, e.g. on merge to main                                                                                                                                                                                             |
| environments                        | object   | `Dev` → `Test` → `Prod`             | Full list of environments and their `dependsOn` chain, used to generate the pipeline stages                                                                                                                                                            |
| poolNameFormatString                | string   | `pins-odt-agent-pool`               | Agent pool name, `{0}` is replaced with the environment name, allowing per-environment pools.                                                                                                                                                          |
| workingDirectory                    | string   | `$(System.DefaultWorkingDirectory)` | Directory containing the Terraform code.                                                                                                                                                                                                               |
| serviceConnectionPrefix             | string   | N/A                                 | Prefix for the Azure Service Connection name; the environment name is appended (e.g. `"<prefix> Dev"`). Only this or `serviceConnectionCustomFormatString` should be set. `serviceConnectionCustomFormatString` takes precedence.                      |
| serviceConnectionCustomFormatString | string   | N/A                                 | Custom format string for the Service Connection name; `{0}` is replaced with the environment name. Only this or `serviceConnectionPrefix` should be set. This takes precedence.                                                                        |
| storageAccountName                  | string   | N/A (required)                      | Azure Storage account holding the Terraform remote state.                                                                                                                                                                                              |
| resourceGroupName                   | string   | N/A (required)                      | Resource group of the state storage account.                                                                                                                                                                                                           |
| containerPrefix                     | string   | N/A                                 | Prefix for the state container name; the lowercased environment name is appended. Only this or `containerFormatString` should be set. `containerFormatString` takes precedence.                                                                        |
| containerFormatString               | string   | N/A                                 | Format string for the state container name; `{0}` is replaced with the environment name. Only this or `containerPrefix` should be set. This takes precedence.                                                                                          |
| planFileName                        | string   | `main.tfplan`                       | Filename used for the generated Terraform plan.                                                                                                                                                                                                        |
| environmentVarFilePath              | string   | N/A                                 | Path to a folder containing `<env>.tfvars` files. When set, `-var-file=<path>/<env>.tfvars` is passed to `terraform plan`.                                                                                                                             |
| extraVariables                      | object   | `[]`                                | Additional pipeline variables merged into the pipeline `variables` block.                                                                                                                                                                              |
| extraEnvironmentVariables           | object   | `[]`                                | Extra environment variables (list of `{ name, value }`) exposed to the Terraform tasks.                                                                                                                                                                |
| planStageExtraEnvironmentVariables  | object   | `[]`                                | Extra environment variables (list of `{ name, value }`) exposed to Terraform plan. Here you can pass `TF_VAR_<name>` variables, see [Environment variables](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables) |
| preliminarySteps                    | stepList | `[]`                                | Steps to run before the Terraform tasks in both the plan job and the apply deployment (e.g. downloading a secret file).                                                                                                                                |
| postApplySteps                      | stepList | `[]`                                | Steps to run after Terraform apply                                                                                                                                                                                                                     |
| planStageVariableGroupFormatString  | string   | `''`                                | Format string for a variable group linked to the plan stage; `{0}` is replaced with the environment name. When empty, no variable group is linked.                                                                                                     |

