# AlonaBot Go 插件模板

[English](README.md) · [简体中文](README.zh-CN.md)

从这个模板创建 AlonaBot Go 插件，直接使用 Core 编码规范、集成测试、i18n、双语文档和 GitHub 自动化。本仓基于组织模板 `AlonaBot/alonabot-plugin-template`，计划发布为 `FlanChanXwO/alonabot-plugin-template`。官方插件与个人插件共用这套布局和贡献流程。

## 创建插件

1. 在 GitHub 选择 **Use this template → Create a new repository**，仓库名使用 `alonabot-plugin-<name>`。
2. 克隆新仓库，在根目录运行改名脚本：

```fish
bash scripts/rename.sh AlonaBot builtin
```

这个例子用于创建 `AlonaBot/alonabot-plugin-builtin`。个人插件填写自己的账号和小写短名，例如 `my-plugin`，省略 `alonabot-plugin-` 前缀。Go 包名去掉连字符（`myplugin`）。脚本对尚未改名的模板执行一次，使用普通文件移动。

开发前核对这些替换：

| 位置 | 替换或检查内容 |
| --- | --- |
| [go.mod](go.mod)、Go import | `github.com/OWNER/alonabot-plugin-example` → 自己的 module 路径 |
| [plugin.go](plugin.go)、[plugin_test.go](plugin_test.go)、[internal/example](internal/example) | `example` 包名与实现目录 → 自己的 Go 包名 |
| [cmd/alonabot-plugin-example](cmd/alonabot-plugin-example) | 可执行入口目录 → `alonabot-plugin-<name>` |
| [plugin.yaml](plugin.yaml) | ID、名称、作者、来源和描述；source 与新仓库一致 |
| [LICENSE](LICENSE) | `OWNER` 与版权年份 |
| 文档、公共技能与 GitHub 设置 | 改名后的路径、项目介绍、标签、按需配置的指派人与仓库 URL |

脚本替换 module、import、包名、目录、插件 ID/name/source/author、版权人和对应公共文本。描述、版权年份与项目特有文档手动修改。手动替换步骤见[开发指南](docs/development.zh-CN.md)。

## 运行示例

使用 `go.mod` 声明的 Go 版本，本地由 asdf 管理。保留模板的 SDK 声明 `latest`，按 CI 相同方式拉取：

```fish
go get github.com/AlonaBot/AlonaBot@latest
go mod download github.com/AlonaBot/AlonaBot
env GOTOOLCHAIN=(go env GOVERSION) go -C (go list -m -f '{{.Dir}}' github.com/AlonaBot/AlonaBot) install ./cmd/alonabot
alonabot run . --data-dir ./data
```

将 Go bin 目录加入 PATH。在交互终端输入 `/hello`，默认回复 `Hello AlonaBot`。开发模式会在源码变化后重载。配置、语言和平台使用见[使用指南](docs/usage.zh-CN.md)。

Go 会将 `latest` 解析为具体版本并更新 `go.mod`/`go.sum`，派生仓库中应审阅这些变化。CI 与发布保留组织模板的 `go get ...@latest` 步骤。

## 开发、测试与发布

`plugin.go` 创建插件，`internal/example/register.go` 集中登记全部命令，`internal/example/handler/` 每个命令一个文件，业务逻辑归 `internal/example/`。`cmd/alonabot-plugin-example/main.go` 调用 `sdk.Run`。命令直接登记在根插件。

```fish
go build ./...
go vet ./...
go test ./...
alonabot check .
alonabot test .
alonabot pack . --target linux/amd64 --out bin
```

[plugin_test.go](plugin_test.go) 使用真实 Core 与测试 Adapter 进行集成测试。发布时更新 `plugin.yaml` 与 `changelog/<版本>/en-US.md`、`zh-CN.md`，推送匹配的 `v*` 标签。发布工作流通过 `scripts/release.sh` 打包五平台归档并生成双语说明。

- [使用](docs/usage.zh-CN.md) · [开发](docs/development.zh-CN.md) · [发布](docs/releasing.zh-CN.md)
- [贡献指南](CONTRIBUTING.zh-CN.md) · [编码规范](docs/coding-standards.zh-CN.md)
- [组件开发文档](https://alonabot.github.io/)

[MIT License](LICENSE)
