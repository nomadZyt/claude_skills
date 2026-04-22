---
name: zacc-wiki-fronted
description: "众安前端（zacc）— 项目拓扑 Wiki：单一入口 /zacc-wiki-fronted（或本技能）交互选择 SOP 与子命令；在 .wiki/ 生成图谱、增量更新与架构查询。可独立或与 zacc-init-fronted 配套。"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
version: "1.0.0"
tags: ["frontend", "wiki", "zacc", "wiki-fronted"]
---

> **说明**：本技能全部执行规范已合并于本 **`SKILL.md`**（不再使用单独的 `wiki/` 目录或 `WIKI.md`）。对目标项目写入的产出目录仍为 **`.wiki/`**（与技能包路径无关）。

> **配套**：若尚未生成 `CLAUDE.md` / `.claude/AI_RULES.md`，可先执行 **`zacc-init-fronted`**。

# Project Topology Wiki — AI 知识基础设施

为任意技术栈项目生成结构化的 AI 专属知识图谱，存储在 `.wiki/`，与业务代码完全解耦。

## 核心哲学

| 原则 | 说明 |
|------|------|
| 解耦记忆 | AI 的架构认知独立于业务代码，存储在 `.wiki/` |
| 机器友好 | 使用 Frontmatter + YAML 声明，抛弃散文叙述 |
| 尊重现状 | 不了解项目现况前，禁止任何破坏性修改 |
| 增量演进 | Wiki 随项目演进，只追加不覆盖历史包袱 |

## 输出文件

| 文件 | 位置 | 作用 |
|------|------|------|
| index.md | `.wiki/` | 全局拓扑索引（三层架构视图） |
| glossary.md | `.wiki/` | 项目术语表 |
| {id}-{slug}.md | `.wiki/nodes/` | 原子知识节点（每个模块一个） |
| .wiki-state.json | `.wiki/` | 增量更新状态快照 |

## 统一入口与交互分流（必读）

用户使用技能 **`zacc-wiki-fronted`** 或斜杠 **`/zacc-wiki-fronted`**。**不依赖**多个独立斜杠命令（如 ~~init / query / update 三分拆~~）；由助手在本入口完成分流。

### 何时主动询问用户

- **用户已用自然语言说清意图**（例如「首次生成 Wiki」「查支付模块上下游」「做一次 scan」「记一条 legacy」）：直接映射到对应 **SOP** 与子命令，**不必**再问一级菜单。
- **意图不明确**（例如只说「帮我弄下 Wiki」）：使用 **AskUserQuestion**（或环境支持的等价交互）展示 **一级菜单**：
  1. **初始化拓扑 Wiki** → 执行 **SOP-1**
  2. **架构感知查询** → 若尚未给出问题，请用户补充 → 执行 **SOP-3**
  3. **增量更新 / 历史包袱** → 继续展示 **二级菜单**，选项与 **SOP-2「### 子命令」** 一致：`scan` | `legacy` | `node add` | `node deprecate` | `node update` | `refresh` → 执行 **SOP-2** 对应小节

### 一级菜单与 SOP 对应

| 一级选择 | SOP | 说明 |
|----------|-----|------|
| 初始化 | **SOP-1** | 首次或全量重建 `.wiki/` |
| 查询 | **SOP-3** | 需要用户问题文本 |
| 增量更新 | **SOP-2** | **必须先选二级子命令**（见下节 SOP-2） |

---

## SOP-1：项目拓扑初始化

> **触发**：用户在一级菜单中选「初始化」，或明确表达首次生成 / 全量初始化 Wiki；若用户一句话已等价于初始化意图，可直接执行本 SOP。

### 步骤 1：项目类型检测

**参考**：`references/project-detection.md`

遍历项目根目录，按优先级检测入口文件：

