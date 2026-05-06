---
name: zacc-task-spec
description: "众安前端（zacc）— 前端任务拆解与执行引擎：将需求转化为 IMPLEMENTATION_PLAN.md，依赖 zacc-init-fronted 与 zacc-init-wiki-fronted 产物，按 6 步 SOP 逐 Task 执行。"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
version: "2.2.0"
tags: ["frontend", "task-spec", "planning"]
---

# zacc-task-spec — 前端任务拆解与执行引擎

专为前端复杂业务场景设计的任务拆解与执行引擎。将模糊的产品需求转化为"全局总纲 + 实施细则"的双层状态机。在编写任何实质性代码前，强制执行预研、契约对齐与逻辑占位，确保 AI Agent 在长上下文环境中保持聚焦、防发散、并输出确定性的前端代码。

## When to Use / When NOT to Use

| 场景                                                    | 是否适用   |
| ------------------------------------------------------- | ---------- |
| 新前端页面、复杂 UI 组件、涉及全局状态流转的功能模块    | **适用**   |
| 仅修改文案、调整少量 CSS 样式、修复无依赖关系的单一 Bug | **不适用** |

## Definition of Done

### Phase A：全局总纲合格

- **IMPLEMENTATION_PLAN.md 已生成**：基于 `templates/IMPLEMENTATION_PLAN.md.tpl` 模板，输出到 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md`，包含全部 6 个章节（需求概述、上游依赖、UI 拓扑、状态流动、里程碑、执行日志）
- **上游产物已探测并记录**：`docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 的「上游产物依赖」表格中，每项产物状态已标注为「已加载」或「未找到」
- **UI 拓扑图完整**：组件树已梳理至叶子节点；每个组件已标注类型（通用/业务专用）和来源（已有/新增）；已有组件已关联 `wiki` 节点 ID
- **状态流动图完整**：每个数据来源已关联 API 接口；每个状态已标注全局/局部归属及生命周期；数据流图覆盖从交互到渲染的完整链路
- **里程碑合理**：切分为 3-4 个垂直闭环；每个 Task 已标注粒度等级（S/M）且无 L 级；每个 Task 已列出涉及文件清单
- **历史包袱已纳入**：`wiki/nodes/` 中与本需求相关的 Legacy Constraints 已提取到「历史包袱约束」表格，并标注应对策略
- **上游产物来源已标注**：每个里程碑的描述中注明知识来源（`wiki/` 节点 / `CLAUDE.md` 红线 / 本次新增分析）

### Phase B：单个 Task 执行合格

- **Step 1 契约优先**：已编写 TypeScript `Interface` / `Props` 签名及 Mock 数据；未触碰任何 UI 渲染代码；若 `wiki/nodes/` 有已有签名，已基于其扩展而非重新定义
- **Step 2 行为注释驱动**：核心交互逻辑已用自然语言注释写下执行步骤；注释覆盖成功路径和失败路径
- **Step 3 静态视图渲染**：仅使用 Mock 数据渲染；DOM 结构合理、样式到位；所有事件处理函数为空占位或未绑定
- **Step 4 逻辑注入**：行为注释已替换为真实逻辑代码；数据流为单向；API 调用通过项目既有的请求封装；Store 使用遵循项目既有模式
- **Step 5 验证通过**：lint 无致命报错、类型校验通过、构建通过；三项检查命令来源已记录（`CLAUDE.md` 或推断）
- **Step 6 执行详情已填写**：`docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 中当前 Task 的 `<details>` 区块已完整填写（契约、关键决策、变更文件、关联 commit、依赖、被依赖、回滚），且回滚评估已考虑依赖链
- **Task 状态已更新**：`docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 中对应 Task 已标记为 `[x]`，执行日志已追加完成记录

### 跨 Session 唤醒合格

