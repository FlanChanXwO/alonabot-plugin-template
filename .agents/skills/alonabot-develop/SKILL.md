---
name: alonabot-develop
description: 实现、诊断、重构或设计插件的代码时使用；先确定所有者、调用者与兼容性，再做最小而完整的修改，不夹带无关重构。
---

# 开发插件

本技能把需求落实到本仓的实现。规则以本仓文档为准：[AGENTS.md](../../../AGENTS.md)、[编码规范](../../../docs/coding-standards.zh-CN.md)、[开发指南](../../../docs/development.zh-CN.md)与[贡献指南](../../../CONTRIBUTING.zh-CN.md)。SDK 用法见 [组件开发文档](https://alonabot.github.io/)，协议字段见 Core [Protobuf 定义](https://github.com/AlonaBot/AlonaBot/blob/main/contracts/proto/alonabot/v1)。

## 确定责任和完成条件

读取需求、受影响实现、调用者、已有测试与当前 diff，确认分支和基线；Git 写操作使用独立 worktree。公开入口是 `plugin.go`，命令由 `internal/example/register.go` 集中登记，处理函数位于 `internal/example/handler/`，业务逻辑位于 `internal/example/`，进程入口为 `cmd/alonabot-plugin-example/main.go`。

对 Bug 先追踪输入、责任层和可复现失败；对新行为明确使用者、可观察结果和兼容性影响。需要 Core 或 SDK 配合的改动先在 Core 仓库确认方向，不在本仓绕过 SDK 或复制 Core 的逻辑。

## 在一个所有者内完成修改

代码风格遵循 Google Go Style Guide（可用时加载 `go-google-style-guide`、`go-google-style-decisions`、`go-google-best-practices`），命名使用[编码规范](../../../docs/coding-standards.zh-CN.md#命名与术语)中的术语；只在信任边界做校验，不写防御性的重复检查。优先 SDK 已有能力、具体类型和标准库，类型、方法与常量按职责就近放置。本仓当前没有 `go:generate` 入口，直接维护对应资源。修改内部签名或语义时同步改全部调用方；已发布接口与数据格式按[编码规范](../../../docs/coding-standards.zh-CN.md#版本与兼容性)维护兼容性。

本次触及的包文档、类型字段和函数阶段按[注释技能](../alonabot-code-commenting/SKILL.md)补齐。新依赖须先说明必要性与替代方案并取得维护者批准；新增限额、重试或降级须有现行行为或可复现故障依据。

## 验证并交付

按[测试技能](../alonabot-test/SKILL.md)选择最小有效证据，同步受影响的调用者、资源、使用文档和 changelog。较大改动按[审查技能](../alonabot-review/SKILL.md)检查最终 diff。

交付说明位置、实际行为、命令结果和未运行项。实现完成不等于已获 commit、push、PR 或 merge 授权；创建 PR 时再使用 [PR 技能](../alonabot-pr/SKILL.md)。
