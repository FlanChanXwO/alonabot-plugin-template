# 开发自己的插件

[English](development.md)

先按 [README](../README.zh-CN.md) 改名并安装与所选 SDK 对应的 CLI。以下命令在仓库根目录执行。Go 版本遵循 `go.mod`，本地运行时由 asdf 管理。模板将 SDK 声明为 `latest`，使用与 CI 相同的 `go get github.com/AlonaBot/AlonaBot@latest` 解析，并审阅生成的 module 文件。

## 先改名再实现

```fish
bash scripts/rename.sh AlonaBot builtin
```

参数为 GitHub 账号和小写短名，例如 `builtin`、`my-plugin`。新仓库名为 `alonabot-plugin-<name>`；Go 包名去掉连字符。脚本校验外部参数，要求模板尚未改名；替换 `OWNER`、`alonabot-plugin-example`、包声明和实现路径，再用普通 `mv` 移动 `cmd/alonabot-plugin-example/` 和 `internal/example/`。

手动改名时一起更新：

1. `go.mod` 的 module 路径，以及所有 `github.com/OWNER/alonabot-plugin-example` 下的 Go import。
2. 根包、测试的 package 声明，`internal/example/` 包和目录，以及 `cmd/alonabot-plugin-example/`。
3. `plugin.yaml` 的 `id`、`name`、`author`、`source`、`description`。ID 保留 `alonabot-plugin-` 前缀；`source` 填 `github.com/<owner>/alonabot-plugin-<name>`。
4. `LICENSE` 的版权人 `OWNER` 与年份；同步公共文档、技能路径及仓库专用 GitHub 元数据。
5. 核对 `.github/labeler.yml`，在派生仓库创建 `bug`、`enhancement`、`area: docs`、`area: github-actions`、`area: plugin` 标签，并按维护者需求调整 issue 联系链接和指派人。

脚本负责身份和对应文本；描述、年份、用法及项目专用说明手动修改。完整清单见 [README](../README.zh-CN.md)。

## 源码布局

| 入口 | 职责 |
| --- | --- |
| `plugin.go` | 导出 `New() *sdk.Plugin`，创建根插件并调用 `Register` |
| `internal/example/register.go` | 在同一个根插件登记全部命令 |
| `internal/example/handler/<command>.go` | 每个命令一个处理函数文件，回复经 `c.T` 翻译 |
| `internal/example/` | 业务逻辑，命令确有需要时添加 |
| `cmd/alonabot-plugin-example/main.go` | 调用 `sdk.Run`，英文记录失败并退出 |
| `plugin_test.go` | 通过 `New`、真实 Core 和测试 Adapter 做集成测试 |
| `i18n/`、`plugin_config_schema.json`、`plugin.yaml` | 翻译、配置与插件身份 |

登记集中在 `Register`，命令输入输出放处理函数，共享业务逻辑放实现包。向处理函数传入所需业务函数或状态，保持包依赖无环。问候示例只需要配置和翻译。SDK 工具通过构建 overlay 嵌入资源，直接维护这些源文件。

## 验证改动

```fish
gofmt -w plugin.go plugin_test.go internal/example/register.go internal/example/handler/hello.go cmd/alonabot-plugin-example/main.go
go build ./...
go vet ./...
go test ./...
go test -race ./...
alonabot check .
alonabot test .
```

改名后使用新路径执行格式化。`plugin_test.go` 通过真实 Core 与测试 Adapter 覆盖 `/hello` 的默认和自定义配置回复。只提交集成测试。临时单元与边界测试放已忽略的 `*_local_test.go`，一次性脚本放已忽略的 `tmp/test/`。PR 记录实际命令、平台、结果、新增的提交测试行数和未运行项。

CI 按变更路径选择检查，运行 vet、带 race 的集成测试，并为 linux/amd64、linux/arm64、windows/amd64、darwin/amd64、darwin/arm64 做 pure-Go 构建。资源变更触发 `alonabot check .` 和 `alonabot test .` 离线加载。交叉编译验证构建，平台行为另需对应证据。

手动交叉编译：

```fish
for target in linux/amd64 linux/arm64 windows/amd64 darwin/amd64 darwin/arm64
    set -l parts (string split / $target)
    env GOOS=$parts[1] GOARCH=$parts[2] CGO_ENABLED=0 go build ./...
end
```

文档与 GitHub 元数据检查相对链接、YAML、修改的脚本及 `git diff --check`。结果有效时复用；相关修改或失败后再重跑。遵循[编码规范](coding-standards.zh-CN.md)、[贡献流程](../CONTRIBUTING.zh-CN.md)与[组件开发文档](https://alonabot.github.io/)。仓库专用依赖与已批准例外写入编码规范文末。