| 检测文件 | 项目类型 | 语言 |
|----------|---------|------|
| `package.json` | Node.js / 前端 | JavaScript/TypeScript |
| `go.mod` | Go | Go |
| `Cargo.toml` | Rust | Rust |
| `pom.xml` | Java Maven | Java |
| `build.gradle` / `build.gradle.kts` | Java Gradle | Java/Kotlin |
| `pyproject.toml` / `setup.py` | Python | Python |
| `mix.exs` | Elixir | Elixir |
| `Gemfile` | Ruby | Ruby |
| `composer.json` | PHP | PHP |
| `*.csproj` / `*.sln` | .NET | C# |
| `CMakeLists.txt` | C/C++ | C/C++ |
| `pubspec.yaml` | Dart/Flutter | Dart |

**Monorepo 检测**：`pnpm-workspace.yaml`、`lerna.json`、`nx.json`、`turbo.json`、`go.work`、多个 `go.mod`、`pom.xml` 含 `<modules>`。

- 如检测到 Monorepo，参考 `references/monorepo-strategies.md`
- 如无法识别项目类型，用 AskUserQuestion 询问源代码目录和语言

**读取项目基本信息**：
- 项目名称（package.json name / go.mod module / pom.xml artifactId 等）
- 项目描述（README.md 首段）
- 源代码根目录（`src/`、`app/`、`lib/`、`cmd/`、`internal/`、`pkg/` 等）

**输出**：项目类型、语言、入口文件路径、是否 Monorepo、源代码根目录。

### 步骤 2：核心模块扫描

**参考**：`references/module-extraction.md`

使用 Glob 扫描源代码目录（深度 2-3 层），**不读取每个文件内容**。

**各语言模块边界定义**：

| 语言 | 扫描目录 | 模块 = |
|------|---------|--------|
| JS/TS | `src/` | 含 `index.ts/js` 的顶级子目录 |
| Java | `src/main/java/{group}/{artifact}/` | 第 3-4 层 package |
| Go | 根目录 + `cmd/` + `internal/` + `pkg/` | 同 package 声明的目录 |
| Python | `src/` 或根 package | 含 `__init__.py` 的目录 |
| Rust | `src/` | `lib.rs` / `main.rs` 中的 `mod` 声明 |

**排序并按项目规模自适应选取深度扫描范围**（参考 `references/module-extraction.md` 模块数量策略）：
1. 被引用次数（Grep import 语句）— 权重 0.5
2. 文件数量（Glob 统计）— 权重 0.3
3. Git 活跃度（`git log --since="3 months ago" --oneline -- {path} | wc -l`）— 权重 0.2

| 候选模块数 | 策略 |
|-----------|------|
| <= 10 | 全量深度扫描 |
| 11-20 | Top-10 深度，其余轻量 |
| 21-50 | 展示排名，用户选择深度扫描范围 |
| > 50 | 用户指定关注领域 |

同时识别基础模块（`utils`、`common`、`shared`、`lib`、`pkg`、`internal/common`），创建轻量节点。

**对每个深度节点模块**：
- 仅浅读入口文件（`index.ts`、`mod.rs`、`__init__.py`）
- 提取 export/public 方法和类

### 步骤 3：依赖关系提取

**参考**：`references/dependency-analysis.md`

采用**三层边模型**，分别扫描并独立统计，不合并入度：

| 层次 | 边类型 | 扫描对象 | 写入字段 |
|------|--------|---------|---------|
| 第一层 | `import` | 所有模块的静态 import/require | `dependencies` / `dependents` |
| 第二层 | `route` | 页面模块的路由跳转语句 + 路由配置文件（仅 JS/TS） | `route_to` / `route_from` |
| 第三层 | `dynamic` | 动态 `import()` 懒加载语句 | `lazy_deps` |

**第一层 — 静态 Import**：

| 语言 | Grep 模式 | 内部判定 |
|------|----------|---------|
| JS/TS | `import.*from\s+['"]` / `require\(['"]` | 以 `.` 或 `@project/` 开头 |
| Java | `^import\s+` | 匹配项目 groupId |
| Go | `import.*["(]` | 以项目 module path 开头 |
| Python | `^from\s+\S+\s+import` / `^import\s+` | 相对导入或匹配项目包名 |
| Rust | `^use\s+crate::` / `^mod\s+` | `crate::` 前缀 |

