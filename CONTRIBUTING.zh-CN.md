# 参与插件开发

[English](CONTRIBUTING.md)

遵循同步自 Core 的[编码规范](docs/coding-standards.zh-CN.md)和本仓流程。工具与检查见[开发指南](docs/development.zh-CN.md)。较大的行为或数据改动先开 Issue 说明使用场景和预期结果。添加依赖前说明必要性和替代方案，取得维护者明确批准后再添加。

## 分支与提交

从最新 `main` 创建用途明确的分支，例如 `feat/greeting`、`fix/config`、`docs/usage`。Git 写操作在独立 worktree 进行；一个 PR 解决一个连贯问题，并保留其他贡献者的工作。commit、push 和发布遵循维护者的明确授权。

每个 commit 应包含完整、可审阅的修改：同步受影响调用者、配置、翻译和文档，运行与修改相关的检查，排除个人记录、凭据、运行数据和临时测试。commit message 使用简体中文，说明改动及必要原因，类型前缀按需使用。代码注释和内部维护说明同样使用简体中文。日志、错误、标识符、CLI 输出使用英文；公开指南和 changelog 提供对应的中英版本。

只提交通过真实入口的集成测试。现有 `plugin_test.go` 经 `New()` 驱动真实 Core 与测试 Adapter。单元、边界与临时测试放已忽略的 `*_local_test.go`，一次性脚本放已忽略的 `tmp/test/`。每个 PR 默认新增一个主路径集成测试；需要多个时说明理由，并记录新增的提交测试行数。

## 提交 PR

1. 目标分支为 `main`。标题使用 `type/scope: 中文摘要`，例如 `fix/config: 修复问候配置读取`。类型为 `feat`、`fix`、`docs`、`refactor`、`test`、`ci`、`build`、`chore`、`perf`、`revert`；scope 使用小写英文模块名，可用连字符连接。
2. 填写 [PR 模板](.github/PULL_REQUEST_TEMPLATE.md)：变更与原因、实际命令/平台/结果、未运行项及原因、兼容性与风险。用 `Closes #123` 关联 Issue，清单按实际情况勾选。
3. 检查 diff 的范围和敏感信息。行为变化同步用法、翻译与 `changelog/<版本>/{en-US,zh-CN}.md`。
4. 等待当前 head 的检查和维护者审阅，根据反馈修改并运行受影响检查。维护者审阅后 squash 合并，并负责版本与发布。

CI [Repository](.github/workflows/ci.yml) 检查空白和路径，允许公共技能，拒绝个人记录和本机工具。`Component checks` 按路径选择 Go、组件与离线检查。[PR metadata](.github/workflows/pr-metadata.yml) 校验非草稿 PR 的标题、段落与清单；[PR triage](.github/workflows/pr-triage.yml) 读取受信配置分配标签，保持与贡献者代码隔离。派生仓库维护者配置标签、按需指派与分支保护。

## 反馈与许可

Bug 报告附插件/SDK 版本、系统/架构、复现步骤、预期与实际行为及完整相关报错，并移除凭据和真实用户数据。漏洞通过[私密安全报告](https://github.com/AlonaBot/AlonaBot/security/advisories/new)提交；通用求助前往[讨论区](https://github.com/AlonaBot/AlonaBot/discussions)。派生仓库应按自身支持渠道更新联系链接。

统一编码规则先在 Core 修改，仓库专用依赖与已批准例外写入编码规范文末。维护者流程见[发布指南](docs/releasing.zh-CN.md)。贡献采用 [MIT License](LICENSE)，按要求保留第三方版权声明。