- **断点已定位**：已读取 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md`，找到最近一个 `[x]` 和下一个 `[ ]`
- **偏差已检查**：断点之后的代码状态与计划描述已对比；偏差已记录并向用户汇报
- **用户已确认**：已向用户汇报当前进度和下一步，并获得继续执行确认

### 状态维护合格

- **活体文档**：每完成一个 Task，`docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 已同步更新状态和执行日志
- **纠错回写**：用户纠正后，`CLAUDE.md` 纠错记录已追加；红线级纠错已同步更新 `AI_RULES.md`
- **阻碍记录**：遇到升级/阻碍时，`docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 的「阻碍与变更记录」已追加条目

### 整体完成

- **所有 Task 已完成**：`docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 中所有里程碑下的 Task 均为 `[x]`，状态为 `completed`
- **验证全部通过**：最后一个 Task 的 Step 5 验证通过、Step 6 执行详情已填写后，整体项目 `npm run build` 无致命报错
- **无遗留阻碍**：「阻碍与变更记录」中无未解决的条目

## 输出文件

| 文件                   | 位置                         | 作用                                                 |
| ---------------------- | ---------------------------- | ---------------------------------------------------- |
| IMPLEMENTATION_PLAN.md | `docs/tasks/{feature-name}/` | 全局总纲，包含 UI 拓扑、状态流动、里程碑与 Task 清单 |

- `{feature-name}` 由用户提供或从需求标题派生（kebab-case，如 `quick-fill`、`order-management`）
- 支持多需求并行：每个功能独立目录，互不冲突
- 前置门禁检测时扫描 `docs/tasks/` 下所有子目录，列出进行中的需求供用户选择

**模板**：`templates/IMPLEMENTATION_PLAN.md.tpl`

---

## 核心执行引擎 (Core Execution Engine)

整个任务生命周期分为两个核心阶段：**[Phase A] 构建全局总纲** 与 **[Phase B] 执行实施细则**。Agent 必须严格按顺序执行。

### 前置门禁：适用性检查

在进入 Phase A 前，**必须先执行以下检查**：

1. **确定 feature-name**：从用户需求中提取功能名称，转为 kebab-case（如「快速填单」→ `quick-fill`）。若用户未明确指定，Agent 自行派生并向用户确认。
2. **确保输出目录存在**：若 `docs/tasks/{feature-name}/` 不存在，自动创建（`mkdir -p docs/tasks/{feature-name}`）。
3. **扫描已有需求**：列出 `docs/tasks/` 下所有子目录中的 `IMPLEMENTATION_PLAN.md`，检查是否有进行中的需求：
   - 若目标 feature 的 `IMPLEMENTATION_PLAN.md` 已存在且有 `[ ]` 未完成项：跳过 Phase A，直接进入 **跨 Session 唤醒流程**。
   - 若目标 feature 的 `IMPLEMENTATION_PLAN.md` 已存在且所有项已完成：询问用户是归档旧文档并重新规划，还是退出。
   - 若目标 feature 的 `IMPLEMENTATION_PLAN.md` 不存在：继续步骤 4。
   - 若存在**其他 feature** 正在进行中：告知用户当前并行进行的需求列表，确认无冲突后继续。
4. **检测上游 Skill 产物是否就绪**（详见 Phase A 前置知识加载）：
   - 若 `CLAUDE.md` 和 `wiki/` 均不存在：提醒用户建议先执行 `zacc-init-fronted` + `zacc-init-wiki-fronted`，但**不阻塞**当前流程。

---

### [Phase A] 构建全局总纲 (The Master Plan)

