# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [3.1.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/3.1.0...release/3.1.1) (2022-07-08)


### Bug Fixes

* re-enable git tagging on main branch ([a494870](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/a4948704a218a5e8d8c0d3c3fe6e3f0814ec69fd))

## [3.1.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/3.0.3...release/3.1.0) (2022-06-30)


### Features

* **jobs/wrapper_deployment.yml:** download artifacts from current pipeline ([9b1048b](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/9b1048bf905e1542bb06e0dbbb44b471439724fb))
* **steps/terraform_plan.yml:** include templatefiles in artifact ([cde7396](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/cde7396689380f391e42f2c421c7c1b8d9ce1351))

### [3.0.3](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/3.0.2...release/3.0.3) (2022-06-27)


### Bug Fixes

* **artifacts:** fix artifact download in cd pipelines ([476251f](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/476251ff1a021ad7fedce7cf73245efbe304dc49))

### [3.0.2](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/3.0.1...release/3.0.2) (2022-06-24)


### Bug Fixes

* **steps/azure_web_app_deploy.yml:** stop logging web app cd info ([a8e2e27](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/a8e2e27cafab4853674db8e3a438457c5f54571c))

### [3.0.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/3.0.0...release/3.0.1) (2022-06-23)


### Bug Fixes

* **stages/wrapper_cd.yml:** add job conditions ([cd6016b](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/cd6016b09bb848c6366f2fb6e49d449ffcd78630))

## [3.0.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.5.5...release/3.0.0) (2022-06-23)


### ⚠ BREAKING CHANGES

* **wrappers:** Structure of the deploymentStages parameter now requires a deploymentJobs key.

### Features

* **steps/publish_test_results.yml:** move publish test results to stand alone step ([9d93f14](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/9d93f14848c597b39e4096c474cb3474e1581bfc))
* **web app deployment steps:** update web app deploy steps to accept standalone tags ([b85bda9](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/b85bda905acd2f7e0db07575f1a7454dce2d43a4))
* **wrappers:** update wrappers to accept different structured of parameters ([3bddfcf](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/3bddfcf50883896bb60c97eeadc043b669038ec6))

### [2.5.5](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.5.4...release/2.5.5) (2022-06-14)


### Bug Fixes

