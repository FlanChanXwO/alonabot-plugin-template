<!--
提交前确认：不含凭据、真实用户数据、私有地址或本地临时文件。
Before submitting: no credentials, real user data, private URLs, or local temporary files.
-->

<!--
Closes #123
-->

## 变更与原因 / Changes

<!--
改了什么、为什么。关联 Issue 用 `Closes #123`（合并后关闭）。
What changed and why. Link an issue with `Closes #123` (closes on merge).
-->

## 验证 / Verification

<!--
实际运行的命令、平台和结果。未运行的检查说明原因；跳过、fixture 和交叉编译分别标注。写明提交的测试新增了多少行，以及本地跑过但未提交的测试。
Commands, platform, and results actually run. Explain any check not run; mark skips, fixtures, and cross-compiles separately. State how many lines of committed tests were added, and which local tests ran without being committed.
-->

## 兼容性与风险 / Compatibility and risks

<!--
协议、SDK、配置、数据或运行方式的影响及必要恢复方法；没有影响时明确写“无”。
Impact on protocol, SDK, config, data, or how it runs, plus the recovery steps. Write "none / 无" when there is no impact.
-->

## 检查清单 / Checklist

- [ ] 改动在已确认范围内，不含凭据、真实用户数据或本地临时测试 / The change stays within the confirmed scope and contains no credentials, real user data or local temporary tests
- [ ] 没有新增依赖，或已取得维护者明确批准并说明用途 / No new dependencies, or a maintainer approved them and their purpose is stated
- [ ] 已按编码规范检查包文档、命名、注释与测试提交范围，或本次不涉及代码 / Package docs, naming, comments and committed test scope follow the coding standards, or this change has no code
- [ ] 相关契约、文档和生成源已同步，或本次不需要同步 / Related contracts, documentation and generated sources are in sync, or no sync was needed
