# Checkov Comments

A small Node script to help with checkov upgrades and fixes. It will check for checkov fails and add comments to the code to ignore those checks.
Of course these comments should be reviewed as they are there to highlight potential security or configuration issues.

## Usage

```shell
scripts/checkov-comments> node index.js <path-to-checkov> <path-to-code-folder> [--write]
```

If the `--write` flag is provided, it will write the comments to the code files. Otherwise, it will just print how many fails there were.