* **templates): fix(templates:** fix typo and remove isOutput flag ([2b32ed9](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/2b32ed935f983a03df270e804dd70142a760664f))

### [2.5.4](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.5.3...release/2.5.4) (2022-06-14)


### Bug Fixes

* **templates:** move terraform apply skip logic ([8674b90](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/8674b904617a7e6bfc29e271ce03bb185e363b1c))

### [2.5.3](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.5.2...release/2.5.3) (2022-06-10)


### Bug Fixes

* **steps/azure_web_app_deploy.yml:** fix container set command ([8048596](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/8048596c3ef1734d47e68661348a02f62eaa9969))

### [2.5.2](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.5.1...release/2.5.2) (2022-06-10)


### Bug Fixes

* **steps/azure-get-secrets:** fix bash if statement ([e4e04cd](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/e4e04cdd973088a5844df701e69a04b2a7d416e4))
* **steps/azure-get-secrets:** fix yaml formatting ([7c34919](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/7c349198582c9296eac9d9737a58f16e18627f5a))

### [2.5.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.5.0...release/2.5.1) (2022-06-09)


### Bug Fixes

* **steps/azure-web-app-deploy.yml:** fix app slot name parameter ([e06bd0c](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/e06bd0ccf3baa662f122ace2424fe8c0cdd99063))

## [2.5.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.4.3...release/2.5.0) (2022-06-09)


### Features

* **steps/azure-web-app-deploy.yml:** output staging url ([5348eca](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/5348eca519d782699a156ca07c2eb27dddf847ef))

### [2.4.3](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.4.2...release/2.4.3) (2022-06-09)


### Bug Fixes

* **steps/azure_web_app_deploy.yml:** fix deployment to production slot ([1119522](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/11195227a86b1d4528208382d76d276a58948e90))
* **steps/azure_web_app_deploy.yml:** run app service deploy webhook as part of pipeline ([8ac9023](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/8ac9023c77085276b47409d8cd33f0dc4d90dfa2))

### [2.4.2](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.4.1...release/2.4.2) (2022-06-09)


### Bug Fixes

* **steps/azure-web-app-slot-swap:** fix bash conditional statement ([0e759ed](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/0e759ed4bd081e22cea2310eb8bb29f2f014b115))

### [2.4.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.4.0...release/2.4.1) (2022-06-09)


### Bug Fixes

* **steps/terraform_plan.yml:** make skipApply an output variable ([37cd976](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/37cd9766c3900c5fe2bad0c728f09d6dd5802f4e))

## [2.4.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.3.1...release/2.4.0) (2022-06-08)


### Features

* **steps:** separate slot deploy and slot swap steps ([9832fbf](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/9832fbf5933fd0204f9baa759796b3fc01988198))


### Bug Fixes

* **steps:** add newline at end of file ([2579814](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/2579814397104163c9d129af2e3a9e1e54e328eb))
* **steps:** remove redudant slot swap deploy step ([49212a2](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/49212a29faf19fd52745f33e569c07cb1c142e41))
* **steps:** update echo output for clarity on slot target ([8ba8994](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/8ba89949d5d6ac11d7e2ae1ff90898987962ffe5))
* **steps:** update echo output with slot names ([b042ed7](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/b042ed7cb0bd2e0bd5b9ca75d55c4dad6051de62))
* **steps:** update existing web_app_deploy with slot option ([fa6f6e9](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/fa6f6e9c0c67e2d2217b5c3b4897500f020d6052))

### [2.3.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.3.0...release/2.3.1) (2022-06-08)


### Bug Fixes

* **steps/terragrunt_plan_all.yml:** stop lock files being removed from artifact ([0c23d40](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/0c23d40cbc2288ded3af67ed136c0da16970d122))

## [2.3.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.2.1...release/2.3.0) (2022-06-07)


### Features

* **jobs:** use tests vmss pool for cypress e2e tests by default ([87f34e2](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/87f34e234e0f02ae23b5a325fcade97e29dc129e))

### [2.2.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.2.0...release/2.2.1) (2022-06-06)


### Bug Fixes

* **steps:** combine slot deploy and swap steps and add missing slot arguments ([c1e3ef3](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/c1e3ef3a2fa9b2d94b1beaefaf38944e60b3dd78))
* **steps:** update echo output for clarity ([b28dca1](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/b28dca1ddf2869cf63700b93da51488211a2d502))

## [2.2.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.1.4...release/2.2.0) (2022-06-06)


### Features

* **steps:** support app service slot deployments ([b339564](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/b3395646d3f072f6f03741ff1b2f9e0ce515133b))

### [2.1.4](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.1.3...release/2.1.4) (2022-05-30)


### Bug Fixes

* **templates:** error handling ([53790f5](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/53790f5dfb0e04d5f95029a6f07eda29764ad78a))

### [2.1.3](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.1.2...release/2.1.3) (2022-05-26)


### Bug Fixes

* **azure_web_app_acr_push.yml:** set artifact name to last part of repository name (excluding /) ([44bcaaf](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/44bcaaf71b9d329bf93f5536c42c4c03db9a85c1))

### [2.1.2](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.1.1...release/2.1.2) (2022-05-25)


### Bug Fixes

* **azure_web_app_acr_push.yml:** fix name of artifact to avoid conflicts in multi-job pipelines ([a6e4852](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/a6e48525144afccadfb3467e98684630689e19ae))

### [2.1.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.1.0...release/2.1.1) (2022-05-23)


### Bug Fixes

* **azure_get_secrets.yml:** fix variable name ([fad2a3a](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/fad2a3a82043d1d3f70e8609f2332e6c79e0cb87))

## [2.1.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.0.2...release/2.1.0) (2022-05-23)


### Features

* **templates:** allow multi-job ci pipeline, update stage/job names, check files step template ([dc1eb25](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/dc1eb256b3630dc98b4f156e8f9e9e7790abb9fa))

### [2.0.2](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.0.1...release/2.0.2) (2022-05-17)


### Bug Fixes

* **templates:** fix syntax error in web app deployment script ([4f4973a](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/4f4973aa312f57da777136a691f81d27a7189054))

### [2.0.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/2.0.0...release/2.0.1) (2022-05-17)


### Bug Fixes

* **templates:** fix deployments to app services where image same as previous by enabling cd ([b919af3](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/b919af3fd0e6a6296e44e8e0a5ca6ea42b085ac9))

## [2.0.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/1.2.2...release/2.0.0) (2022-05-11)


### ⚠ BREAKING CHANGES

* **templates:** Parameters changed in main wrapper templates.

https://pins-ds.atlassian.net/browse/DBO-38

* **templates:** refactor Azure authentication and replace Azure tasks ([f35ec62](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/f35ec62f312df5bbd02b5635e11d174795264a23))

### [1.2.2](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/1.2.1...release/1.2.2) (2022-05-10)


### Bug Fixes

* **cypress:** artifact publishing ([88e6350](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/88e6350e5ce3e3de09e456ff0012092f1e4862de))

### [1.2.1](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/1.2.0...release/1.2.1) (2022-05-09)


### Bug Fixes

* **wrapper_ci.yml:** indentation ([306ba0c](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/306ba0cb1eecf6d104327aa078288d2e1990c83e))

## [1.2.0](https://github.com/Planning-Inspectorate/common-pipeline-templates/compare/release/1.1.0...release/1.2.0) (2022-05-09)


### Features

* **templates:** add templates for cypress and branch name check ([5cbb18d](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/5cbb18d83f16e3d1a8b9b9ef2a257635419006c4))
* **templates:** remove post process step from cypress e2e tests ([2391678](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/2391678bf420ec3a916f9ee87c4548ba8b2a06bb))

## 1.1.0 (2022-04-28)


### Features

* **steps/azure_web_app_acr_push.yml:** add steps to run tests ([f79c8df](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/f79c8dfa2f826a646e4728c5aa0762daa5a9432d))


### Bug Fixes

* **azure-pipelines-release.yml:** set username and email before release ([c63cfaf](https://github.com/Planning-Inspectorate/common-pipeline-templates/commit/c63cfaff245a63887ac3534b4bb4fdbaffa46414))

## 1.0.0 (2022-04-13)
