# AlonaBot 编码规范

[English](https://github.com/AlonaBot/AlonaBot/blob/main/docs/coding-standards.md)

本文是 Core、SDK、协议与示例代码的编码和测试提交规则，PR 审查按本文检查。贡献流程见[贡献指南](https://github.com/AlonaBot/AlonaBot/blob/main/CONTRIBUTING.zh-CN.md)，模块边界见[架构地图](https://github.com/AlonaBot/AlonaBot/blob/main/ARCHITECTURE.md)。

## 风格基线

- Go 代码遵循 [Google Go Style Guide](https://google.github.io/styleguide/go/)，包括 [Style Decisions](https://google.github.io/styleguide/go/decisions) 和 [Best Practices](https://google.github.io/styleguide/go/best-practices)。可用时加载 `go-google-style-guide`、`go-google-style-decisions` 和 `go-google-best-practices` 技能。
- 注释遵循 `code-commenting` 技能的原则：只写名字和结构表达不出来的东西，多阶段流程写 step 注释。本文件与上述资料冲突时，以本文件为准，主要差异是注释用简体中文。
- 代码要让只有 Go 基础的工程师也能读懂：清楚优先于简短，不炫技，不为将来可能的需求预留抽象。
- 使用 `go.mod` 指定的 Go 版本和 `gofmt`。

## 命名与术语

名字沿用指南和协议定义中的领域术语，让读代码的人能对上文档中的概念。

| 术语 | 含义 |
| --- | --- |
| Core / 插件（Plugin） | 宿主进程 / 独立进程运行的插件 |
| Adapter、Adapter 实例（Instance） | 平台适配器 / 一个已配置的平台账号接入 |
| Session | Core 与一个插件进程之间的一次认证连接 |
| Generation（代次） | 插件程序、配置与数据的一次已提交组合 |
| Target、Actor | 发送目标 / 事件触发者，定义见 [identity.proto](https://github.com/AlonaBot/AlonaBot/blob/main/contracts/proto/alonabot/v1/identity.proto) |
| Route、Handler、Hook | 插件注册的路由 / 处理函数 / 收发前后的拦截点 |
| MessageChain、Segment | 一次逻辑发送的消息 / 其中的片段 |
| MediaRef、IncomingMedia、Grant | 已上传媒体的引用 / 入站媒体描述 / 签发给其他 Session 的读权限 |
| Pending、Active | 待激活的配置或代次 / 当前生效的代次 |
| Budget、Deadline | 准入字节预算 / 绝对截止时刻 |

- 新概念先在相关指南或协议定义中确定名字，再进入代码。同一个概念在全项目只用一个名字，不混用同义词。
- 不用含糊的通用词做名字或后缀：`Kind`、`Type`（作为万能区分字段时）、`Info`、`Data`、`Item`、`Object`、`Manager`、`Helper`、`Util`、`Common`、`Misc`、`Impl`。改用说明具体角色的词，例如 `Phase`、`Mode`、`Source`、`Status`、`Registry`、`Store`。
- 不用缩写，`Deps`、`Cfg`、`Mgr`、`Svc`、`Msg`、`Req`、`Resp`、`Tmp`、`Val` 都写完整单词。Go 惯例的短名不受此限：只在几行内使用的局部变量（如 `ctx`、`err`、`ok`、`i`、`n`、`msg`、`req`、`env`），以及一两个字母的方法接收者。字段、导出符号和作用域较大的变量仍写完整单词。`ID`、`URL`、`HTTP` 等首字母缩写词保持全大写。
- 包名用简短的小写名词，不用 `util`、`common`、`base`、`types` 这类包名。
- 协议生成的名字（如 `pb.FrameKind`、`pb.RouteKind`）以 [Protobuf 定义](https://github.com/AlonaBot/AlonaBot/blob/main/contracts/proto/alonabot/v1) 为准，不在 Go 代码里另起别名；新写的 Go 类型不再沿用这种 `Kind` 后缀。

## 按职责分文件

- 先确定语义所有者，再决定包与文件。类型、方法、校验和专属常量放在一起；大类型可按入站、出站、存储等真实操作拆文件。
- 协议载荷按完整主题集中，例如调用、注册、消息。含 mutex、channel、连接或生命周期状态的结构体属于实现，不是共享的数据类型。
- 不建跨领域的 `dto.go`、`types.go`、`constants.go`、`utils.go`，也不要求一个类型一个文件。
- 不按行数拆分文件。判断标准是：改一个操作需要跳转多少文件、状态是否仍有唯一所有者、调用者是否更容易用对。

## 只在边界做检查，不做防御性编程

- 校验只放在信任边界：协议输入、插件提交的数据、用户配置、文件系统和外部平台的响应。包内部和包之间的调用信任类型与前置条件，不重复判空，不为不可能发生的情况写降级或兜底分支。
- 优先使用具体类型、标准库和已有实现。只在真实的消费边界定义小接口；不为每个实现、每个测试或将来的需求创建接口、选项或包装层。
- 需要取消的函数以 `context.Context` 为第一个参数并向下传递。每个 goroutine、连接、锁和临时文件都要有明确的所有者和结束路径。
- 用 `%w` 保留错误链，只在有处理权的那一层记录错误。部分成功的结果与错误一起返回，不伪造空成功。
- 限额、超时、重试、截断和降级必须有契约要求或可复现的故障依据。新依赖要先说明必要性和替代方案，取得维护者同意后才加。
- `cmd/alonabot` 只负责解析参数和装配；协议、数据库和进程逻辑留在各自的包里。

## 日志用默认 Logger，依赖显式传递

Core 进程只有一个日志出口，使用 Go 标准库 `log/slog`，字段、格式和级别见[日志说明](https://github.com/AlonaBot/AlonaBot/blob/main/docs/management-api.zh-CN.md#core-设置与-http-入口)。

- 每条日志正文写成可独立读懂的句子，DEBUG 也遵循同一规则：明确组件或路由、动作和结果，失败或状态变化时交代原因。结构化字段用于筛选与 Trace 关联，阅读正文就能理解发生了什么。例如写 `Component rollpig changed from ACTIVE to QUIESCING: idle timeout`，避免只写泛化的状态变化标题再附字段。摘要遵守消息正文、凭据等敏感信息的保护规则。
- `cmd/alonabot` 在 `logging.Open` 成功后立即调用 `slog.SetDefault(out.Logger())`，然后再构造 Core 组件。`internal/core` 下的包在记录处调用 `slog.Info`、`slog.Warn`、`slog.Error`、`slog.With` 等包函数；不在构造函数、结构字段或包级变量里保存 `slog.Default()` 或它的 `With` 结果。
- 不为日志新增构造参数、Options 字段、结构字段或 context 值。组件进程的日志使用 SDK 设置的默认 Logger。
- 以下依赖继续显式传递：
  - 有状态、按 `data_dir` 区分的 `*state.Store`、`*adapter.Registry`、`*router.Router`、`*policy.Policy` 及各包的 Limits：它们属于具体的 Core 实例，状态与限额需要随该实例装配。
  - `*wire.Budget`：`internal/wire` 由 Core 与 SDK 共用，插件侧为 nil，库模式下两边在同一进程，显式参数区分各自的预算归属。
  - 需要在测试中推进时间的时钟（构造参数 `now` 或 `Options.Now`）：测试需要控制同一被测实例的时间。
  - `supervisor.Spec.Log`：它接收单个插件进程的输出，按该进程绑定来源与会话，保留独立的输出回调。
- 测试需要读取 Core 日志时，在构造被测对象之前用 `slog.SetDefault` 指向捕获用的 Handler，并用 `t.Cleanup` 恢复原值；这类测试不调用 `t.Parallel`。

<a id="首次发布前不写兼容层"></a>

## 版本与兼容性

v0.1.0 是首个正式发行的接口与状态库基线。发布后的数据迁移和公开接口变更按以下规则维护：

- Core 状态库（`state.sqlite`）的已发布迁移保持不变，包括 `internal/core/state/schema.sql`。新增表、列或约束放入新的 SQL 迁移，追加到 `migrations`，同时验证从上一发行版本升级时数据保留，以及全新建库的最终结构。
- 修改内部函数签名、结构字段或其语义时，同一次改动更新全部调用方；公开 SDK、协议或组件行为的变更在 changelog 中说明版本影响和升级方法。
- 兼容措施须对应已发布的调用方或数据格式；保留既有错误处理和数据含义，不用零值重新解释已有接口。
- 插件受管 SQLite 的迁移接口按契约维护；配置没有版本与迁移。生成文件由源文件和生成器维护。

## Core 状态库不写 SQL

Core 状态库（`internal/core/state`）经 GORM 读写，业务的增删改查不写 SQL 文本，也不写 `Where("plugin_id = ?", id)` 这类字符串条件。

- 表名用单数名词的 snake_case，一行表示一个对象，例如 `install`、`pending_config`、`conversation_entry`；关联两个对象的表用两者的名字相连，例如 `plugin_adapter_permission`。模型类型用 `TableName` 指向表名，列名写在 `column` 标签里。
- 等值条件不写字段名或列名。单主键表用 `Where(clause.Eq{Column: clause.PrimaryColumn, Value: id})`，主键为空串时同样精确匹配；按复合主键删除时让目标结构体带上主键值，例如 `Delete(&adapterPermission{PluginID: p, AdapterInstanceID: i})`；只按部分列匹配时用结构体条件，例如 `Where(&conversationEntry{PluginID: p, ConversationKey: k})`，不在后面追加 `"PluginID"` 这类字段名参数。
- 结构体条件忽略零值字段。全部字段为零时 GORM 拒绝执行，只有部分字段为零时条件会被放宽，删除时会删掉多余的行；目标结构体只带主键值、主键又为空时，`Take` 不加条件，会读到任意一行。可能为空的条件字段在入口校验非空；需要按零值匹配的条件不用结构体表达。
- 按主键覆盖写入用 `clause.OnConflict{UpdateAll: true}`，重复插入时不做事用 `clause.OnConflict{DoNothing: true}`，不列出冲突列和更新列。
- 更新在事务内按主键读出行，在 Go 中检查条件（例如「尚未提交」），修改字段后 `Save`；不用结构体 `Updates` 写 false、0 等零值。全表更新用 `Session(&gorm.Session{AllowGlobalUpdate: true})`，不写 `Where("1 = 1")`。
- 范围条件、排序与取最大值用 `clause` 结构（`clause.Gte`、`clause.OrderByColumn` 等），列名写成包内常量；取最大值按该列降序取一行，不写 `max()`、`coalesce()`。能在 Go 中完成的排序与聚合不写进查询。不引入 GORM CLI 等查询代码生成工具。
- DDL 不写在 Go 代码里。建表、索引等语句放在包内的 `*.sql` 文件中，用 `//go:embed` 读入后执行；初始迁移即 `internal/core/state/schema.sql`。测试为构造异常文件临时建的表不在此列。
- PRAGMA 回读与打开前的只读预检属于连接管理，可以在 Go 代码里写 SQL。
- 只约束 Core。插件经 `sdk/sqlitedb` 使用 `database/sql` 是面向插件作者的产品功能，官方插件按[插件开发规范](https://alonabot.github.io/docs/develop/rules)选择入口。

## 程序输出用英文

- 日志、错误字符串、CLI 输出、panic 消息、测试失败消息，以及协议中的 safe_message 一律用英文。错误字符串按 Go 惯例小写开头、不加句号，用 `%w` 包装时前面写清正在做什么，例如 `open SQLite: %w`。
- 面向最终用户的文字（WebUI 界面、机器人发给用户的回复）不写在代码里，通过 i18n 词典提供，源语言为英文，另附简体中文。
- 代码注释与内部维护说明用简体中文。用户使用与开发指南提供中英内容，短页可以同页并列两语。

## 不写魔法值

- 有含义的数值和字符串写成命名常量，例如长度、上限、超时、退出码、文件名、地址和服务名。契约规定的值放在负责执行它的包里，注释注明规格出处。
- 同一个值只定义一次。别处需要时引用常量，或从它推导（例如正则里的长度上限用 `fmt.Sprintf` 生成，字符串形式用 `strconv.Itoa` 生成），不再写一遍字面量。
- 不需要命名的：0、1 这类不带业务含义的值，标准库约定的参数（如 `net.Dial("tcp", ...)`），以及测试中用来断言契约值的期望值。

## 包文档

每个包只在一个文件里写包文档：通常是 `doc.go` 或包的主文件，紧贴 `package` 那一行。写法参照 Go 标准库：第一句以 `Package x` 开头说清这个包做什么；再空一行（`//`）分段写使用范围、不负责什么，以及对应的规格条款。不写维护者、创建日期这类元信息，它们由 Git 记录。

```go
// Package wire 实现 Core 与 SDK 共用的协议运行时：帧编解码、传输与 Session 调用引擎。
//
// 每帧由 4 字节 big-endian 载荷长度和 Protobuf Envelope 组成，长度范围为 1～4,194,304 字节；
// TCP 与 stdio 使用相同的编码。帧格式见 docs/development.md 的协议与会话行为。
package wire
```

- 其他文件开头不写注释：紧贴 `package` 的注释会被 Go 并进包文档，单独的文件说明也容易随重构过期。文件名要让人一眼看出内容；一个文件需要靠注释才说得清，通常说明它该改名或调整拆分。
- 有多个文件或多个主要类型的包，在包文档里加一段「包的组成」，用文档链接（如 `[Session]`、`[Conn]`）列出主要类型和入口，读者可以在 godoc 中直接跳转，改名时 gopls 也会提示链接失效。
- `main` 包的包文档以命令名开头，例如「alonabot 命令启动 AlonaBot Core。」
- 有 `//go:build` 时，build tag 放在第一行，空一行后再写包文档或 `package`。cgo 注释和 `//go:generate` 等指令保留原来的位置。
- `.proto` 文件在 `syntax` 之前用一段注释说明这个文件定义了哪些载荷，以及对应的规格条款。
- 生成的文件保留生成器写的头部，不手工补写；要补充说明就改 `.proto` 或生成器。
- 其他可以写注释的文件（工作流、脚本、配置）在顶部用一行注释说明用途。

## 注释

### 文档注释

导出的类型、函数、方法、常量和变量都写文档注释。注释以标识符开头，后面紧跟它做什么、保证什么，必要时写清副作用、错误、取消、并发和零值的含义。

```go
// Budget 限制所有 Session 合计的在途载荷字节数。
type Budget struct { ... }

// Reserve 占用 n 字节；余量不足时立即返回 false，不等待。
func (b *Budget) Reserve(n int64) bool
```

不要写成「X 是……」的定义句，也不要用「该函数」「此方法」「用于」这类开头：

```go
// Budget 是 Core 全局载荷预算。   ← 不这样写
// Reserve 是占用预算的函数。      ← 不这样写
```

私有函数和方法在名字与签名已经说清楚时不必写注释；有前置条件、调用顺序要求或不明显的取舍时再写。

### 类型与字段

类型注释写它代表什么，以及使用者必须遵守的不变量。字段只在名字和类型看不出含义时才写注释，例如单位、零值或缺省的意义、可选性、由哪把锁保护、所有权和生命周期。短说明可以放在字段同一行的末尾。

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

### step 注释

函数里有几个明确的阶段时，在每段逻辑前用 `// 1. ...`、`// 2. ...` 写出这一段的目的或顺序要求。编号的是阶段，不是语句；简单函数、getter 和转发函数不编号。注释紧贴它描述的代码段，不在函数开头写一份目录；调整逻辑时同步改编号。

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

### 让基础工程师读得懂

- 用到 `select`、channel 关闭、`sync/atomic`、锁的先后顺序、goroutine 交接等写法时，在旁边用一行注释说明为什么这样写。
- 状态机、调用引擎、恢复流程这类特别复杂的模块，在包文档或类型注释里用一段多行注释讲清整体模型：有哪些状态、谁拥有什么、按什么顺序发生。之后的局部注释就不必重复。
- 不逐行复述代码，不给每个赋值、`if err != nil` 或 return 加注释。
- 不承诺代码没有提供的保证，例如线程安全、原子性、幂等或可重试。

### 写现状，不写进度

注释和错误消息只写代码当前的行为、限制和原因，不写 PLAN 工作包、切片、goal 或 task 编号，也不写「某阶段实现」「后续补齐」这类进度。尚未支持的能力直接写「尚不支持 X」。临时实现用 `shortcut: <限制>，<替换条件>` 的形式，替换条件写成条件，例如「有稳定 route_id 生成器后替换」。引用现行指南或协议源文件中的具体定义。

## 测试提交规则

仓库里只提交**集成测试**和**协议编号检查**；其余测试在本地写、本地跑，不提交。提交的测试是长期的维护成本，只用来守住主路径和跨进程、跨组件才会暴露的失败，不追求覆盖面。

- **集成测试**通过组件的公开入口驱动真实的协作方，例如真实的插件进程、两端都是真实代码的 Session 连接、真实的 SQLite、真实的文件系统和系统锁。外部平台可以用仓库提供的模拟服务替代（例如内存 Adapter、本地 Bot API 模拟服务），但不能用假实现替换仓库里的其他组件。
- **协议编号检查**只有 `contracts/wirespec_test.go`，用来防止误改协议字段号和枚举值。
- **不提交绑定 SDK API 的测试**：`sdk/` 不提交测试；`internal/core/supervisor/` 只保留 `supervisor_test.go`，其中不依赖 SDK API；不新增 `testdata` 测试插件。这些验证写在 `*_local_test.go`，结果写进 PR。
- **数量**：一个 PR 默认只提交一个覆盖主路径的集成测试，场景只放规格要求的主路径和只有跨进程才会暴露的失败。多列测试时，在 PR 正文写明理由。其余分项用本地测试取证，按[开发指南](https://github.com/AlonaBot/AlonaBot/blob/main/docs/development.zh-CN.md#验证改动)记录实际输入、命令、平台与结果。
- 单元测试、边界穷举、回归复现和临时测试，写在包目录下以 `_local_test.go` 结尾的文件里。这类文件已被 `.gitignore` 忽略，写多少都可以，不会被提交。不在 Go 包内的一次性脚本放在 `tmp/test/`。
- **前端**：CI 不跑前端，提交的前端测试没有门禁。纯函数的测试（Schema 解析、patch 构造、API 客户端的请求格式）写在以 `.local.test.ts` 或 `.local.test.tsx` 结尾的文件里，它们已被 `.gitignore` 忽略，vitest 的默认匹配也能运行它们。`npm run test` 使用 `vitest run --passWithNoTests`，没有本地测试的检出也能通过。
- 提交的集成测试要对应规格中的行为或 V 编号：同类情况合并成表驱动测试，不为 getter、构造函数或显而易见的分支写测试。
- PR 正文写明提交的测试新增了多少行、本地还跑了哪些测试和结果；本地测试不提交，但结论要能复述。

## 如何应用和审查

- 新增文件完整遵守以上规则。修改已有文件时，补齐本次触及部分的注释；全库补齐是独立任务，不夹带在功能改动里。
- `gofmt`、编译和生成一致性由工具检查；命名、注释和测试范围由审查者按本文件与 上文注释规则 检查。CI 通过不代表这些规则自动满足。
- 只改注释时，检查内容、格式和引用即可。涉及 `go:generate`、build tag 等会被工具读取的注释时，验证实际的使用方。

## 本仓差异

派生仓库在此列出实际依赖及已批准的规范例外，并注明原因与适用范围；尚无差异时保留本说明。规则正文同步自 Core，统一规则先在 Core 修改。
