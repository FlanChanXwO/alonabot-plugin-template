# alonabot-plugin-template

[简体中文](README.zh-CN.md)

A project template for developing AlonaBot plugins. It demonstrates the same hello example as `alonabot init`, plugintest integration tests, and five-platform packaging with GitHub Releases.

## Create a plugin project

1. Select [Use this template](https://github.com/new?template_owner=AlonaBot&template_name=alonabot-plugin-template), then clone your new repository.
2. Set the `module` in `go.mod` to your repository path and update imports of this project. Keep the SDK path `github.com/AlonaBot/AlonaBot` unchanged.
3. Update `id`, `name`, `description`, `author`, and `source` in `plugin.yaml`. Use the `alonabot-plugin-` prefix followed by lowercase letters, digits, and hyphens for `id`. Set `source` to `github.com/<account>/<repository>`; the release script checks it against the actual repository.
4. Replace the `owner` assignee placeholder in `.github/`, choose a license, and add `LICENSE`. Replace both READMEs with development and usage instructions for your plugin.

## Set up the SDK and CLI

Install the Go version declared in `go.mod`, then fetch the latest SDK and install the CLI:

**Bash (Linux / macOS)**

```bash
go get github.com/AlonaBot/AlonaBot@latest
go install github.com/AlonaBot/AlonaBot/cmd/alonabot@latest
```

**PowerShell (Windows)**

```powershell
go get github.com/AlonaBot/AlonaBot@latest
go install github.com/AlonaBot/AlonaBot/cmd/alonabot@latest
```

## Write commands

- `plugin.go`: `New` creates the plugin and registers the hello command.
- `plugin_config_schema.json`: configuration declarations, initially empty.
- `plugin_test.go`: command reply tests using a real Core and test Adapter.
- `plugin.yaml`: plugin identity, version, and source.
- `scripts/release.sh`: version and source checks, followed by five-platform packaging.

The `hello` command is registered with:

```go
p.Command("hello").Menu().Description("Show a greeting").Handle(func(c *sdk.Context) error {
    return c.Reply("Hello AlonaBot")
})
```

The handler replies with `c.Reply("Hello AlonaBot")`; `.Menu()` adds the command to automatic menus.

To add a command, register its handler in `New`, add configuration declarations as needed, and verify replies and failure paths in `plugin_test.go`. Split implementation files by feature as the plugin grows.

## Debug and check locally

```bash
alonabot run --reload .
```

This starts Core with the plugin and rebuilds it when source files change. Runtime data is stored in the ignored `data/` directory. Send `/hello` on a connected chat platform to try the example; the command prefix follows Core configuration.

Before submitting, select checks for the affected behavior using the [contribution guide](CONTRIBUTING.md#verify-changes). `go test` runs integration tests, `alonabot check .` validates component declarations, and `alonabot test .` checks offline loading and registration.

## Package and release

Build a package for one platform locally:

```bash
alonabot pack . --target linux/amd64 --out bin
```

To publish from your own repository:

1. Update `version` in `plugin.yaml`. Replace the examples in `CHANGELOG.md` with actual English release notes under a `## [version] - YYYY-MM-DD` heading.
2. Commit the changes, then create and push a matching `v<version>` tag, such as `v0.1.0`.
3. The `Release` workflow fetches the latest SDK, builds its matching CLI, runs tests, and packages linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, and windows/amd64. It uploads the archives and publishes the version's release notes.

Enable GitHub Actions in the generated repository. The tag must match the plugin version, and `source` must match the repository path; the release script stops if either check fails.

## Contribute to the plugin

See the [contribution guide](CONTRIBUTING.md) to add features, fix bugs, or improve documentation.

For more SDK usage, see the [Core plugin guide](https://github.com/AlonaBot/AlonaBot/blob/main/docs/plugin-guide.md).
