[![StepSecurity Maintained Action](https://raw.githubusercontent.com/step-security/maintained-actions-assets/main/assets/maintained-action-banner.png)](https://docs.stepsecurity.io/actions/stepsecurity-maintained-actions)

# Install Hatch Action

-----

This is an action to install Hatch in your GitHub Actions workflow.

## Usage

You must [use](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses) this action in one of your [jobs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobs)' [steps](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idsteps):

```yaml
- name: Install Hatch
  uses: step-security/pypa-hatch@v1
```

## Options

Name | Default | Description
--- | --- | ---
`version` | `latest` | The version of Hatch to install (e.g. `1.11.1`).

## External consumers

It's possible to use the [install script](https://github.com/step-security/pypa-hatch/blob/main/main.sh) outside of GitHub Actions assuming you set up your environment as follows:

- Set every [option](#options) to an environment variable with uppercasing and replacing hyphens with underscores.
- Set the `RUNNER_TOOL_CACHE` environment variable to the directory where you want to install Hatch.
- Set the `GITHUB_PATH` environment variable to a file that is writable which will contain the final directory where Hatch gets installed (usually `$RUNNER_TOOL_CACHE/.hatch`).
- Set the `RUNNER_OS` environment variable to the current platform using one of the following values:
    - `Linux`
    - `Windows`
    - `macOS`
- Set the `RUNNER_ARCH` environment variable to the current architecture using one of the following values:
    - `X64`
    - `ARM64`
- Install [pipx](https://github.com/pypa/pipx) as a fallback installation method for when there is no [standalone binary](https://hatch.pypa.io/latest/install/#standalone-binaries) available. In this case, nothing will be written to `GITHUB_PATH`.
