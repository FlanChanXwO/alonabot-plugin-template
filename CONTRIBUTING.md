# Contribute to the plugin

[简体中文](CONTRIBUTING.zh-CN.md)

Contributions to features, bug fixes, tests, and documentation are welcome. See the [README](README.md#set-up-the-sdk-and-cli) for development setup and local debugging.

## Change the plugin

Commands are registered in `New` in `plugin.go`. When adding or changing a feature, update configuration declarations in `plugin_config_schema.json` and add corresponding tests in `plugin_test.go`. Update the README when usage changes.

For bug reports, include the plugin and SDK versions, operating system, reproduction steps, and relevant logs. Remove credentials and private data. Discuss larger features in an Issue with a proposed design and use cases.

## Verify changes

Run checks relevant to your change:

```bash
go vet ./...
go test -race ./...
alonabot check .
alonabot test .
```

Format changed Go files with `gofmt` before submitting. `go test` verifies command behavior, `alonabot check .` validates component declarations, and `alonabot test .` checks offline loading and registration. For packaging changes, build a package for the target platform using the [README](README.md#package-and-release).

## Submit a PR

Complete the [PR template](.github/PULL_REQUEST_TEMPLATE.md) with what changed, why, verification results, and the impact on existing commands, configuration, or data. Link related Issues and explain any checks not run.

Before releasing, replace the examples in `CHANGELOG.md` with actual English change descriptions and update the version in `plugin.yaml`. See the [README](README.md#package-and-release) for the release process.
