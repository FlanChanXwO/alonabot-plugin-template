# Package and release your plugin

[简体中文](releasing.zh-CN.md)

After the [development setup](development.md), verify and package a local archive:

```fish
go build ./...
go vet ./...
go test ./...
alonabot check .
alonabot test .
alonabot pack . --target linux/amd64 --out bin
```

The template supports linux/amd64, linux/arm64, darwin/amd64, darwin/arm64 and windows/amd64. Archives include the plugin manifest, executable, resources and `LICENSE`. Keep the copyright holder and year accurate.

## Prepare a version

1. Finish the [rename checklist](development.md), particularly `plugin.yaml` identity and `source: github.com/<owner>/<repo>`.
2. Set `plugin.yaml` version (initial example: `0.1.0`). Add matching `changelog/<version>/en-US.md` and `zh-CN.md` files describing real changes. Replace the sample entries before the first release. Use one version heading, then change-category headings. Follow the [Core changelog convention](https://github.com/AlonaBot/AlonaBot/blob/main/changelog/README.md); put PR links at the end of entries and describe user actions when needed.
3. Have the change reviewed and merged through the [contribution workflow](../CONTRIBUTING.md). Enable GitHub Actions and allow the Release job to write repository contents.
4. With maintainer authorization, create and push the matching tag from the release commit:

```fish
git tag v0.1.0
git push origin v0.1.0
```

## Automated publishing

Pushing a `v*` tag triggers [.github/workflows/release.yml](../.github/workflows/release.yml). It obtains the SDK with the existing `go get ...@latest` command, builds a matching CLI, runs tests, vet and `alonabot check .`, then calls [scripts/release.sh](../scripts/release.sh):

```fish
bash scripts/release.sh v0.1.0 OWNER/alonabot-plugin-example
```

The script checks the tag/version, source/repository and both changelog files, rebuilds `dist/`, packages all five targets, and verifies each archive's `LICENSE`. It writes `dist/notes.md` under `## English` and `## 简体中文`, removes the first version heading, normalizes category headings to `###` and preserves fenced code. The workflow publishes the archives and notes as a GitHub Release. Source downloads are supplied by GitHub.

Before retrying a failed release, read the first error and correct its cause. SDK `latest` is resolved anew by each workflow run; record the resolved version when diagnosing release behavior. This template keeps the organization template's SDK retrieval policy.

General installation and component development are documented on the [documentation site](https://alonabot.github.io/). Cross-component changes should be coordinated with Core maintainers and included in their integration validation.