进入**只读模式 (Read-only)**。严禁直接编写 UI 或业务代码。阅读需求与现有代码库后，基于 `templates/IMPLEMENTATION_PLAN.md.tpl` 模板输出到 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md`。

#### 前置知识加载（依赖上游 Skill 产物）

在构建拓扑结构前，**必须先探测并加载**以下两个上游 Skill 的产物。这些产物为 Phase A 提供项目级上下文，避免重复分析并确保任务规划与项目已有知识对齐。

| 上游 Skill                 | 产物                                | 用途                                             |
| -------------------------- | ----------------------------------- | ------------------------------------------------ |
| **zacc-requirement-spec**  | `docs/requirements/{feature-name}.md` | 结构化需求文档（机读 Meta + 六段式业务描述），**最高优先级** |
| **zacc-init-fronted**      | `CLAUDE.md`                         | 技术栈版本、构建/ lint 命令、代码规范、纠错记录  |
| **zacc-init-fronted**      | `.claude/AI_RULES.md`               | AI 红线规则（技术栈/架构/风格/业务逻辑四类约束） |
| **zacc-init-wiki-fronted** | `wiki/index.md` + `wiki/index.json` | 项目拓扑索引，包含模块分层视图与依赖关系         |
| **zacc-init-wiki-fronted** | `wiki/nodes/{id}.md`                | 原子知识节点，包含模块的公开接口、依赖、关键文件 |
| **zacc-init-wiki-fronted** | `wiki/glossary.md`                  | 项目术语表，辅助需求与代码语义对齐               |

**加载策略**：

0. **优先探测 `docs/requirements/{feature-name}.md`**（由 zacc-requirement-spec 产出）：
   - 若存在：Read 该文档，从「元数据 (Meta)」表格读取 `feature-name` / `主模块路径` / `关联 Wiki 节点` / `涉及新接口` / `涉及路由变更` / `涉及全局状态变更`；从「上游产物摘要」读取 CLAUDE.md / AI_RULES.md / wiki 的状态（可直接跳过下方步骤 1、2 的重复探测）；将各子需求的「受影响文件」/「改造方案」作为 Task 拆分的一等依据。
   - 若不存在：退化为直接接收用户自由描述，继续执行步骤 1、2。

1. **探测 CLAUDE.md / AI_RULES.md**：
   - 若存在：读取技术栈、构建命令、红线规则，作为后续拓扑结构的**约束条件**（e.g., 红线禁止引入新 UI 库 → UI 拓扑中只能使用项目已有组件）。
   - 若不存在：提醒用户先执行 `zacc-init-fronted`，但不阻塞当前流程；改为从 `package.json` 和源码自行推断。
2. **探测 wiki/ 拓扑图谱**：
   - 若存在：按 Wiki-first 协议，通过 `index.json` 定位需求涉及的模块节点，读取其 `dependencies`、`key_files`、`exports` 直接填充 UI 拓扑图和状态流动图；同时检查节点的 `## 历史包袱 (Legacy Constraints)` 章节，将已知约束纳入里程碑规划。
   - 若不存在：提醒用户先执行 `zacc-init-wiki-fronted`，但不阻塞当前流程；改为从源码目录结构自行推断模块边界。

#### 三个核心拓扑结构

在加载上游产物的基础上，输出以下三个核心拓扑结构：

1. **UI 拓扑图 (UI Topology):**
   - 梳理组件树级联关系 (e.g., `Page -> ListContainer -> ListItem -> StatusBadge`)。
   - 识别哪些是可复用的通用组件，哪些是业务线专用组件。
   - **优先复用 wiki 节点的依赖关系和 key_files**；对 Wiki 未覆盖的新模块才做增量扫描。
2. **状态流动图 (State Flow):**
   - 定义数据来源 (API 接口)。
   - 定义全局状态 (Store) 与局部状态 (Local State) 的边界。
   - **遵循 AI_RULES.md 中的架构模式红线**（e.g., 必须使用项目既有的 Store 模式、API 封装方式）。
3. **阶段里程碑 (Milestones):**
   - 将工作切分为 3-4 个垂直闭环，每个里程碑内的 Task 必须能独立验证。
   - 示例：`[ ] M1: 数据契约与 Mock -> [ ] M2: 静态骨架屏 -> [ ] M3: 核心逻辑注入 -> [ ] M4: 边界异常处理`
   - **标注上游产物来源**：在里程碑描述中注明哪些知识来自 `wiki/` 节点、哪些来自 `CLAUDE.md` 红线、哪些为本次新增分析。

