---
name: zacc-init-wiki-fronted
description: "众安前端（zacc）— 项目拓扑 Wiki：单一入口 /zacc-init-wiki-fronted（或本技能）交互选择 SOP 与子命令；在 wiki/ 生成图谱、增量更新与架构查询。可独立或与 zacc-init-fronted 配套。"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
version: "1.0.2"
tags: ["frontend", "wiki-fronted"]
---

> **说明**：本技能全部执行规范已合并于本 **`SKILL.md`**对目标项目写入的产出目录仍为 **`wiki/`**（与技能包路径无关）。

> **配套**：若尚未生成 `CLAUDE.md` / `.claude/AI_RULES.md`，可先执行 **`zacc-init-fronted`**。

# Project Topology Wiki — AI 知识基础设施

为任意技术栈项目生成结构化的 AI 专属知识图谱，存储在 `wiki/`，与业务代码完全解耦。

## 核心哲学

| 原则     | 说明                                                 |
| -------- | ---------------------------------------------------- |
| 解耦记忆 | AI 的架构认知独立于业务代码，存储在 `wiki/`         |
| 机器友好 | 使用 Frontmatter + YAML 声明，抛弃散文叙述           |
| 有界检索 | 先用 Wiki 收敛候选范围，再定向读代码校验，避免泛遍历 |
| 尊重现状 | 不了解项目现况前，禁止任何破坏性修改                 |
| 增量演进 | Wiki 随项目演进，只追加不覆盖历史包袱                |

## 输出文件

| 文件             | 位置           | 作用                                                |
| ---------------- | -------------- | --------------------------------------------------- |
| index.md         | `wiki/`       | 全局拓扑索引（三层架构视图）                        |
| index.json       | `wiki/`       | 机器可读索引（按 path / alias / export / tag 检索） |
| glossary.md      | `wiki/`       | 项目术语表                                          |
| {id}.md          | `wiki/nodes/` | 原子知识节点（每个模块一个，`id` 必须稳定）         |
| .wiki-state.json | `wiki/`       | 增量更新状态快照                                    |

## Definition of Done

- **初始化完成**：已生成 `wiki/index.md`、`wiki/index.json`、`wiki/glossary.md`、`wiki/.wiki-state.json` 与节点文件；节点 `id` 稳定且可回溯到真实代码路径
- **节点合格**：每个深度节点至少包含 `id`、`path`、`aliases/tags`、`key_files`、`dependencies`、`coverage`、`confidence`、`freshness`
- **增量更新完成**：变更模块及其 1-hop 邻居已刷新；Legacy Constraints 未丢失；无法确认的节点被标记为 `stale` 或 `low confidence`
- **查询完成**：回答中包含目标模块、至少一层上下游、相关历史包袱、检索依据、是否发生扩圈
- **流程合格**：在进入源码前，已先执行 Wiki-first 检索；没有无边界全仓遍历

## Wiki-first 检索协议

> 目标：让 AI 在修改项目时优先走 `wiki/` 这层 memory，而不是直接对 `src/` 做全仓泛遍历 ，**任何涉及代码修改的任务，在执行第一个编辑/写入操作之前，必须先完成以下步骤并输出结果：未完成上述步骤前，禁止执行任何文件修改操作。**。


### 默认检索顺序

1. **先读索引**：优先读取 `wiki/index.md` 与 `wiki/index.json`
2. **先收敛候选**：按 `path`、`title`、`aliases`、`exports`、`tags`、`glossary` 命中 1-3 个候选节点
3. **再读邻居**：补读目标节点的 1-hop `dependencies` / `dependents` / `route_to` / `route_from`
4. **定向读代码**：仅进入节点的 `key_files` 与 `related_paths` 校验，不直接全局扫描源码
5. **最后再扩圈**：仅当命中置信度不足、节点已过期、路径失效、或依赖断裂时，才允许扩大搜索范围

### 扩圈条件（防漏机制）

- `wiki/index.json` 中无命中，或候选节点 `confidence = low`
- 节点 `freshness != fresh`
- `key_files` 已不存在，或 `path` 与当前目录结构不一致
- 读取 1-hop 邻居后，仍无法解释用户要修改的行为入口或影响范围

### Tag 使用原则

- **应增加 tag**，但优先使用**受控 tag**，避免自由发挥导致噪音
- 推荐格式：`domain:*`、`kind:*`、`layer:*`、`risk:*`、`tech:*`
- `tag` 用于**召回**，`path` / `key_files` 用于**收敛**，二者不可互相替代

## 统一入口与交互分流（必读）