**第二层 — 路由跳转（仅 JS/TS 项目）**：
1. 先读取路由配置文件（`src/router/index.{ts,js}` 等），建立 `path → node` 映射表
2. Grep 页面目录中的所有跳转模式：
   - 框架路由：`router\.push|navigate\(|<Link.*to=|<router-link.*to=|redirect\(`
   - 原生导航：`(?:window\.)?location\.(href|replace|assign)|history\.(pushState|replaceState)|window\.open\(`
   - 原生链接：`<a\s[^>]*href=` （过滤外部链接）
3. 按 `route_type` 分类：`internal`（计入 route_in）、`internal-dynamic`（路径含变量，不计入）、`external`（忽略）
4. `internal` 类型通过路由映射表解析为节点 ID，填充 `route_to` / `route_from`

**入度分两个字段独立计算**：
- `import_in`：有多少节点的 `dependencies` 包含本节点
- `route_in`：有多少节点的 `route_to` 包含本节点

> **注意**：页面类模块（`type: page`）通常 `import_in = 0`（路由懒加载不产生静态 import），需靠 `route_in` 反映其业务重要性。不能因 `import_in = 0` 就判断该模块不重要。

仅对 `import` 关系执行循环依赖检测（路由环是正常业务逻辑，不标注）。

### 步骤 4：生成节点文件

**模板**：`templates/wiki-node.md.tpl`

为每个模块生成 `.wiki/nodes/{YYYYMMDD-HHMMSS}-{slug}.md`。

> **性能关键：必须并行写入，禁止逐个串行。**

**执行策略**：

1. **先收集，后批量写入** — 步骤 1-3 的扫描和分析完成后，在内存中准备好所有节点的内容，然后在**一次响应中发起所有 Write 调用**（Claude Code 支持单消息多工具并行调用）
2. **分批上限**：单轮最多并行写入 **8 个文件**。如果节点超过 8 个，分 2-3 轮写入，每轮 Write 完成后立即进入下一轮
3. **轻量节点更轻** — 轻量节点只生成 frontmatter + 概述（一句话），不生成公开接口/依赖关系/关键文件等章节，控制每个文件在 15 行以内

**节点元数据契约**：

```yaml
---
id: "20260413-143052"
type: page                      # module | api | page | logic | legacy | foundation | config
title: "结账页面"
path: "src/pages/checkout"
language: "TypeScript"
dependencies:
  - "[[20260413-143053]]"       # import: auth-module
dependents:
  - "[[20260413-143058]]"       # import: api-controller
route_to:
  - "[[20260413-140009]]"       # route → pages/orderResult
route_from:
  - "[[20260413-140005]]"       # route ← pages/cart
lazy_deps:
  - "[[20260413-143060]]"       # dynamic: heavy-chart-module
exports:
  - "CheckoutPage"
import_in: 0                    # 静态 import 入度（页面类通常为 0）
route_in: 8                     # 路由跳转入度（业务使用频率）
status: active                  # active | deprecated
last_scanned: "2026-04-13T14:30:52+08:00"
---
```

**深度节点正文结构**（6 个章节）：
1. **概述** — 一句话描述模块职责
2. **公开接口** — 导出的函数/类/方法表格（名称、签名、说明）
3. **依赖关系** — 邻域图 + 上下游表格，每个 `[[id]]` 链接附用途说明
4. **关键文件** — 重要文件列表及其角色
5. **设计决策** — 可从注释/文档推断的设计选择
6. **历史包袱 (Legacy Constraints)** — 初始为空，由 SOP-2 填充

**轻量节点正文结构**（2 个章节，控制在 15 行内）：
1. **概述** — 一句话描述
2. **文件列表** — 仅列出文件名，不分析内容

### 步骤 5：生成全局拓扑索引（含知识图谱）

**模板**：`templates/wiki-index.md.tpl`

生成 `.wiki/index.md`，包含以下内容：

1. **YAML frontmatter**：项目名、类型、语言、时间戳、节点数、Monorepo 标记