#### Task 粒度分级标准

里程碑内的每个 Task 必须标注粒度等级，用于预估工作量与触发升级条件：

| 等级  | 文件影响范围 | 典型场景                               | 升级触发                                  |
| ----- | ------------ | -------------------------------------- | ----------------------------------------- |
| **S** | 1-2 个文件   | 新增一个组件、修改一个 API 函数        | 实际修改 > 3 个文件时触发「规模膨胀」升级 |
| **M** | 3-5 个文件   | 新增一个页面（含子组件 + API + Store） | 实际修改 > 6 个文件时触发「规模膨胀」升级 |
| **L** | 6+ 个文件    | 跨模块重构、涉及路由/Store 结构变更    | **必须拆分**为 M 或 S 级子任务后再执行    |

**规则**：

- 所有 Task 默认不允许标为 L 级；若规划时发现需 6+ 文件，必须在里程碑内先行拆分。
- Phase B 执行中若发现实际范围超出标注等级的升级阈值，立即触发「规模膨胀」升级（见人机协同触发器）。

---

### [Phase B] 执行实施细则 (Task Execution SOP)

在 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 确立后，针对每一个被拆分出的小任务（Task），Agent 必须严格遵守以下 6 步前端专属 SOP。

#### Step 1: 契约优先 (Interface & Contract First)

- **动作:** 优先编写 TypeScript `Interface`、组件的 `Props` 签名、以及对应的 `Mock` 数据。
- **约束:** 不触碰任何 UI 渲染代码。先锁定输入输出标准。
- **上游复用:** 若 `wiki/nodes/` 中目标模块已有 `exports` 表，直接基于其签名扩展，不要重新定义。

#### Step 2: 行为注释驱动 (Comment-Driven Behavior)

- **动作:** 在组件内部或核心函数内，使用自然语言注释写下交互逻辑的执行步骤。
- **示例:**

```typescript
const handleCheckout = async () => {
  // 1. 节流：检查 isLoading 状态
  // 2. 校验：检查必填表单项
  // 3. 组装：将局部状态映射为 API 请求 Payload
  // 4. 发送：调用 API 并 await
  // 5. 成功：清理 Store，路由跳转
  // 6. 失败：捕获 Error，触发 Toast 提示
};
```

#### Step 3: 静态视图渲染 (UI Skeleton)

- **动作:** 仅使用 Step 1 定义的 Mock 数据，编写 JSX/HTML 与 CSS/SCSS。
- **约束:** 忽略所有点击事件和动态状态流转，优先确保视觉还原和 DOM 结构合理。
- **上游复用:** 若 `wiki/nodes/` 中有相似页面/组件的节点，参照其 `key_files` 中已有的样式模式和 DOM 结构，保持一致性。

#### Step 4: 逻辑注入 (Logic Integration)

- **动作:** 将 Step 2 中的自然语言注释逐步替换为真实的 JavaScript/TypeScript 逻辑代码。
- **约束:** 保持单向数据流，连接 API 与状态管理。
- **上游复用:** 遵循 `AI_RULES.md` 中定义的数据流转红线（API 封装方式、Store 使用模式）；若 `wiki/nodes/` 中有可复用的 hook / util / service，优先引用而非重写。

#### Step 5: 前端物理防线验证 (Verification Checkpoints)

- **动作:** 在当前 Task 标记完成前，必须在终端执行以下检查，且无致命报错：
  - [ ] lint 检查（优先使用 `CLAUDE.md` 中记录的 lint 命令；无则尝试 `npm run lint`）
  - [ ] 类型校验（TypeScript 项目：`tsc --noEmit`）
  - [ ] 构建验证（优先使用 `CLAUDE.md` 中记录的 build 命令；无则尝试 `npm run build`）