用户使用技能 **`zacc-init-wiki-fronted`** 或斜杠 **`/zacc-init-wiki-fronted`**。**不依赖**多个独立斜杠命令（如 ~~init / query / update 三分拆~~）；由助手在本入口完成分流。

### 何时主动询问用户

- **用户已用自然语言说清意图**（例如「首次生成 Wiki」「查支付模块上下游」「做一次 scan」「记一条 legacy」）：直接映射到对应 **SOP** 与子命令，**不必**再问一级菜单。
- **意图不明确**（例如只说「帮我弄下 Wiki」）：使用 **AskUserQuestion**（或环境支持的等价交互）展示 **一级菜单**：
  1. **初始化拓扑 Wiki** → 执行 **SOP-1**
  2. **架构感知查询** → 若尚未给出问题，请用户补充 → 执行 **SOP-3**
  3. **增量更新 / 历史包袱** → 继续展示 **二级菜单**，选项与 **SOP-2「### 子命令」** 一致：`scan` | `legacy` | `node add` | `node deprecate` | `node update` | `refresh` → 执行 **SOP-2** 对应小节

### 一级菜单与 SOP 对应

| 一级选择 | SOP       | 说明                                   |
| -------- | --------- | -------------------------------------- |
| 初始化   | **SOP-1** | 首次或全量重建 `wiki/`                |
| 查询     | **SOP-3** | 需要用户问题文本                       |
| 增量更新 | **SOP-2** | **必须先选二级子命令**（见下节 SOP-2） |

---

## SOP-1：项目拓扑初始化

> **触发**：用户在一级菜单中选「初始化」，或明确表达首次生成 / 全量初始化 Wiki；若用户一句话已等价于初始化意图，可直接执行本 SOP。

### 步骤 1：项目类型检测

**参考**：`references/project-detection.md`、`references/monorepo-strategies.md`

- 检测项目类型、语言、入口文件、项目名称、项目描述、源码根目录
- 检测是否为 Monorepo；如是，按 `monorepo-strategies.md` 选择全量 / 聚焦 / 选择性处理
- **Taro 小程序检测**：命中 `package.json` 后，额外检查 `@tarojs/taro` / `@tarojs/cli` 依赖、`config/` 目录、`project.config.json`、`app.config.ts` 等信号；识别为 `taro-miniprogram` 或 `taro-multi-platform`
- 无法识别时，再询问用户源码目录和语言
- 最小输出：`project_type`、`language`、`entry_file`、`monorepo`、`source_root`（Taro 项目额外输出 `framework`）

### 步骤 2：核心模块扫描

**参考**：`references/module-extraction.md`

- 对前端项目，优先识别 type-organized 结构：按 `components/`、`pages/`、`api/`、`hooks/`、`store/`、`utils/` 等容器目录分别提取内部模块
- **Taro 小程序项目**：使用 `module-extraction.md` 中的 Taro 专用容器目录（`services/`、`subpackages/`）和扫描步骤；必须先解析 `app.config.ts` 提取路由信息再执行模块扫描；页面合法性以 `app.config.ts` 的 `pages[]` 为准
- 只做浅扫描：Glob 目录结构，默认深度 2-3 层，不遍历每个文件内容
- 组件/页面/API 按子目录识别；hooks/store/utils 按文件识别
- 基础模块（components, hooks, store, utils, constant, services）不参与评分淘汰，全部创建至少轻量节点
- 按候选模块数与评分策略决定深度扫描范围（前端项目阈值见 `module-extraction.md`）
- 对深度节点只读入口文件并提取公开接口；轻量节点只保留最小元数据
- 空目录或单文件模块创建轻量节点并标记 `confidence: low`
- **轻量节点后续升级**：用户可通过 SOP-2 的 `node update` 子命令（`--id {id}`）将任一轻量节点升级为深度节点

### 步骤 3：依赖关系提取

**参考**：`references/dependency-analysis.md`

- 始终维护三层边：`import`、`route`、`dynamic`
- 必须分开统计 `import_in` 与 `route_in`，禁止合并
- 前端项目才扫描 `route_to` / `route_from`
- 页面类模块通常 `import_in = 0`，不得因此低估其重要性
- 仅对 `import` 关系做循环依赖检测

### 步骤 4：生成节点文件

**模板**：`templates/wiki-node.md.tpl`
**执行细节**：`references/operational-guidelines.md`（含并行写入策略、轻量/深度节点正文结构、稳定 ID 规则）

为每个模块生成 `wiki/nodes/{id}.md`。关键约束：

- 节点 `id` 必须是稳定语义 ID（如 `page.checkout`），**禁止使用时间戳**
- 节点写入必须并行（单响应多工具），单轮最多 8 个文件
- 深度节点按模板生成 7 章节（概述 / 快速定位 / 公开接口 / 依赖关系 / 关键文件 / 设计决策 / 历史包袱）
- 轻量节点只保留 frontmatter + 概述 + 文件列表，控制在 15 行内

