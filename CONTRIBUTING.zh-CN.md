# 参与插件开发

[English](CONTRIBUTING.md)

欢迎提交功能、问题修复、测试与文档改进。开发环境和本地调试见 [README](README.zh-CN.md#准备-sdk-与-cli)。

## 修改插件

命令在 `plugin.go` 的 `New` 中注册。新增或修改功能时，同步调整配置声明 `plugin_config_schema.json`，并在 `plugin_test.go` 中补充对应测试。涉及使用方式变化时，更新 README。

报告问题请附上插件与 SDK 版本、操作系统、复现步骤及相关日志，并移除凭据和私人数据。较大的功能建议先通过 Issue 讨论设计与使用场景。

## 验证改动

按改动范围运行：

```bash
go vet ./...
go test -race ./...
alonabot check .
alonabot test .
```

提交前使用 `gofmt` 格式化修改的 Go 文件。`go test` 验证命令行为，`alonabot check .` 校验组件声明，`alonabot test .` 检查离线加载与注册。涉及打包时，按 [README](README.zh-CN.md#打包与发布) 构建目标平台的包。

## 提交 PR

填写 [PR 模板](.github/PULL_REQUEST_TEMPLATE.md)，说明改动内容、原因、验证结果，以及对现有命令、配置或数据的影响。关联相关 Issue；有未运行的检查时写明原因。

发布前将 `CHANGELOG.md` 中的示例替换为实际英文变更说明，并更新 `plugin.yaml` 的版本，具体流程见 [README](README.zh-CN.md#打包与发布)。
