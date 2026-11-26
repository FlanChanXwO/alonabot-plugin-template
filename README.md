# AlonaBot Go plugin template

[English](README.md) · [简体中文](README.zh-CN.md)

Create an AlonaBot Go plugin with the Core coding standards, integration testing, i18n, bilingual documentation and GitHub automation already in place. This repository is intended to be published as `FlanChanXwO/alonabot-plugin-template`, based on the organization template `AlonaBot/alonabot-plugin-template`. Official and personal plugins can use the same layout and contribution workflow.

## Create your plugin

1. Choose **Use this template → Create a new repository** on GitHub. Name the repository `alonabot-plugin-<name>`.
2. Clone your new repository and run the rename script from its root:

```fish
bash scripts/rename.sh AlonaBot builtin
```

This example prepares `AlonaBot/alonabot-plugin-builtin`. For a personal plugin, supply your account and a lowercase short name such as `my-plugin`; omit the `alonabot-plugin-` prefix. Hyphens are removed from the Go package name (`myplugin`). The script runs once on an unrenamed template and uses ordinary file moves.

Review these replacements before developing:

| Location | Replace or review |
| --- | --- |
| [go.mod](go.mod), Go imports | `github.com/OWNER/alonabot-plugin-example` → your module path |
| [plugin.go](plugin.go), [plugin_test.go](plugin_test.go), [internal/example](internal/example) | `example` package and implementation directory → your Go package name |
| [cmd/alonabot-plugin-example](cmd/alonabot-plugin-example) | executable directory → `alonabot-plugin-<name>` |
| [plugin.yaml](plugin.yaml) | ID, name, author, source and description; source must match the new repository |
| [LICENSE](LICENSE) | `OWNER` and copyright year |
| Documentation, public skills and GitHub settings | renamed paths, project introduction, labels, optional assignees and repository URLs |

The script replaces the module path, imports, package names, directories, plugin ID/name/source/author, copyright holder and matching public text. Edit the description, copyright year and project-specific documentation yourself. Instructions for manual replacement are in [development](docs/development.md).

## Run the example

Use the Go version declared in `go.mod` (managed with asdf locally). Keep the template's SDK declaration `latest` and obtain it with the same command used in CI:

```fish
go get github.com/AlonaBot/AlonaBot@latest
go mod download github.com/AlonaBot/AlonaBot
env GOTOOLCHAIN=(go env GOVERSION) go -C (go list -m -f '{{.Dir}}' github.com/AlonaBot/AlonaBot) install ./cmd/alonabot
alonabot run . --data-dir ./data
```

Add the Go bin directory to PATH. Type `/hello` in the interactive terminal: the default reply is `Hello AlonaBot`. Development mode reloads source changes. Configuration, supported locales and platform usage are described in [usage](docs/usage.md).

Go resolves `latest` to a concrete version and updates `go.mod`/`go.sum`. Review those changes in your derived repository. CI and releases retain the organization template's `go get ...@latest` step.

## Develop, test and release

`plugin.go` constructs the plugin, `internal/example/register.go` registers all commands, `internal/example/handler/` holds one file per command, and business logic belongs to `internal/example/`. `cmd/alonabot-plugin-example/main.go` calls `sdk.Run`. Commands use the root plugin directly.

```fish
go build ./...
go vet ./...
go test ./...
alonabot check .
alonabot test .
alonabot pack . --target linux/amd64 --out bin
```

[plugin_test.go](plugin_test.go) is an integration test using real Core and a test Adapter. For releases, update `plugin.yaml` and both `changelog/<version>/en-US.md` and `zh-CN.md`, then push a matching `v*` tag. The release workflow packages five platforms using `scripts/release.sh` and publishes bilingual notes.

- [Usage](docs/usage.md) · [Development](docs/development.md) · [Releasing](docs/releasing.md)
- [Contributing](CONTRIBUTING.md) · [Coding standards](docs/coding-standards.md)
- [Component development documentation](https://alonabot.github.io/)

[MIT License](LICENSE)
