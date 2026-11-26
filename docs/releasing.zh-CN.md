# 打包与发布自己的插件

[English](releasing.md)

按[开发指南](development.zh-CN.md)准备环境后，验证并生成本地归档：

```fish
go build ./...
go vet ./...
go test ./...
alonabot check .
alonabot test .
alonabot pack . --target linux/amd64 --out bin
```

模板支持 linux/amd64、linux/arm64、darwin/amd64、darwin/arm64、windows/amd64。归档包含插件声明、可执行文件、资源与 `LICENSE`。保持版权人和年份准确。

## 准备版本

1. 完成[改名清单](development.zh-CN.md)，尤其是 `plugin.yaml` 身份和 `source: github.com/<owner>/<repo>`。
2. 设置 `plugin.yaml` 版本，初始示例为 `0.1.0`。添加对应的 `changelog/<版本>/en-US.md`、`zh-CN.md`，记录实际变更；首次发布前替换示例条目。先写一个版本标题，再写变更分类标题。遵循 [Core 更新日志约定](https://github.com/AlonaBot/AlonaBot/blob/main/changelog/README.zh-CN.md)，PR 链接放条目末尾，有用户操作要求时写明。
3. 按[贡献流程](../CONTRIBUTING.zh-CN.md)审阅并合并。启用 GitHub Actions，允许 Release job 写入仓库内容。
4. 获维护者授权后，在发行 commit 创建并推送匹配标签：

```fish
git tag v0.1.0
git push origin v0.1.0
```

## 自动发布

推送 `v*` 标签触发 [.github/workflows/release.yml](../.github/workflows/release.yml)。工作流沿用 `go get ...@latest` 拉取 SDK，构建对应 CLI，运行测试、vet 与 `alonabot check .`，再调用 [scripts/release.sh](../scripts/release.sh)：

```fish
bash scripts/release.sh v0.1.0 OWNER/alonabot-plugin-example
```

脚本校验标签/版本、source/仓库及两份 changelog，重建 `dist/`，打包五个目标并检查每个归档内的 `LICENSE`。`dist/notes.md` 分为 `## English` 与 `## 简体中文`，跳过首个版本标题，将分类统一为 `###` 并保留 fenced code。工作流将归档和说明发布为 GitHub Release。源码下载由 GitHub 提供。

重试失败发行前，先读取首个错误并解决原因。每次工作流运行都会重新解析 SDK `latest`，排查发行行为时记录实际版本。本模板保留组织模板的 SDK 获取策略。

通用安装与组件开发见[文档站](https://alonabot.github.io/)。跨组件改动与 Core 维护者协调，并纳入对应整合验证。
