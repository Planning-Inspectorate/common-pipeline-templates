# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

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
