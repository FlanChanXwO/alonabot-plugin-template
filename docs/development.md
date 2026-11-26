# Develop your plugin

[简体中文](development.zh-CN.md)

Start with the [README setup](../README.md) to rename the project and install a CLI matching the selected SDK. Run commands below from the repository root. Go follows `go.mod`, with asdf for local runtime management. The template declares the SDK as `latest`; `go get github.com/AlonaBot/AlonaBot@latest` resolves it, as in CI. Review the resulting module files.

## Rename before implementing

```fish
bash scripts/rename.sh AlonaBot builtin
```

Use a GitHub account and a lowercase short name, such as `builtin` or `my-plugin`. The resulting repository is `alonabot-plugin-<name>`; Go package names remove hyphens. The script validates its external arguments and requires an unrenamed template. It replaces `OWNER`, `alonabot-plugin-example`, package declarations and implementation paths, then moves `cmd/alonabot-plugin-example/` and `internal/example/` with ordinary `mv`.

For manual replacement, update all of these together:

1. The module path in `go.mod` and every Go import under `github.com/OWNER/alonabot-plugin-example`.
2. The root and test package declarations, the `internal/example/` package and directory, and `cmd/alonabot-plugin-example/`.
3. `plugin.yaml`: `id`, `name`, `author`, `source` and `description`. Keep the `alonabot-plugin-` ID prefix; `source` must be `github.com/<owner>/alonabot-plugin-<name>`.
4. The `OWNER` copyright holder and year in `LICENSE`; update public documentation, skill paths and any repository-specific GitHub metadata.
5. Review `.github/labeler.yml` and create `bug`, `enhancement`, `area: docs`, `area: github-actions` and `area: plugin` labels in the derived repository. Adjust issue contact links and optional assignees for its maintainers.

The script handles identity and matching text; edit descriptions, the year, usage and project-specific instructions yourself. See the [README checklist](../README.md).

## Source layout

| Entry | Responsibility |
| --- | --- |
| `plugin.go` | Export `New() *sdk.Plugin`; construct the root plugin and call `Register` |
| `internal/example/register.go` | Register every command on that root plugin |
| `internal/example/handler/<command>.go` | One handler per command; translate replies with `c.T` |
| `internal/example/` | Business logic, added when the command needs it |
| `cmd/alonabot-plugin-example/main.go` | Call `sdk.Run`, log errors in English and exit on failure |
| `plugin_test.go` | Integration tests through `New`, real Core and a test Adapter |
| `i18n/`, `plugin_config_schema.json`, `plugin.yaml` | Translations, configuration and plugin identity |

Keep registration in `Register`, command input/output in handlers, and shared business logic in the implementation package. Pass needed business functions or state to handlers to keep package imports acyclic. The greeting example only needs configuration and translation. SDK tooling embeds resources with a build overlay; maintain these source resources directly.

## Verify changes

```fish
gofmt -w plugin.go plugin_test.go internal/example/register.go internal/example/handler/hello.go cmd/alonabot-plugin-example/main.go
go build ./...
go vet ./...
go test ./...
go test -race ./...
alonabot check .
alonabot test .
```

After renaming, use the new paths for formatting. `plugin_test.go` covers default and configured `/hello` replies through real Core with a test Adapter. Commit integration tests only. Put temporary unit/boundary tests in ignored `*_local_test.go` and one-off scripts in ignored `tmp/test/`. Record actual commands, platform, results, added committed test lines and unrun checks in the PR.

CI selects checks from changed paths, runs vet and integration tests with race detection, and builds pure Go for linux/amd64, linux/arm64, windows/amd64, darwin/amd64 and darwin/arm64. Resource changes trigger `alonabot check .` and offline loading with `alonabot test .`. Cross-compilation verifies builds; platform behavior needs its own evidence.

For manual cross-compilation:

```fish
for target in linux/amd64 linux/arm64 windows/amd64 darwin/amd64 darwin/arm64
    set -l parts (string split / $target)
    env GOOS=$parts[1] GOARCH=$parts[2] CGO_ENABLED=0 go build ./...
end
```

For documentation and GitHub metadata, inspect relative links, YAML, changed scripts and `git diff --check`. Reuse valid results until a relevant change or failure warrants another run. Follow the [coding standards](coding-standards.md), [contribution workflow](../CONTRIBUTING.md) and [component development documentation](https://alonabot.github.io/). Repository-specific dependencies and approved exceptions belong in the standards' final section.
