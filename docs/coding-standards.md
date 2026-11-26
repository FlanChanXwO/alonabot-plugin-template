# AlonaBot coding standards

[简体中文](https://github.com/AlonaBot/AlonaBot/blob/main/docs/coding-standards.zh-CN.md)

Coding and test-submission rules for Core, SDK, protocol and example code; PR review checks against this document. See [contributing](https://github.com/AlonaBot/AlonaBot/blob/main/CONTRIBUTING.md) for the workflow and [architecture](https://github.com/AlonaBot/AlonaBot/blob/main/ARCHITECTURE.md) for module boundaries.

## Style baseline

- Follow [Google Go Style Guide](https://google.github.io/styleguide/go/), including [Style Decisions](https://google.github.io/styleguide/go/decisions) and [Best Practices](https://google.github.io/styleguide/go/best-practices). Load go-google-style-guide/go-google-style-decisions/go-google-best-practices when available.
- Follow code-commenting: explain what names/structure cannot, and use step comments for stages. This document takes priority, chiefly requiring Simplified Chinese code comments.
- Write for engineers with basic Go: clarity before brevity, no clever tricks or abstractions for hypothetical needs.
- Use the Go version in go.mod and gofmt.

## Names and terms

Use the domain terms in the guides/protocol so readers can map code to the same concepts.

| Term | Meaning |
| --- | --- |
| Core / Plugin | Host / component, normally a separate process; library mode shares the host |
| Adapter / Instance | Platform adapter / one configured platform account |
| Session | One authenticated connection between Core and a component |
| Generation | One committed combination of component program, configuration and data |
| Target / Actor | Send destination / event initiator; see sdk/message |
| Route / Handler / Hook | Registered route / callback / interception before or after events/sends |
| MessageChain / Segment | One logical send / its constituent segment |
| MediaRef / IncomingMedia / Grant | Uploaded media reference / inbound media description / read permission issued to another Session |
| Pending / Active | Configuration or generation awaiting activation / current generation |
| Budget / Deadline | Admission byte budget / absolute cutoff |

- Name new concepts in the relevant guide/protocol before implementing them. Use one name per concept throughout the project.
- Avoid vague generic names/suffixes: Kind, Type (universal discriminators), Info, Data, Item, Object, Manager, Helper, Util, Common, Misc, Impl. Prefer actual roles, e.g. Phase, Mode, Source, Status, Registry, Store.
- Spell out Deps/Cfg/Mgr/Svc/Msg/Req/Resp/Tmp/Val. Conventional Go short locals (ctx, err, ok, i, n, msg, req, env) used within a few lines and one/two-letter receivers are allowed. Fields/exported names/wider scopes use full words. Keep ID/URL/HTTP initialisms uppercase.
- Package names are short lowercase nouns; avoid util/common/base/types.
- Generated protocol names (pb.FrameKind/pb.RouteKind) follow .proto without Go aliases. New Go types avoid generic Kind suffixes.

## Organize files by responsibility

- Establish semantic ownership before packages/files. Keep types/methods/validation/specific constants together; split large types by real inbound/outbound/storage operations.
- Group protocol payloads by complete subjects such as calls/registration/messages. Structures owning mutexes/channels/connections/lifecycle state belong to implementation.
- Avoid cross-domain dto.go/types.go/constants.go/utils.go; one type per file is unnecessary.
- Split by responsibility, considering navigation per operation, unique state ownership and ease of correct use, rather than line counts.

## Validate at boundaries

- Validate protocol/plugin/user/filesystem/external-platform inputs at trust boundaries. Internal calls trust types/preconditions without repeated nil checks or impossible-case fallbacks.
- Prefer concrete types, standard libraries and existing implementations. Small interfaces belong at real consuming boundaries, without per-implementation/test/hypothetical wrappers/options.
- Cancellable functions take context.Context first and propagate it. Every goroutine/connection/lock/temporary file needs an owner and exit path.
- Preserve chains with %w, logging only at the handling layer. Return partial results with errors instead of empty fabricated success.
- Limits/timeouts/retries/truncation/fallbacks require contractual or reproducible-failure evidence. Explain new dependencies/alternatives and obtain maintainer approval first.
- cmd/alonabot parses/assembles; protocol/database/process logic stays in responsible packages.

## Default logger and explicit dependencies

Core has one log output through standard log/slog; fields/formats/levels follow internal/core/logging.

- Write each log message as a readable sentence, including DEBUG records. Name the component or route, describe the action and result, and include the reason for a failure or state change. Keep structured attributes for filtering and Trace correlation; the message must make sense on its own. For example, use `Component rollpig changed from ACTIVE to QUIESCING: idle timeout` instead of a generic state-change title followed by fields. Keep message bodies, credentials and other protected values out of summaries.
- Immediately after logging.Open, cmd/alonabot calls slog.SetDefault(out.Logger()) before constructing Core. internal/core packages call slog.Info/Warn/Error/With at logging sites, without storing slog.Default/With results in constructors/fields/package variables.
- Add no logging constructor parameters/Options/fields/context values. Component processes use SDK's default logger.
- Keep these dependencies explicit:
  - Stateful data_dir-specific *state.Store/*adapter.Registry/*router.Router/*policy.Policy and package Limits: state/limits belong to the assembled Core instance.
  - *wire.Budget: Core/SDK share internal/wire, plugin side nil. Explicit arguments distinguish budgets even within library mode.
  - Clocks advanced by tests (now/Options.Now) control the same tested instance's time.
  - supervisor.Spec.Log receives one process's output, preserving source/Session and a separate callback.
- To capture Core logs, set slog.SetDefault to the capture Handler before constructing objects, restore through t.Cleanup and avoid t.Parallel.

<a id="pre-release-compatibility"></a>

## Versioning and compatibility

v0.1.0 is the first released interface/state baseline. Maintain later migrations/public changes as follows:

- Keep published Core state migrations unchanged, including internal/core/state/schema.sql. New tables/columns/constraints use new SQL migrations appended to migrations. Verify previous-release upgrades preserve data and fresh databases reach the final schema.
- Update all callers together for internal signatures/fields/meaning. Explain SDK/protocol/component version effects and upgrade procedures in changelog.
- Compatibility measures target released callers/formats, preserving error handling/data meaning without zero-value reinterpretations.
- Maintain managed SQLite migration APIs; configuration has no version/migrations. Sources/generators own generated files.

## Core state uses GORM

Core state (internal/core/state) uses GORM rather than business SQL strings or string predicates such as Where("plugin_id = ?", id).

- Singular snake_case tables represent one object: install/pending_config/conversation_entry. Join tables combine names, e.g. plugin_adapter_permission. Model TableName selects tables; column tags select columns.
- Equality uses typed conditions. Single primary key: Where(clause.Eq{Column:clause.PrimaryColumn,Value:id}), including empty strings. Composite deletes carry keys, e.g. Delete(&adapterPermission{PluginID:p,AdapterInstanceID:i}). Partial-column matches use structs, e.g. Where(&conversationEntry{PluginID:p,ConversationKey:k}), without appended field-name strings.
- Struct conditions ignore zero values. GORM rejects wholly zero conditions; partial zeros broaden matches and can overdelete. Take with only an empty primary key adds no predicate and may return any row. Validate potentially empty required conditions at entry; use another representation for intentional zero matches.
- Primary-key overwrite: clause.OnConflict{UpdateAll:true}; duplicate no-op: clause.OnConflict{DoNothing:true}, without listing conflict/update columns.
- In transactions read by primary key, check conditions in Go (e.g. uncommitted), mutate then Save. Avoid struct Updates for false/0. Whole-table writes use Session(&gorm.Session{AllowGlobalUpdate:true}), not Where("1 = 1").
- Ranges/order/max use clause.Gte/clause.OrderByColumn and package constants for columns. Max reads one descending row instead of max()/coalesce(). Perform feasible sorting/aggregation in Go; add no GORM CLI/query generators.
- DDL lives in package *.sql files loaded by go:embed; initial migration is internal/core/state/schema.sql. Temporary abnormal-file test tables are exempt.
- PRAGMA reads/read-only pre-open checks are connection management and may use Go SQL strings.
- This applies to Core. Plugins' sdk/sqlitedb database/sql access is a product feature; official plugins choose through [plugin guide](https://alonabot.github.io/en/docs/develop/rules).

## Program output uses English

- Logs/errors/CLI/panics/test failures/protocol safe_message use English. Error strings start lowercase without periods; %w context states the operation, e.g. open SQLite: %w.
- End-user UI/bot text uses i18n dictionaries with English source and Simplified Chinese translations.
- Code comments and internal maintenance instructions use Simplified Chinese. User and developer guides provide English and Simplified Chinese content; short pages may carry both languages together.

## Name meaningful values

- Name meaningful numbers/strings: lengths/caps/timeouts/exit codes/filenames/addresses/service names. Contract values belong in enforcing packages with comments pointing to their documented behavior.
- Define once; reference/derive elsewhere, e.g. fmt.Sprintf for regex bounds, strconv.Itoa for string forms.
- Bare 0/1 without business meaning, standard-library parameters (net.Dial("tcp",...)) and expected contractual test values need no names.

## Package documentation

Write package documentation once, usually doc.go/main package file directly above package. Follow standard Go: begin “Package x” explaining responsibility, then blank // paragraphs for scope/exclusions/relevant behavior. Git owns author/date metadata.

```go
// Package wire 实现 Core 与 SDK 共用的协议运行时：帧编解码、传输与 Session 调用引擎。
//
// 每帧由 4 字节 big-endian 载荷长度和 Protobuf Envelope 组成，长度范围为 1～4,194,304 字节；
// TCP 与 stdio 使用相同的编码。帧格式见 protocol definitions。
package wire
```

- Other file headers omit comments: package-adjacent comments merge into godoc, and isolated file descriptions drift. File names should explain contents; unclear names usually need renaming/reorganization.
- Multi-file/type packages add a composition paragraph linking main types/entries, e.g. [Session]/[Conn], for godoc navigation/gopls rename diagnostics.
- main documentation starts with the command, e.g. “alonabot starts AlonaBot Core.”
- go:build goes first, blank line then package docs/package. Preserve cgo/go:generate directive placement.
- .proto begins with a comment before syntax describing its payloads/relevant behavior.
- Generated headers stay generator-owned; edit .proto/generator for additions.
- Workflows/scripts/configuration allowing comments get a one-line purpose header.

## Comments

### Documentation comments

Document exported types/functions/methods/constants/variables. Begin with the identifier, then behavior/guarantees and needed side effects/errors/cancellation/concurrency/zero semantics.

```go
// Budget 限制所有 Session 合计的在途载荷字节数。
type Budget struct { ... }

// Reserve 占用 n 字节；余量不足时立即返回 false，不等待。
func (b *Budget) Reserve(n int64) bool
```

Avoid definitional “X is…” and generic “this function/method/used to” openings:

```go
// Budget 是 Core 全局载荷预算。   ← 不这样写
// Reserve 是占用预算的函数。      ← 不这样写
```

Private names/signatures need no redundant comments; explain preconditions/order/nonobvious tradeoffs when present.

### Types and fields

Type comments state meaning/invariants. Field comments add hidden units/zero/default/optional/lock/ownership/lifetime meaning only; short explanations may be inline.

```go
// StopTiming 规定一次插件停用的时间预算。
type StopTiming struct {
	Drain time.Duration // 冻结新调用后，留给已有调用结束的最长时间
	Total time.Duration // 从开始停用到进程树必须结束的总时间
}

type Budget struct {
	mu   sync.Mutex
	used int64 // 已占用字节，由 mu 保护
	max  int64
}
```

### Step comments

For distinct stages, put // 1., // 2. immediately before the relevant stage to explain purpose/order. Number stages rather than statements; skip simple functions/getters/forwarders. Avoid opening tables of contents; update numbering with logic.

```go
func (s *Session) Call(ctx context.Context, req Request) (Response, error) {
	// 1. 计算有效期限：取请求期限与 ctx 期限中较早者。
	...
	// 2. 先占准入预算，不足时立即失败，不排队等待。
	...
	// 3. 等待响应；ctx 结束时先返回，再尽力通知对端取消。
	select { // 两个分支谁先到就用谁
	...
}
```

### Write for engineers with basic Go

- Briefly explain nonobvious select/channel closure/atomic/lock order/goroutine handover choices beside the code.
- Complex state machines/call engines/recovery get a multiline package/type overview: states, ownership and order. Avoid repeating it locally.
- Omit line-by-line restatements and comments on every assignment/if err/return.
- Promise only implemented concurrency/atomicity/idempotence/retry guarantees.

### Describe behavior rather than progress

Comments/errors explain current behavior/limits/reasons, without PLAN slices/goals/task numbers or implementation milestones. Say “X is not yet supported” directly. Temporary choices use shortcut: <limitation>, <replacement condition>, e.g. replace when a stable route_id generator exists. Link current guides/protocol source where relevant.

## Test submission rules

Commit only **integration tests** and **protocol-number checks**. Other tests stay local. Committed tests impose lasting maintenance costs and should guard main paths/cross-process/component failures rather than coverage breadth.

- **Integration tests** drive real collaborators through public entry points: actual plugin processes, real Session peers, SQLite/filesystems/OS locks. Repository simulators may replace external platforms (memory Adapter/local Bot API), while repository components remain real.
- **Protocol-number checks** are limited to contracts/wirespec_test.go, protecting field/enum numbers.
- **SDK-bound tests stay local**: sdk/ has no committed tests; internal/core/supervisor retains only SDK-independent supervisor_test.go. Add no testdata plugins. Use *_local_test.go and record results in PR.
- **Count**: default one main-path integration test per PR, covering required behavior/cross-process failures. Explain multiple tests in PR. Use local checks for other cases; record inputs/commands/platform/results per [development](https://github.com/AlonaBot/AlonaBot/blob/main/docs/development.md#verify-changes).
- Unit/boundary/regression/temporary tests use ignored *_local_test.go within packages. One-off scripts outside packages go in tmp/test/.
- **Frontend**: Core CI does not run frontend tests, so committed frontend tests provide no gate. Pure Schema/patch/API-format checks use ignored .local.test.ts/.local.test.tsx, matched by vitest. npm run test uses vitest run --passWithNoTests, allowing checkouts without local tests.
- Integration tests map to required behavior or V identifiers. Table-drive equivalent cases; avoid getter/constructor/obvious-branch tests.
- PRs state added committed test lines, other local checks and results. Local tests remain uncommitted, with reproducible conclusions.

## Apply and review

- New files follow all rules. Existing edits complete touched comments; repository-wide cleanup is separate from feature work.
- Tools check gofmt/build/generation. Reviewers check names/comments/test scope using these rules; passing CI alone does not establish them.
- Comment-only edits need content/format/reference checks. Verify consumers when touching tool-readable go:generate/build tags.

## Repository differences

Derived repositories should list actual dependencies and approved exceptions here, with their reasons and scope. Keep this placeholder until differences exist. Sync the rules above from Core; change shared rules in Core first.
