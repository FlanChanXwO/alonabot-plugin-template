# 插件开发约定

本仓是 AlonaBot Go 插件模板；派生仓库维护自己的插件，公开入口是 `plugin.go`，命令集中登记在 `internal/example/register.go`，处理函数位于 `internal/example/handler/`，业务逻辑归 `internal/example/`；进程入口为 `cmd/alonabot-plugin-example/main.go`。SDK、协议与 Core 在 [Core 仓库](https://github.com/AlonaBot/AlonaBot)维护，安装与通用使用文档在[文档站](https://alonabot.github.io/)。

## 先读什么

维护技能位于 `.agents/skills/`，客户端未自动发现时直接读取下表链接；只加载本次任务需要的入口。

| 任务 | 先读 | 完成前检查 |
| --- | --- | --- |
| 实现、诊断或重构代码 | [开发技能](.agents/skills/alonabot-develop/SKILL.md)、[编码规范](docs/coding-standards.zh-CN.md)、[开发指南](docs/development.zh-CN.md) | 入口、调用者与必要相邻修改完整 |
| 新增或修改代码注释 | [注释技能](.agents/skills/alonabot-code-commenting/SKILL.md) | 包文档、文档注释、字段与 step 注释符合现状 |
| 选择测试或记录验证 | [测试技能](.agents/skills/alonabot-test/SKILL.md)、[开发指南](docs/development.zh-CN.md) | 只提交覆盖真实入口的集成测试；本地测试写在 `*_local_test.go` |
| 审查分支、commit 或 PR | [审查技能](.agents/skills/alonabot-review/SKILL.md) | 行为与规范两轴，问题有位置、影响和修复方案 |
| 准备 PR 或诊断 CI | [PR 技能](.agents/skills/alonabot-pr/SKILL.md)、[贡献指南](CONTRIBUTING.zh-CN.md) | 授权、模板、当前 head 的检查及真实未运行项 |
| 修改文档、changelog、AGENTS 或技能 | [文档技能](.agents/skills/alonabot-docs/SKILL.md) | 权威单一、链接有效、中英同步 |
| 打包与发布 | [发布指南](docs/releasing.zh-CN.md) | 发布授权与版本记录 |

## 工作约定

- 沟通、内部维护说明、代码注释和 commit message 使用简体中文；日志、错误、标识符与 CLI 输出使用英文；公开文档中英同步。
- 先读受影响代码、调用方和当前 diff，保留其他维护者改动；Git 写操作在独立 worktree，提交与远端操作按明确授权执行。
- 新依赖先说明必要性与替代方案，取得维护者批准。
- 编码规范同步自 Core：修改规则先改 Core，再同步到本仓；本仓只维护其中的「本仓差异」。
- 不把模拟端、fixture 或交叉编译结果记成真实平台的验证。
- 个人维护资料（ADR、spec、goal）不进入本仓 main，CI 会拒绝；凭据、运行数据和临时文件留在本机。