- **约束:** 上述三项全部通过后，才允许进入 Step 6。

#### Step 6: 填写执行详情 (Execution Record)

- **动作:** Step 5 验证通过后，在 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 中展开当前 Task 的 `<details>` 区块，填写以下字段：
  - **契约：** 实际的入参/出参签名或 Props 接口定义
  - **关键决策：** 核心设计选择及理由（为什么选 A 而非 B）
  - **变更文件：** 实际变更的文件列表，标注「新增」或「修改」
  - **关联 commit：** 本 Task 对应的 commit hash（通过 `git log --oneline -1` 获取）
  - **依赖：** 本 Task 依赖的前置 Task ID 列表（如 `T1(类型定义)`）
  - **被依赖：** 依赖本 Task 的下游 Task ID 列表（如 `T4(集成)`）
  - **回滚：** 回滚方式 + 影响评估（需考虑依赖链）
- **约束:** 执行详情填写完成后，才允许将 Task 状态更新为 `[x]`。
- **回滚评估规则:**
  - 若本 Task 无被依赖项：`git revert {commit}` 可安全独立回滚
  - 若本 Task 有被依赖项且下游已执行：需按依赖链**逆序回滚**（先回滚最下游 Task，再逐级回滚），并在回滚字段中注明完整回滚顺序
  - 若本 Task 修改了全局 Store 结构或 API 契约：标注为「高影响回滚」，建议人工介入确认

---

## 状态维护与纠错机制 (State Machine & Rollback)

### 活体文档维护

- 每完成一个 Task 并通过验证，必须显式修改 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md`，将状态更新为 `[x]`，并填写 `<details>` 执行详情区块。
- **执行详情是回溯的唯一入口**：出问题时，通过展开对应 Task 的 `<details>` 即可看到：改了什么文件、为什么这样设计、commit hash 是什么、回滚会影响谁。
- **跨 Session 唤醒流程**（当 Agent 检测到已有未完成的 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 时执行）：
  1. 读取 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md`，定位所有 `[ ]` 未完成项。
  2. 读取最近一个 `[x]` 项及其 `<details>` 执行详情，确认断点位置和上下文。
  3. 检查断点之后的代码状态：若代码已被手动修改，需对比 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 中的描述与实际代码，标注偏差。
  4. 向用户汇报：当前进度、下一个待执行 Task、是否存在偏差。
  5. 用户确认后，从下一个 `[ ]` Task 的 Step 1 继续。

### 回滚操作流程

当需要回滚某个 Task 的产物时，Agent 必须执行以下流程：

1. **查阅执行详情**：展开目标 Task 的 `<details>`，读取「回滚」字段和「被依赖」字段。
2. **评估影响链**：
   - 若「被依赖」为空：可直接 `git revert {commit}`。
   - 若「被依赖」中有已执行的下游 Task：必须按依赖链**逆序回滚**（从最下游开始），逐个 revert 对应 commit。
   - 若回滚字段标注为「高影响回滚」：中断并等待用户确认。
3. **执行回滚**：按评估结果逐个 `git revert`，每次 revert 后执行 Step 5 验证（lint / tsc / build）。
4. **更新文档**：将已回滚的 Task 状态从 `[x]` 改回 `[ ]`，在执行日志中追加回滚记录，在「阻碍与变更记录」中记录回滚原因。

### 错误降级与重规划 (Replanning)

- 如果某个 Task 在实施过程中遇到连续 3 次类型报错、构建失败或依赖冲突：**立即停止编码**。
- 回退代码至上一个稳定的 Checkpoint（通过 Git 或手动撤销）。
- 在 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 的 Task 备注中记录阻碍原因。
- 重新切分该任务或请求人类介入。

### 纠错记录回写

当用户在执行过程中纠正 Agent 的输出时，联动 `zacc-init-fronted` 的纠错自学习机制：

