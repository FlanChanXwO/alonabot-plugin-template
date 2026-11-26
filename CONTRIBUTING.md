# Contribute to your plugin

[简体中文](CONTRIBUTING.zh-CN.md)

Follow the [coding standards](docs/coding-standards.md), synced from Core, and this repository's workflow. Use the [development guide](docs/development.md) for tools and checks. Larger behavior or data changes start with an Issue describing the use case and proposed result. Explain new dependencies and alternatives, then obtain explicit maintainer approval before adding them.

## Branches and commits

Start from the latest `main`, with a focused branch such as `feat/greeting`, `fix/config` or `docs/usage`. Perform Git writes in an independent worktree; keep one coherent change per PR and preserve other contributors' work. Commits, pushes and releases follow the maintainer's explicit authorization.

Every commit should contain a complete, reviewable change: keep affected callers, configuration, translations and documentation in sync, run the checks relevant to that change, and omit local records, credentials, runtime data and temporary tests. Use Simplified Chinese commit messages describing the change and necessary reason; a fixed type prefix is optional. Code comments and internal maintenance instructions also use Simplified Chinese. Logs, errors, identifiers and CLI output use English; public guides and changelogs have matching English and Simplified Chinese versions.

Commit only integration tests through real entry points. The existing `plugin_test.go` drives `New()` through real Core and a test Adapter. Local unit, boundary and temporary tests use ignored `*_local_test.go`; one-off scripts use ignored `tmp/test/`. A PR normally adds one main-path integration test; explain any additional tests and record the number of committed test lines added.

## Open a PR

1. Target `main`. Use `type/scope: 中文摘要`, for example `fix/config: 修复问候配置读取`. Types: `feat`, `fix`, `docs`, `refactor`, `test`, `ci`, `build`, `chore`, `perf`, `revert`. Scope is a lowercase English module name, with optional hyphens.
2. Fill out the [PR template](.github/PULL_REQUEST_TEMPLATE.md): change and reason, actual commands/platform/results, unrun checks with reasons, compatibility and risk. Link an Issue with `Closes #123` and check only statements supported by the change.
3. Review the diff for scope and sensitive data. Sync usage, translations and `changelog/<version>/{en-US,zh-CN}.md` when behavior changes.
4. Wait for checks on the current head and maintainer review. Apply feedback and rerun affected checks. Maintainers review and squash merge; maintainers control versions and releases.

CI [Repository](.github/workflows/ci.yml) checks whitespace and paths, allowing public skills while rejecting personal notes and local tools. `Component checks` selects Go, component and offline checks by path. [PR metadata](.github/workflows/pr-metadata.yml) validates non-draft PR titles, sections and checklist; [PR triage](.github/workflows/pr-triage.yml) applies labels from trusted configuration, with no contributor code execution. Derived repository maintainers configure labels, optional assignees and branch protection.

## Reports and license

Bug reports include plugin/SDK versions, OS/architecture, reproduction, expected and actual behavior, and full relevant errors. Remove credentials and real user data. Report vulnerabilities through [private security reporting](https://github.com/AlonaBot/AlonaBot/security/advisories/new); use the [discussion forum](https://github.com/AlonaBot/AlonaBot/discussions) for general questions. Derived repositories should update contact links for their own support channels.

Shared coding rules change in Core first; repository-specific dependencies and approved exceptions go in the standards' final section. See [releasing](docs/releasing.md) for maintainer steps. Contributions are provided under the [MIT License](LICENSE); retain third-party notices where required.