2. **概念层次图 (Concept Hierarchy)**：使用 Mermaid `graph TD` 生成分层架构图
   - 用 `subgraph` 将模块按层级分组（入口层 / 业务层 / 基础层）
   - 每个模块作为一个节点，节点 ID 使用 Wiki 节点 ID
   - 层级之间用箭头连接表示调用方向

3. **模块依赖关系图 (Entity Relationship Graph)**：使用 Mermaid `graph LR` 生成依赖网络图
   - 每个模块节点显示名称 + 路径
   - 箭头 = 依赖方向（A → B 表示 A 依赖 B），标注依赖用途
   - 用 `classDef` 按层级着色（蓝=入口, 绿=业务, 橙=基础, 红虚线=废弃），并设置 `color:#000000` 保证节点文字为黑色（避免部分渲染器在暗色主题下将文字显示为白色）
   - 实线 = 同层依赖，虚线 = 跨层依赖

4. **依赖热力矩阵**：用表格展示模块间的依赖关系矩阵
   - 行 = 调用者，列 = 被调用者，`●` = 存在依赖
   - 计算每个模块的**入度**（被依赖数）和**出度**（依赖数）
   - 入度高的是核心支撑模块，修改影响范围大

5. **分层架构视图 (Text)**：纯文本树形展示，作为 Mermaid 图谱的备用

6. **模块关系总表**：ID | 名称 | 类型 | 路径 | 上游 | 下游 | 入度 | 出度 | 状态

7. **快速导航**：按类型分组 + 核心枢纽模块（入度 >= 3）+ 有历史包袱的节点

**Mermaid 图谱生成规则**：
- 节点 ID 使用简化格式（去掉时间戳中的 `-`，如 `M20260413143052`）避免 Mermaid 语法冲突
- 节点标签用 `("名称<br/><small>路径</small>")` 格式，兼顾可读性
- 超过 15 个模块时，依赖关系图只展示深度节点，轻量节点省略
- 循环依赖用红色粗线标注：`A =="循环"==> B`

### 步骤 6：生成术语表

**模板**：`templates/wiki-glossary.md.tpl`

从模块名、类名、核心方法名提取领域术语。生成 `.wiki/glossary.md`：

| 术语 | 定义 | 对应代码实体 | 所属模块 |
|------|------|------------|---------|

### 步骤 7：保存状态并输出结果

**生成 `.wiki/.wiki-state.json`**：

```json
{
  "version": "1.0",
  "project_type": "node-typescript",
  "language": "TypeScript",
  "last_full_scan": "2026-04-13T14:30:52+08:00",
  "scanned_dirs_hash": "{sha256}",
  "node_count": 8,
  "nodes": [
    { "id": "20260413-143052", "slug": "user-service", "path": "src/services/user", "entry_file_hash": "{sha256}" }
  ]
}
```

**检查 CLAUDE.md 并追加 Wiki 规则**：

如果目标项目存在 `CLAUDE.md`，用 Edit 追加以下章节：

```markdown
## 项目拓扑 Wiki

### 规则
- 修改任何模块前，必须先查阅 `.wiki/index.md` 了解模块关系
- 发现代码中的历史包袱或逻辑矛盾时，通过 **`/zacc-wiki-fronted`**（或技能 **zacc-wiki-fronted**）选择「增量更新 → **legacy**」记录
- 不得忽略 Wiki 节点中的 Legacy Constraints

### 命令
- 使用 **`/zacc-wiki-fronted`** 或技能 **`zacc-wiki-fronted`**：按交互选择 **初始化 / 查询 / 增量更新**；选「增量更新」时再选 **子命令**（与技能包 `SKILL.md` 中 **SOP-2「### 子命令」** 一致）。

### 文件位置
- Wiki 索引：`.wiki/index.md`
- Wiki 节点：`.wiki/nodes/`
- 术语表：`.wiki/glossary.md`
```

**输出结果**：