1. **识别纠错信号**：用户说「不对」「应该用 xxx」「这里要用 xxx 而不是 xxx」等。
2. **回写 `CLAUDE.md` 纠错记录**：用 Edit 工具在 `CLAUDE.md` 的「纠错记录」章节追加一条：
   ```
   - [YYYY-MM-DD] {错误描述} → {正确做法}
   ```
3. **升级红线（如适用）**：若纠错涉及架构模式、命名规范、数据流转等红线级规则，同步更新 `.claude/AI_RULES.md` 对应章节。

---

## 人机协同触发器 (Escalation Matrix)

**遇到以下情况，Agent 必须中断执行并等待人类工程师指令:**

| 触发条件         | 说明                                                                           |
| ---------------- | ------------------------------------------------------------------------------ |
| **依赖引入**     | 需要引入新的 NPM 包（特别是 UI 库或状态管理库）时                              |
| **接口阻断**     | 前端所需的字段在后端 API 契约（Swagger/YApi）中不存在时                        |
| **规模膨胀**     | 实际编码发现任务超出标注等级的升级阈值（S→3+文件, M→6+文件）时                 |
| **架构冲突**     | 新需求逻辑与现有基础建设（统一的请求封装、路由守卫等）存在硬冲突时             |
| **历史包袱冲突** | `wiki/nodes/` 中标记的 Legacy Constraints 与新需求产生矛盾时                   |
| **高影响回滚**   | 回滚的 Task 涉及全局 Store 结构或 API 契约变更时，必须中断等待人工确认回滚范围 |

---

## 多框架适配指南

本 Skill 核心流程（Phase A/B、6 步 SOP、状态维护）对任意前端框架通用。以下为不同框架在具体步骤中的差异适配。

### Step 1: 契约优先 — 框架差异

| 框架                    | 接口定义方式                                       | Mock 形式                |
| ----------------------- | -------------------------------------------------- | ------------------------ |
| **React**               | TypeScript `interface` / `type`                    | JSON 对象或 MSW handler  |
| **Vue 2**               | `PropTypes` 或 TypeScript `interface`（若 tsx）    | JSON 对象                |
| **Vue 3**               | `<script setup lang="ts">` 中的 `defineProps<T>()` | JSON 对象                |
| **Angular**             | `@Input()` / `@Output()` + TypeScript interface    | JSON 对象或 Service mock |
| **小程序（Taro/原生）** | `properties` 定义段 + TypeScript interface         | JSON 对象                |

### Step 3: 静态视图渲染 — 框架差异

| 框架        | 模板语法                | 样式方案                               |
| ----------- | ----------------------- | -------------------------------------- |
| **React**   | JSX                     | CSS Modules / Styled Components / SCSS |
| **Vue 2/3** | `<template>` SFC        | `<style scoped>` / SCSS / CSS Modules  |
| **Angular** | HTML template + binding | Component CSS / SCSS / Less            |
| **小程序**  | WXML（类 HTML）         | WXSS / SCSS（Taro）                    |

### Step 5: 验证命令 — 框架差异

| 框架                     | lint                      | 类型校验                      | 构建                  |
| ------------------------ | ------------------------- | ----------------------------- | --------------------- |
| **React (CRA/Vite/Umi)** | `eslint` / `npm run lint` | `tsc --noEmit`                | `npm run build`       |
| **Vue (Vue CLI/Vite)**   | `eslint` / `npm run lint` | `vue-tsc --noEmit`            | `npm run build`       |
| **Angular**              | `ng lint`                 | `ng build --configuration=ci` | `ng build`            |
| **小程序（Taro）**       | `eslint` / `npm run lint` | `tsc --noEmit`                | `npm run build:weapp` |

> **优先级**：始终以 `CLAUDE.md` 中记录的命令为准；`CLAUDE.md` 不存在时，参考上表从 `package.json` scripts 推断。

