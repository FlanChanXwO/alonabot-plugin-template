---
name: alonabot-docs
description: 修改插件的文档、changelog、AGENTS/CLAUDE 或仓库技能时使用；维护单一权威、准确状态和中英同步，不扩展为产品实现。
---

# 维护插件的文档与技能

本技能负责文档归属、代理路由和说明准确性。先读受影响的实现或工作流，再修改其现有权威文档。

## 选择唯一所有者

- 功能与配置：[使用指南](../../../docs/usage.zh-CN.md)；项目介绍：README。
- 工具、命令与检查：[开发指南](../../../docs/development.zh-CN.md)；打包与发布：[发布指南](../../../docs/releasing.zh-CN.md)。
- 版本变化：`changelog/<版本>/zh-CN.md` 与 `en-US.md`。
- 编码规范：[docs/coding-standards.zh-CN.md](../../../docs/coding-standards.zh-CN.md) 同步自 Core。规则只在 Core 修改后同步过来，本仓只维护文末的「本仓差异」。
- 代理入口：根 [AGENTS.md](../../../AGENTS.md) 只放路由与必要红线，`CLAUDE.md` 保留薄引用；重复流程写成 `.agents/skills/alonabot-*/SKILL.md`。
- SDK、协议和 Core 行为由 [Core 仓库](https://github.com/AlonaBot/AlonaBot)维护，通用的安装与使用由[文档站](https://alonabot.github.io/)维护，本仓只链接。

## 保持说明可用

内部维护说明、注释、commit message 和仓库技能用简体中文；README、使用、开发和发布指南及 changelog 提供中英两份，内容同步。标识符、命令和报错保留原文。技能的 `name` 与目录一致，`description` 写明触发条件。

状态来自当前分支与实际证据：不把未合并的实现写成已有，不把模拟端结果写成真实平台验证。

## 完成检查

运行 `git diff --check`，核对相对链接、锚点和 YAML，中英两份同步修改。缺少校验工具时先报告，不自动安装依赖。