```
✅ 项目拓扑 Wiki 初始化完成

📊 项目分析结果：
- 项目名称：{name}
- 项目类型：{type}
- 语言：{language}
- Monorepo：{yes/no}

📦 识别的核心模块：
- {module1} ({path1})
- {module2} ({path2})
- ...

📄 已生成文件：
- .wiki/index.md — 全局拓扑索引
- .wiki/glossary.md — 术语表
- .wiki/nodes/{id}-{slug}.md × {N} — 知识节点
- .wiki/.wiki-state.json — 状态快照

🔗 依赖关系摘要：
- 内部依赖：{N} 条
- 循环依赖：{N} 处（如有）

💡 下一步：
- 查看 .wiki/index.md 了解项目全貌
- 使用 **`/zacc-wiki-fronted`** 选「查询」并描述问题，进行架构感知查询
- 开发过程中发现技术债：使用 **`/zacc-wiki-fronted`** 选「增量更新 → **legacy**」记录
```

---

## SOP-2：增量更新与冲突记录

> **触发**：用户在一级菜单中选「增量更新」并已选定下方 **子命令**；或用户自然语言已等价于某一子命令（如「scan 一下」「记 legacy」）。项目变更后、发现逻辑矛盾时，通常对应 **scan** 或 **legacy**。

### 前置检查

读取 `.wiki/.wiki-state.json`。如不存在，提示用户先通过 **`/zacc-wiki-fronted`** 完成 **SOP-1（初始化）**。

### 子命令

#### `scan` — 增量扫描

**用法（子命令 `scan`）**：在统一入口中选「增量更新」→「scan」；无额外必选参数时直接执行下列步骤。

1. 重新生成目录结构 hash，与 `.wiki-state.json` 中的 `scanned_dirs_hash` 对比
2. 检测：新增目录（潜在新模块）、删除目录（废弃模块）、入口文件变更
3. **仅对变更模块**：重新执行模块提取和依赖分析
4. 更新对应节点文件（**保留** 历史包袱章节不动）
5. 重新生成 `index.md` 模块关系表
6. 更新 `.wiki-state.json`

#### `legacy` — 记录历史包袱

**核心原则：绝不修改节点已有内容，只追加 Legacy Constraints 章节。**

**用法（子命令 `legacy`）**：在统一入口中已选「增量更新」→「legacy」后，提供节点与约束，例如参数形式 `--node {id或名称} --constraint "描述"`（若对话式交互，可分步向用户收集）。

**模板**：`templates/wiki-legacy-section.md.tpl`

在节点的 `## 历史包袱 (Legacy Constraints)` 章节追加：

```markdown
### LC-{number}: {constraint_title}
- **Current_State**: {代码的实际行为}
- **Do_Not_Touch**: {禁止修改的部分及原因}
- **Context**: {历史原因/业务背景}
- **Severity**: {Info|Warning|Critical}
- **Recorded**: {YYYY-MM-DD}
- **Reporter**: {AI|User}
```

**AI 自动建议场景**（在编码过程中，AI 检测到以下信号时应建议记录）：

| 信号 | 示例 |
|------|------|
| TODO/FIXME/HACK 注释 | `// HACK: bypass auth for legacy clients` |
| 版本兼容代码 | `legacyUserService`、`v1Compat` |
| 注释与代码行为矛盾 | 注释说"不可能为空"但代码做了空判断 |
| 同一逻辑多套实现 | `/v1/users` 和 `/v2/users` 共存 |
| 强制保留注释 | `DO NOT MODIFY`、`DO NOT DELETE`、`KEEP THIS` |

检测到这些信号时，用 AskUserQuestion 确认后记录。

#### `node add` — 新增节点

**用法（子命令 `node add`）**：`--path {path}`（在对话中可由用户指定目录）

对指定目录执行模块扫描，创建新节点文件，更新 index.md 和 .wiki-state.json。

#### `node deprecate` — 废弃节点

**用法（子命令 `node deprecate`）**：`--id {id}`

将节点 status 设为 `deprecated`，添加废弃说明，更新 index.md。

#### `node update` — 重新扫描节点

**用法（子命令 `node update`）**：`--id {id}`

重新读取入口文件，更新 exports 和 dependencies（保留历史包袱章节）。

