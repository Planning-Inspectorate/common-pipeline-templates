# PINS Pipeline Templates

This repository holds a collection of pipeline templates. These are a series of independent pipeline template yaml files, that can be consumed by implementing pipelines.

## Structure

All template files should be held within these folders:

- [jobs](jobs)
- [stages](stages)
- [steps](steps)
- [variables](variables)

## Usage

This repository acts as a reference that allows a pipeline to consume the templates held here in order to achieve a complete pipeline. This limits the amount of code in the component repositories and allowing for a separation of concerns between development and pipeline setup. This repository does not contain any complete pipelines, but rather the building blocks for complete pipelines to consume.

All consuming pipelines should declare this repository as a resource:

```
resources:
  repositories:
    - repository: templates
      type: github
      endpoint: Planning-Inspectorate
      name: Planning-Inspectorate/common-pipeline-templates
```

`endpoint` refers to the name of the GitHub service connection in your pipeline.

To use the templates in your pipeline, see the [Microsoft documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops) on templates.

## Versioning & Setup

This repository makes use of simple semantic versioning via the following npm tools:
- [commitizen](https://github.com/commitizen/cz-cli) - CLI tool to construct commit messages in a format to enable automatically populating the changelog.
- [commitlint](https://github.com/conventional-changelog/commitlint) - Linting tool to enforce commites in the correct style
- [standard-version](https://github.com/conventional-changelog/standard-version) - CLI tool responsible for creating versions and updating changelog.

### Setup

To install the tools above, you need [NodeJS and NPM](https://nodejs.org/en/download/) installed on your machine.

Once these are installed just run `npm install` in the root directory and these will be available when working locally.

This repo contains pre-commit hooks with Husky. To activate these run `npx husky install`

### Versioning 

All commits to a feature branch are used to determine what updates should be made to the changelog. This is why they must be in the format enforced by `commitizen` and `commitlint`. The changelog will be updated when a Pull Request is merged to `main`, and the `standard-version` release task runs.

**IMPORTANT:** When raising Pull Requests make sure the "Rebase & Merge" option is selected. This will ensure that all commits are added to the `main` branch, so the release task can update the changelog correctly.

The release task is run in the release pipeline, and will run whenever there is a commit to the `main` branch. This task will bump the version number in the `package.json` files, and add the release details to the changelog based on the commits.

After the release task has run, a new commit should appear in the `main` branch and this commit should be tagged with `release/<version_number>`.

**Note:** Due to a limitation within GitHub, it is not possible to provide the Azure Pipelines app permission to push to a protected branch. Therefore, the pipelines make use of a Personal Access Token (PAT) to perform the final push to GitHub that updates version numbers. This PAT is tied to an individual user account, so may expire or become invalid whenever that user is removed from the project. The PAT can be updated by an admin user on the repository by generating a new PAT for their account, and updating the value in the `pipeline_secrets` variable group within Azure Pipelines.