**节点元数据契约**：以 `templates/wiki-node.md.tpl` 为准，字段分类见下方「节点元数据契约」章节。

### 步骤 5：生成全局拓扑索引（人类版 + 机器版）

**模板**：`templates/wiki-index.md.tpl`、`templates/wiki-machine-index.json.tpl`
**执行细节**：`references/operational-guidelines.md`（含 Mermaid 命名规则、大型项目降级策略）

- `index.md` 负责人类可读导航，`index.json` 负责机器检索
- 结构与字段以模板为准，至少保留：分层视图、依赖图、关系总表、快速导航、机器索引
- `index.json` 至少提供：`nodes`、`indexes.by_path`、`by_alias`、`by_export`、`by_tag`、`by_file`

### 步骤 6：生成术语表

**模板**：`templates/wiki-glossary.md.tpl`

- 从模块名、类名、核心方法名提取术语、缩写、历史名
- 术语表中的中文名、缩写、历史名称应尽量回写到对应节点的 `aliases`

### 步骤 7：保存状态并输出结果

**生成 `wiki/.wiki-state.json`**：

- 至少包含：`version`、`project_type`、`language`、`last_full_scan`、`last_scanned_commit`、`scanned_dirs_hash`、`node_count`
- `nodes[]` 至少包含：`id`、`slug`、`path`、`previous_paths`、`key_files_hash`、`coverage`、`freshness`

**检查 CLAUDE.md 并追加 Wiki 规则**：

如果目标项目存在 `CLAUDE.md`，追加一个简短章节即可，至少覆盖：

- 修改前先查 `wiki/index.md` / `wiki/index.json`
- 发现历史包袱时记录到对应节点的 `Legacy Constraints`
- `wiki/` 的主要文件位置

**输出结果**：

- 简要汇报项目类型、模块数、依赖数、生成文件清单
- 明确下一步优先动作：`查询` 或 `增量更新`

---

## SOP-2：增量更新与冲突记录

> **触发**：用户在一级菜单中选「增量更新」并已选定下方 **子命令**；或用户自然语言已等价于某一子命令（如「scan 一下」「记 legacy」）。项目变更后、发现逻辑矛盾时，通常对应 **scan** 或 **legacy**。

### 前置检查

读取 `wiki/.wiki-state.json`。如不存在，提示用户先通过 **`/zacc-init-wiki-fronted`** 完成 **SOP-1（初始化）**。

### 子命令

#### `scan` — 增量扫描

**用法（子命令 `scan`）**：在统一入口中选「增量更新」→「scan」；无额外必选参数时直接执行下列步骤。

1. 重新生成目录结构 hash，与 `.wiki-state.json` 中的 `scanned_dirs_hash` 对比
2. 如仓库可用 Git，优先比对 `last_scanned_commit..HEAD` 的文件变更；否则回退到目录 hash + `key_files_hash`
3. 检测：新增目录（潜在新模块）、删除目录（废弃模块）、关键文件变更、路径迁移
4. **仅对变更模块及其 1-hop 邻居**：重新执行模块提取和依赖分析
5. 更新对应节点文件（**保留** 历史包袱章节不动）；无法确认的节点标记 `freshness: stale` 或 `confidence: low`
6. 重新生成 `index.md`、`index.json`
7. 更新 `.wiki-state.json`

#### `legacy` — 记录历史包袱

**核心原则：绝不修改节点已有内容，只追加 Legacy Constraints 章节。**

**用法（子命令 `legacy`）**：在统一入口中已选「增量更新」→「legacy」后，提供节点与约束，例如参数形式 `--node {id或名称} --constraint "描述"`（若对话式交互，可分步向用户收集）。

**模板**：`templates/wiki-legacy-section.md.tpl`
**参考**：`references/legacy-constraint-patterns.md`

- 只允许向 `Legacy Constraints` 章节追加模板内容
- 编码过程中若检测到遗留信号、矛盾信号、兼容分支或强制保留注释，应提示用户记录
- 严重程度与批量扫描规则以 `legacy-constraint-patterns.md` 为准

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
2. 全量重建后，优先按稳定 `id` 回写历史包袱；无法按 `id` 命中时，再按 `path` / `previous_paths` 匹配
3. 无法匹配的历史包袱归入 `index.md` 的"孤立历史包袱"章节

---

## SOP-3：架构感知查询

> **触发**：用户在一级菜单中选「查询」并已提供（或补充）具体问题；或用户自然语言已等价于架构问答（如「支付模块上下游有哪些」）。