#### `refresh` — 全量重建

**用法（子命令 `refresh`）**：全量重建（保留历史包袱），无额外必选参数时与用户确认即可

重新执行 SOP-1 全部步骤，但：
1. 读取所有现有节点的 `## 历史包袱 (Legacy Constraints)` 章节
2. 全量重建后，将历史包袱回写到对应新节点（按 path 匹配）
3. 无法匹配的历史包袱归入 `index.md` 的"孤立历史包袱"章节

---

## SOP-3：架构感知查询

> **触发**：用户在一级菜单中选「查询」并已提供（或补充）具体问题；或用户自然语言已等价于架构问答（如「支付模块上下游有哪些」）。

### 硬规则（不可违反）

1. **禁止** 未读 Wiki 直接读 `src/` 给出修改建议
2. **必须** 先读 `.wiki/index.md`
3. **必须** 追踪上下游依赖至少一层
4. **必须** 合并相关节点的 Legacy Constraints 到回答中

### 步骤 1：加载 Wiki 索引（强制）

读取 `.wiki/index.md`。如 `.wiki/` 不存在，提示先通过 **`/zacc-wiki-fronted`** 执行 **SOP-1（初始化）**。

### 步骤 2：定位相关节点

将用户问题的关键词与以下字段匹配：
- 节点 `title`
- 节点 `path`
- 节点 `exports`
- 术语表 `glossary.md` 中的术语

读取匹配到的节点文件。

### 步骤 3：追踪上下游（强制）

读取匹配节点的 `dependencies` 和 `dependents`。加载邻居节点，理解影响范围。

至少追踪一层。如涉及 foundation 模块（被多模块依赖），需评估全局影响。

### 步骤 4：合并历史包袱（强制）

检查目标节点及其所有邻居节点的 `## 历史包袱 (Legacy Constraints)` 章节。

如存在任何历史包袱，**必须**在回答中明确提醒。

### 步骤 5：输出查询结果

```
🔍 架构感知查询结果

📦 相关模块：
| 模块 | 关系 | 路径 |
|------|------|------|
| {target} | 目标 | {path} |
| {upstream} | 上游依赖 | {path} |
| {downstream} | 下游消费 | {path} |

🔗 依赖影响图：
  {upstream-1} ──→ [目标模块] ──→ {downstream-1}
  {upstream-2} ──↗             ╲──→ {downstream-2}

⚠️ 历史包袱提醒：
- LC-1 ({node}): {constraint} [Severity: Critical]
- LC-2 ({node}): {constraint} [Severity: Warning]

💡 修改建议：
- {具体建议，尊重依赖关系和历史包袱}

📝 需要同步修改的文件：
- {file1} — {原因}
- {file2} — {原因}

💥 影响范围：{N} 个模块，{N} 个文件
```

---

## 节点元数据契约

所有 `.wiki/nodes/` 下的文件**必须**包含以下 Frontmatter：

```yaml
---
id: "{YYYYMMDD-HHMMSS}"              # 唯一标识（生成时间戳）
type: "{type}"                        # module | api | page | logic | legacy | foundation | config
title: "{String}"                     # 简短模块名称
path: "{Relative_Path}"              # 对应的源代码路径（相对于项目根）
language: "{Language}"                # 编程语言
dependencies:
  - "[[{ID}]]"                        # import 上游依赖节点
dependents:
  - "[[{ID}]]"                        # import 下游消费节点
route_to:
  - "[[{ID}]]"                        # 路由跳转目标（仅前端 page 类型）
route_from:
  - "[[{ID}]]"                        # 路由跳转来源（仅前端 page 类型）
lazy_deps:
  - "[[{ID}]]"                        # 动态 import() 懒加载依赖
exports:                              # 公开接口列表
  - "{function_or_class_name}"
import_in: {N}                        # 被多少模块静态 import（代码耦合入度）
route_in: {N}                         # 被多少页面路由跳转到（业务使用入度，page 类型专用）
status: "{status}"                    # active | deprecated
last_scanned: "{ISO-8601}"           # 最后扫描时间
---
```

