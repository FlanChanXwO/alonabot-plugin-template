# alonabot-plugin-template

[English](README.md)

用于开发 AlonaBot 插件的项目模板。提供与 `alonabot init` 一致的 hello 示例、plugintest 集成测试，以及五平台打包与 GitHub Release 工作流。

## 创建插件项目

1. 点击[使用此模板](https://github.com/new?template_owner=AlonaBot&template_name=alonabot-plugin-template)，创建并克隆自己的仓库。
2. 将 `go.mod` 的 `module` 改为新仓库路径；代码中的本项目 import 同步修改。保留 SDK 的 `github.com/AlonaBot/AlonaBot` 路径。
3. 修改 `plugin.yaml`：设置 `id`、`name`、`description`、`author` 和 `source`。`id` 使用 `alonabot-plugin-` 前缀及小写字母、数字、连字符；`source` 填写 `github.com/<账号>/<仓库名>`，发布脚本会核对它与实际仓库一致。
4. 替换 `.github/` 配置中的 `owner` 指派占位，选择许可证并添加 `LICENSE`。将双语 README 改为自己插件的开发与使用说明。

## 准备 SDK 与 CLI

先安装 `go.mod` 声明的 Go 版本，然后获取最新 SDK 并安装 CLI：

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

## 编写命令

- `plugin.go`：`New` 创建插件并注册 hello 命令。
- `plugin_config_schema.json`：配置声明，初始为空。
- `plugin_test.go`：通过真实 Core 和测试 Adapter 验证命令回复。
- `plugin.yaml`：声明插件身份、版本与来源。
- `scripts/release.sh`：核对版本与来源并打包五个平台。

以 `hello` 为例：

```go
p.Command("hello").Menu().Description("Show a greeting").Handle(func(c *sdk.Context) error {
    return c.Reply("Hello AlonaBot")
})
```

处理函数通过 `c.Reply("Hello AlonaBot")` 回复；`.Menu()` 将命令加入自动菜单。

新增命令时，在 `New` 中注册处理函数，按需补充配置声明，并在 `plugin_test.go` 中验证回复与失败路径。实现增多后可按功能拆分文件。

## 本地调试与检查

```bash
alonabot run --reload .
```

该命令启动 Core 与插件，源码变化后自动重建。运行数据写入已忽略的 `data/`。在接入的聊天平台发送 `/hello` 可体验示例；命令前缀以 Core 配置为准。

提交前按改动范围运行检查，具体命令见[贡献指南](CONTRIBUTING.zh-CN.md#验证改动)。`go test` 执行集成测试；`alonabot check .` 校验组件声明，`alonabot test .` 验证离线加载与注册。

## 打包与发布

本地为单个平台打包：

```bash
alonabot pack . --target linux/amd64 --out bin
```

发布到自己的仓库：

1. 更新 `plugin.yaml` 的 `version`，将 `CHANGELOG.md` 示例替换为实际英文发布说明，使用 `## [版本] - YYYY-MM-DD` 标题。
2. 提交变更后，创建并推送匹配的 `v<版本>` 标签，例如 `v0.1.0`。
3. `Release` 工作流获取最新 SDK、构建对应 CLI、运行测试，然后为 linux/amd64、linux/arm64、darwin/amd64、darwin/arm64、windows/amd64 打包，上传归档并发布该版本的说明。

确保生成后仓库已启用 GitHub Actions。标签须与插件版本一致，`source` 须与仓库路径一致；校验失败时发布脚本会停止。

## 参与插件开发

提交功能、修复问题或改进文档，请阅读[贡献指南](CONTRIBUTING.zh-CN.md)。

更多 SDK 用法见 [Core 插件指南](https://github.com/AlonaBot/AlonaBot/blob/main/docs/plugin-guide.zh-CN.md)。