### 硬规则（不可违反）

1. **禁止** 在未读 `wiki/index.md` / `wiki/index.json` 前直接全仓扫描 `src/`
2. **必须** 先读 `wiki/index.md` 与 `wiki/index.json`
3. **必须** 追踪上下游依赖至少一层
4. **必须** 合并相关节点的 Legacy Constraints 到回答中
5. **仅当** Wiki 命中不足或节点过期时，才允许扩大源码搜索范围

### 步骤 1：加载 Wiki 索引（强制）

读取 `wiki/index.md` 与 `wiki/index.json`。如 `wiki/` 不存在，提示先通过 **`/zacc-init-wiki-fronted`** 执行 **SOP-1（初始化）**。

### 步骤 2：定位相关节点

将用户问题的关键词与以下字段匹配：

- 节点 `title`
- 节点 `path`
- 节点 `aliases`
- 节点 `exports`
- 节点 `tags`
- 术语表 `glossary.md` 中的术语

按命中情况选出 1-3 个最高相关候选，读取对应节点文件。

### 步骤 3：追踪上下游（强制）

读取匹配节点的 `dependencies`、`dependents`、`route_to`、`route_from`。加载邻居节点，理解影响范围。

至少追踪一层。如涉及 foundation 模块（被多模块依赖），需评估全局影响。

### 步骤 4：定向代码校验

仅允许进入候选节点的 `key_files` 与 `related_paths` 做代码校验。

- 优先读入口文件、核心 hook / store / service / route 文件
- 优先使用节点中的 `search_hints` 做定向 Grep
- 若在节点边界内已能确认改动点，**不得**继续扩大扫描范围

### 步骤 5：有限扩圈（仅在必要时）

仅当出现以下情况时，才允许从节点边界向外扩圈：

- 候选节点 `confidence = low`
- 节点 `freshness = stale | partial`
- `key_files` 不存在或与当前目录结构冲突
- 读取 1-hop 邻居后，仍无法解释调用链或影响范围

扩圈顺序必须是：`related_paths` → 同层兄弟目录 → 全局 `rg`

### 步骤 6：合并历史包袱（强制）

检查目标节点及其所有邻居节点的 `## 历史包袱 (Legacy Constraints)` 章节。

如存在任何历史包袱，**必须**在回答中明确提醒。

### 步骤 7：输出查询结果

- 回答至少包含：目标模块、至少一层上下游、历史包袱提醒、检索依据、是否扩圈
- 如给出修改建议，必须同时说明影响范围和需要同步修改的关键文件

---

## 节点元数据契约

节点格式以 `templates/wiki-node.md.tpl` 为准；SKILL 中不再重复完整 frontmatter 示例。

- **身份字段**：`id`、`slug`、`type`、`title`、`path`
- **检索字段**：`aliases`、`tags`、`key_files`、`related_paths`、`search_hints`、`exports`
- **关系字段**：`dependencies`、`dependents`、`route_to`、`route_from`、`lazy_deps`
- **质量字段**：`coverage`、`confidence`、`freshness`、`created_at`、`last_scanned`

> **page 类型说明**：路由懒加载的页面组件不会被其他模块 import，`import_in` 通常为 0，**不代表该模块不重要**。应以 `route_in` 判断页面的业务使用频率。

---

## 性能优化策略

- 详细执行顺序、并行写入约束、边界场景见 `references/operational-guidelines.md`
- 核心原则只有四条：浅扫描、入口文件优先、增量更新优先、节点写入必须并行且单轮最多 8 个文件

## 边界场景处理

- 空项目、超大 Monorepo、未知项目类型、`wiki/` 已存在、文件不可读、候选模块过多等场景，统一按 `references/operational-guidelines.md` 处理

## 与现有 Skill 协作

| 现有 Skill          | 协作方式                                                                  |
| ------------------- | ------------------------------------------------------------------------- |
| `zacc-init-fronted` | Wiki 与前端初始化互补：CLAUDE.md / AI_RULES.md 与 Legacy Constraints 协同 |

---

## 参考文件

- `references/project-detection.md` — 多语言项目类型检测策略
- `references/module-extraction.md` — 核心模块提取算法
- `references/dependency-analysis.md` — 依赖关系分析方法
- `references/legacy-constraint-patterns.md` — 历史包袱识别模式
- `references/monorepo-strategies.md` — Monorepo 处理策略
- `references/operational-guidelines.md` — 执行顺序、并行写入与边界场景

---

## 完成输出

- 汇报生成结果：模块数、依赖数、产物清单
- 提醒下一步入口：`查询` / `增量更新`
- 如发现不确定性，明确指出 `stale` / `low confidence` 节点