> **page 类型说明**：路由懒加载的页面组件不会被其他模块 import，`import_in` 通常为 0，**不代表该模块不重要**。应以 `route_in` 判断页面的业务使用频率。

---

## 性能优化策略

| 策略 | 说明 |
|------|------|
| 浅扫描优先 | 步骤 2 只 Glob 目录结构，不读文件内容 |
| 入口文件法 | 只读 index.ts/mod.rs/__init__.py，不遍历所有源码 |
| Grep 替代 AST | 用正则匹配 import，不做完整语法分析 |
| 动态分层 | 按项目规模自适应深度扫描范围，小项目全量，大项目用户选择 |
| 增量更新 | .wiki-state.json 记录快照，只处理差异 |
| 深度限制 | 目录扫描深度 2-3 层 |
| **并行写入** | **所有节点文件在同一轮工具调用中并行写入，禁止逐个串行** |
| **分批上限** | **单轮最多 8 个文件并行写入，超过则分 2-3 轮** |
| **轻量节点精简** | **轻量节点只有 frontmatter + 概述，控制 15 行内** |

### 执行顺序优化（防卡死）

整个 SOP-1 分为 **3 个阶段**，每个阶段内并行执行，阶段之间顺序执行：

**阶段 A — 扫描分析（只读，不写文件）**：
1. 步骤 1：项目类型检测（Glob + Read 配置文件）
2. 步骤 2：核心模块扫描（Glob + Grep + Read 入口文件）
3. 步骤 3：依赖关系提取（Grep import 语句）

**阶段 B — 批量生成文件（并行写入）**：
4. 步骤 4：并行写入所有节点文件（每批 <= 8 个）
5. 步骤 5：写入 index.md（含 Mermaid 图谱）
6. 步骤 6：写入 glossary.md
7. 步骤 7：写入 .wiki-state.json

> 步骤 4 的节点文件 + 步骤 5/6/7 的索引文件应在**同一批或相邻两批**内全部完成。

**阶段 C — 收尾（轻量操作）**：
8. 如有 CLAUDE.md 则 Edit 追加 Wiki 规则
9. 输出结果摘要

## 边界场景处理

| 场景 | 策略 |
|------|------|
| 空项目 | 只创建 index.md，标注"项目为空" |
| 超大 Monorepo（>50 子包） | 用 AskUserQuestion 让用户选 1-3 个子包 |
| 无法识别项目类型 | 用 AskUserQuestion 询问源目录和语言 |
| `.wiki/` 已存在 | 询问：增量更新 / 全量重建 / 取消 |
| 无法读取的文件 | 跳过，在节点中标注"信息不完整" |
| 候选模块 > 20 个 | 展示排名列表让用户选择深度扫描范围，其余创建轻量节点 |

## 与现有 Skill 协作

| 现有 Skill | 协作方式 |
|-----------|---------|
| `zacc-init-fronted` | Wiki 与前端初始化互补：CLAUDE.md / AI_RULES.md 与 Legacy Constraints 协同 |

---

## 参考文件

- `references/project-detection.md` — 多语言项目类型检测策略
- `references/module-extraction.md` — 核心模块提取算法
- `references/dependency-analysis.md` — 依赖关系分析方法
- `references/legacy-constraint-patterns.md` — 历史包袱识别模式
- `references/monorepo-strategies.md` — Monorepo 处理策略

---

## 完成输出（示例）

```
📊 项目拓扑 Wiki 已生成

📦 识别的核心模块：{N} 个深度节点 + {N} 个轻量节点
🔗 内部依赖：{N} 条
📄 文件：.wiki/index.md + .wiki/nodes/ × {N}

💡 触发方式：
- 使用技能 **zacc-wiki-fronted** + 自然语言（由环境决定是否映射为 **`/zacc-wiki-fronted`** 等入口）
- 由助手按 **统一入口** 询问：初始化 / 查询 / 增量更新 → 增量更新时再选 **子命令**

💡 建议：
- 检查生成内容是否准确
- 发现历史包袱时使用增量更新并记录 Legacy Constraints
```