---

## 输出模板

生成 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md` 时必须使用 `templates/IMPLEMENTATION_PLAN.md.tpl` 模板，确保格式一致。若 `docs/tasks/{feature-name}/` 目录不存在，先执行 `mkdir -p docs/tasks/{feature-name}`。

---

## 约束自动校验 (Integrity Check)

Agent 不能仅靠"自觉"遵守执行详情的填写规范。每次将 Task 标记为 `[x]` 后，**必须运行校验脚本**验证执行详情的完整性和正确性。

### 校验时机

- **Step 6 填写完成后、标记 `[x]` 前**：运行 `bash .claude/skills/zacc-task-spec/scripts/verify-plan.sh docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md`
- **跨 Session 唤醒时**：运行校验脚本检查已完成 Task 的执行详情是否完整
- **整体完成时**：最终验收前运行一次全量校验

### 校验项

| 校验项                 | 规则                                                                                                                              | 失败处理                             |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| **执行详情完整性**     | 每个 `[x]` Task 必须有非空的 `<details>` 区块，且 7 个字段（契约、关键决策、变更文件、关联 commit、依赖、被依赖、回滚）均非占位符 | 阻塞：不允许标记 `[x]`，提示补填     |
| **commit hash 真实性** | `关联 commit` 中的 hash 必须在 `git log` 中存在                                                                                   | 阻塞：要求修正 commit hash           |
| **依赖双向一致性**     | 若 T3 的「依赖」列出 T1，则 T1 的「被依赖」必须包含 T3                                                                            | 警告：提示修正不一致的依赖关系       |
| **变更文件存在性**     | 「变更文件」中列出的文件路径必须在当前工作树中存在                                                                                | 警告：提示确认文件是否已重命名或删除 |

### 校验脚本

位置：`.claude/skills/zacc-task-spec/scripts/verify-plan.sh`

用法：

```bash
bash .claude/skills/zacc-task-spec/scripts/verify-plan.sh docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md
```

输出：逐项报告 PASS / FAIL / WARN，最终给出是否允许继续的结论。

---

## 上下文预算管理 (Context Budget)

Agent 在长对话中执行多个 Task 后，累积的上下文会导致注意力分散和输出质量下降。以下规则帮助 Agent 在合适的时机建议用户分段执行。

### 分段执行规则

| 条件                                                             | 动作                                                               |
| ---------------------------------------------------------------- | ------------------------------------------------------------------ |
| **单次 Session 已完成 ≥ 3 个 M 级 Task** 或 **≥ 5 个 S 级 Task** | 建议用户开新 Session 继续，并告知跨 Session 唤醒流程会自动恢复断点 |
| **单个 Task 执行中工具调用超过 30 次**                           | 暂停并向用户汇报进展，确认是否继续或拆分 Task                      |
| **Phase A 规划产出超过 8 个 Task**                               | 建议将里程碑拆分为两批次执行，先完成前半再规划后半                 |

### Agent 自检提示

每个 Task 的 Step 1 开始前，Agent 应在内部检查：

1. 当前 Session 已完成多少个 Task？是否接近分段阈值？
2. 上一个 Task 是否有未解决的 warning？
3. 当前 IMPLEMENTATION_PLAN 的执行日志是否与代码实际状态一致？

若任一检查发现异常，先向用户汇报再继续。

---

## 完整示例

参考 `templates/EXAMPLE_quick-fill.md`，这是一份基于真实「快速填单」功能按 v2.2 规范填写的完整 IMPLEMENTATION_PLAN 示例，包含：

- 4 个 Task 的完整 `<details>` 执行详情（契约、关键决策、变更文件、commit、依赖链、回滚评估）
- 历史包袱的补充约束（来自代码分析而非 Wiki）
- 阻碍与变更记录（T4 从 T3 拆分的过程）

新使用者可将其作为参照物，了解每个字段应该写到什么粒度。
