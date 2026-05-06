---
name: zacc-requirement-spec
description: "众安前端（zacc）— 需求文档生成引擎：将用户一句话需求描述转化为结构稳定、可被 zacc-task-spec 无缝消费的需求文档。强制 plan 模式：先草案对齐，用户确认后再落盘。"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, EnterPlanMode, ExitPlanMode
version: "1.2.0"
tags: ["frontend", "requirement", "spec", "planning"]
---

# zacc-requirement-spec — 需求文档生成引擎

将用户的自由形式需求描述（一句话 / 一段话）转化为结构化、字段齐全的需求文档，作为 `zacc-task-spec` 的稳定输入源，让 AI 开发链路「需求 → 规划 → 执行」全程确定性可控。

## When to Use / When NOT to Use

| 场景 | 是否适用 |
|------|---------|
| 用户只有模糊的一句话 / 一段话描述，需要产出结构化需求文档 | **适用** |
| 用户已手写完整 PRD，仅需小调整 | **不适用**（直接交给 zacc-task-spec） |
| 仅修改文案 / 单一 Bug 修复 | **不适用**（直接改代码） |

## 链路定位

```
用户一句话描述
     ↓  (本 skill)
docs/requirements/{feature-name}.md         ← 契约文件
     ↓  (zacc-task-spec 消费)
docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md
     ↓  (6 步 SOP 执行)
代码
```

## 产物清单 (Deliverables)

本 skill 每次成功执行**必须且仅产出**以下文件，路径和内容要求如下：

| # | 产物 | 路径 | 写入阶段 | 必备区块 | 消费者 |
|---|------|------|---------|---------|--------|
| 1 | 需求文档 | `docs/requirements/{feature-name}.md` | [S5] 用户批准后 | 见下方「文档内容契约」 | `zacc-task-spec` |

**禁止产出**：

- ❌ 任何 `docs/tasks/` 下的文件（属于下游 `zacc-task-spec` 职责）
- ❌ 任何代码文件改动（`src/` 等业务目录）
- ❌ CLAUDE.md / AI_RULES.md / wiki/ 的修改（属于 init skill 职责）
- ❌ 「总结性文档」、README、CHANGELOG 等用户未明确要求的衍生产物

### 文档内容契约

`docs/requirements/{feature-name}.md` **必须**包含以下区块，每项都有可机读的二值判定标准：

| 区块 | 判定标准 | 可验证性 |
|------|---------|---------|
| `# 需求：{feature-title}` 一级标题 | 存在且非占位 | grep `^#\s+需求：` |
| `## 元数据 (Meta)` 机读表格 | 表格含 7 个必填行，feature-name 用反引号 kebab-case 格式 | verify-requirement.sh 强校验 |
| `## 上游产物摘要` 表格 | 4 行产物状态（CLAUDE.md / AI_RULES.md / wiki/index.json / wiki/glossary.md） | verify-requirement.sh 警告级校验 |
| `## 一、{子需求标题}` 起的六段式 | 每个子需求含：背景 / 现状问题 / 改造方案 / 验收标准 / 受影响文件 / 参考代码 | verify-requirement.sh 强校验六段标题存在 |
| `## 全局约束` | 分「来自 AI_RULES.md 的红线」和「本需求特有约束」两段 | verify-requirement.sh 警告级校验 |
| `## 交付说明` | 含 commit 切分建议 + commit 前缀 + 兼容性验证要求 | verify-requirement.sh 警告级校验 |
| `## 待补充信息 (TODO)` | 列出未确认字段，若无则显式写「无」 | 人工肉眼 |

### 占位符完整性

- 模板中 `{...}` 占位符在落盘文件中**必须全部替换**为真实内容或 `unknown` / `TBD` 显式标记
- 禁止保留 `{kebab-case-name}` / `{path}` 等原样占位——校验脚本会对未替换占位符发 WARN

---

## Definition of Done

DoD 分成 **4 组** 共 14 条，每条都可被自动化或人工二值判定（通过 / 未通过），不允许"基本完成"类模糊结论。

### 组 A：流程合规（执行顺序正确）

- [ ] **A1. 上游探测已执行**：已 Read（或确认不存在）`CLAUDE.md` / `.claude/AI_RULES.md` / `wiki/index.json` / `wiki/glossary.md`，结果以表格形式写入「上游产物摘要」
- [ ] **A2. 命中 Wiki 节点已深读**：若 `wiki/index.json` 命中节点，已 Read 对应 `wiki/nodes/{id}.md`，提取其 `key_files` 和 Legacy Constraints
- [ ] **A3. 关键缺失已追问**：对"改造目标文件 / 验收标准 / 参考组件 / 是否涉及接口 · 路由 · 状态变更"中**用户原始描述未覆盖的字段**，已用 `AskUserQuestion` 追问至少一轮
- [ ] **A4. Plan 模式已进入**：[S4] 前已调用 `EnterPlanMode`（或本会话已处于 plan 模式）
- [ ] **A5. 用户已批准草案**：已通过 `ExitPlanMode` 呈交**完整文档全文**（非摘要 / 非 diff），并获得用户批准；**批准前未调用 Write/Edit 操作 `docs/requirements/`**

### 组 B：产物存在（文件与路径正确）

- [ ] **B1. 目标目录存在**：`docs/requirements/` 已通过 `mkdir -p` 确保存在
- [ ] **B2. 产物文件已写盘**：`docs/requirements/{feature-name}.md` 存在，且 `{feature-name}` 与「元数据」表中声明的 feature-name 字符串一致
- [ ] **B3. 无溢出产物**：未在 `docs/tasks/` / `src/` / 根目录产生任何其他文件

### 组 C：产物内容合规（结构与字段齐全）

- [ ] **C1. Meta 表 7 字段齐全**：feature-name / 需求类型 / 估计粒度 / 主模块路径 / 关联 Wiki 节点 / 涉及新接口 / 涉及路由变更 / 涉及全局状态变更 均非 `{...}` 占位（允许填 `unknown`）
- [ ] **C2. 上游产物摘要 4 行齐全**：每行有「已加载 / 未找到」状态 + 一句话摘要
- [ ] **C3. 至少一个子需求六段齐全**：背景 / 现状问题 / 改造方案 / 验收标准 / 受影响文件 / 参考代码 全部存在且非空
- [ ] **C4. 验收标准可观察**：验收标准条目均为可测试行为描述，无"体验更好"类模糊描述
- [ ] **C5. 红线已继承或显式说明未命中**：「来自 AI_RULES.md 的红线」章节含 ≥1 条实际红线，或显式写明「未命中特定红线，默认遵循全部条款」

### 组 D：自动校验通过

- [ ] **D1. 校验脚本退出码 0**：`bash .claude/skills/zacc-requirement-spec/scripts/verify-requirement.sh docs/requirements/{feature-name}.md` 返回 0
- [ ] **D2. WARN 项已告知**：若校验有 WARN，已口头告知用户并等待其决定是否补齐

### DoD 自检时机

- **[S4] ExitPlanMode 前**：自查组 A + 组 C（此时文件尚未落盘，组 B / D 暂跳过）
- **[S5] 落盘完成后**：自查组 B + 组 D（借助 verify 脚本）
- **向用户汇报前**：14 条全绿才能宣告完成；任一项未满足必须主动报告

---

## 输出文件

| 文件 | 位置 | 作用 | 生成阶段 |
|------|------|------|---------|
| REQUIREMENT.md | `docs/requirements/{feature-name}.md` | 需求文档，供 zacc-task-spec 读取 | [S5] |

---

## 核心执行流程 (Core Flow)

共 **5 个阶段**：`[S1] 探测上游` → `[S2] 理解需求` → `[S3] 追问补齐` → `[S4] Plan 模式草案对齐` → `[S5] 落盘 & 校验`。

> 🚨 **硬约束**：在用户通过 ExitPlanMode 批准 [S4] 草案前，**严禁**调用 Write 或 Edit 工具创建 / 修改 `docs/requirements/` 下任何文件。违反视为流程事故。

### [S1] 探测上游产物（只读，不阻塞）

与 `zacc-task-spec` 的前置知识加载协议一致。目的：让需求文档继承项目上下文，避免下游 task-spec 重复分析。

| 产物 | 探测动作 | 用途 |
|------|---------|------|
| `CLAUDE.md` | Read；提取技术栈表格 + 纠错记录 | 填 Meta「主模块路径」候选；填「上游产物摘要」 |
| `.claude/AI_RULES.md` | Read；提取红线规则 | 填「全局约束 → 来自 AI_RULES.md 的红线」 |
| `wiki/index.json` | Read；按用户描述关键词命中节点 | 填 Meta「关联 Wiki 节点」；用节点 `key_files` 作受影响文件候选 |
| `wiki/nodes/{id}.md` | 仅读命中节点 | 提取 Legacy Constraints 作为历史包袱 |
| `wiki/glossary.md` | Read；映射用户俗称 → 正式术语 | 统一文档中的模块命名 |

**降级规则**：

- 任一产物不存在时，在「上游产物摘要」表格标注 `未找到`，在文档顶部追加一句提醒：
  > 未检测到 `{产物}`，建议先运行 `{对应 init skill}` 提升规划质量。
- **不阻塞**当前流程，继续进入 S2。

### [S2] 理解需求

基于用户输入的自然语言描述，做三件事：

1. **抽取 feature-name**：从描述中提取核心动作 + 对象，转 kebab-case。
   - 示例：「BottomSheet 语音交互改造」→ `bottom-sheet-voice-revamp`
   - 无法派生时用 AskUserQuestion 询问用户。
2. **切分子需求**：若用户描述包含多个独立改造点（如"A 改造 + B 调整"），拆为多个「二级章节」（`## 一、`、`## 二、`）。
3. **关键词匹配 Wiki 节点**：用描述中的模块名 / 组件名 / 路径线索，在 `wiki/index.json` 的 `path` / `title` / `aliases` / `exports` 字段中查找命中节点。

### [S3] 追问补齐（AskUserQuestion）

对以下**关键字段**，若用户描述未覆盖 → 必须通过 AskUserQuestion 主动追问，每轮最多 4 个问题：

| 字段 | 追问时机 | 默认选项示例 |
|------|---------|------------|
| 改造目标文件 | 未出现明确路径 | 候选从 wiki 节点 `key_files` 中列出 |
| 验收标准 | 用户仅说"体验更好"类非量化描述 | 引导用户给出可观察行为 |
| 参考组件 / 参照实现 | 需求含"对齐 XX"但未指明 | 从 wiki glossary 推断 |
| 是否涉及接口 / 路由 / 状态变更 | 未提及 | 是 / 否 / 不确定 |
| commit 切分偏好 | 多子需求场景 | 分拆 / 合并 |

**约束**：

- 禁止一次性追问超过 4 个问题。
- 能从 wiki / CLAUDE.md 自动推断的字段 **不要问**。
- 用户回答后，无法确认的字段写入文档尾部「待补充信息 (TODO)」。

### [S4] Plan 模式草案对齐（强制人类审阅）

**目的**：需求文档是下游 task-spec 的契约源头，一字之差可能导致规划跑偏。必须让用户先看到完整草案并批准，才允许落盘。

**执行步骤**：

1. **进入 plan 模式**：若当前未处于 plan 模式，调用 `EnterPlanMode`。
2. **在内存中渲染完整文档**：按 `templates/REQUIREMENT.md.tpl` 在内存中拼接出完整 Markdown 内容（非摘要、非 diff），全部占位符已替换。
3. **通过 ExitPlanMode 呈交全文**：
   - ExitPlanMode 的 plan 字段中**必须包含完整需求文档内容**（用 Markdown 原文整块呈现，禁止用"省略中间部分"/"详见草案"之类的摘要）。
   - 在文档正文前用一段引导语说明：
     - 将落盘的目标路径：`docs/requirements/{feature-name}.md`
     - 本次探测到的上游产物状态（CLAUDE.md / AI_RULES.md / wiki 命中节点数）
     - 本次 AskUserQuestion 追问后仍遗留在「待补充信息 (TODO)」的条目
   - 文档正文后列出用户可选择的动作：
     - 批准 → 进入 [S5] 落盘
     - 要求修改 → 在用户反馈后回到 [S3] 或 [S4] 内部重新生成草案
     - 放弃 → 结束流程，不写任何文件
4. **等待用户决策**：用户批准 ExitPlanMode 前禁止任何 `Write` / `Edit`。用户反馈修改意见时，根据反馈直接修订内存中的草案，再次通过 ExitPlanMode 呈交新版本——**不得**通过"我知道了，那我修改一下"等口头回复跳过二次呈交。
5. **迭代收敛**：若用户连续 3 次要求修改同一字段仍不满意，暂停并向用户汇报「该字段存在理解分歧，建议手工书写后由本 skill 校验」。

**约束**：

- ExitPlanMode 的 plan 字段不是"实施计划"而是"成品文档全文"——用户看到的是最终会写进文件的内容，不是生成步骤描述。
- 用户批准后的内容即为最终内容，[S5] 不得在落盘前二次加工（除必要的换行 / 编码规范化）。

---

### [S5] 落盘 & 校验

**前置条件**：ExitPlanMode 已获用户批准。

1. **确保目录存在**：`mkdir -p docs/requirements`
2. **一次性写盘**：用 `Write` 工具把 [S4] 批准的完整内容写到 `docs/requirements/{feature-name}.md`。
3. **运行校验脚本**：
   ```bash
   bash .claude/skills/zacc-requirement-spec/scripts/verify-requirement.sh docs/requirements/{feature-name}.md
   ```
4. **校验失败处理**：
   - `FAIL`：说明 [S4] 草案仍有字段遗漏（正常情况下应在 [S4] 即被用户发现）。立即 Edit 补填缺失字段，重新校验。补填涉及实质内容时**必须**回到 [S4] 重新对齐。
   - `WARN`：告知用户当前警告项，询问是否立即补齐或留到 task-spec 阶段由其探测。
5. **向用户汇报**（文字输出，不再进入 plan 模式）：
   - 输出文件路径
   - 未能自动确认、留在「待补充信息 (TODO)」的条目
   - 建议下一步：「确认无误后，可运行 `zacc-task-spec` 继续规划」（**不自动调用**，尊重用户决定）

---

## 上游产物消费细则

### CLAUDE.md 消费

- 技术栈表格 → 推断 Meta「主模块路径」根目录（如 `src/pages/` / `packages/` 等）
- 「纠错记录」章节 → 若命中当前需求关键词，作为「本需求特有约束」的候选项之一

### AI_RULES.md 消费

- 按 AI_RULES.md 的章节结构提取红线条目（类别 + 一句话描述）
- 匹配规则：红线条目的关键词（如 `API 调用` / `路由` / `状态管理` / `样式`）命中用户需求描述时，纳入「全局约束」
- 至少继承 1 条通用红线；无匹配时写一句话说明「未命中特定红线，默认遵循 AI_RULES.md 全部条款」

### Wiki 消费（Wiki-first 协议）

- 必须先读 `wiki/index.json`，按关键词定位候选节点（最多 3 个）
- 读候选节点 `.md`，提取：
  - `key_files` → 「受影响文件」候选
  - `dependencies` / `dependents` → 若命中 foundation 模块（入度 ≥ 30），在「本需求特有约束」中提示"影响面大，建议拆 M 级 Task"
  - `## 历史包袱 (Legacy Constraints)` → 若存在条目，在「全局约束 → 本需求特有约束」中引用
- 节点 `confidence: low` 或 `freshness != fresh` → 在文档尾部提醒用户"关联节点置信度低，建议运行 `/zacc-init-wiki-fronted` 增量更新"

### Glossary 消费

- 用户描述中的俗称 / 缩写 → 查 `wiki/glossary.md` 映射为正式模块名
- 生成文档时统一使用正式名，但在「背景」段落保留用户原描述以便追溯

---

## 多框架适配

本 skill 本身**框架无关**，通过上游产物实现项目定制：

- 当前项目是 **React + Taro 小程序** → CLAUDE.md 已说明，AI_RULES.md 含小程序红线（如禁用 wx.request），生成的需求文档自动引用
- 切换到 **Vue / Angular / Web React** 项目 → 只要运行过 `zacc-init-fronted` + `zacc-init-wiki-fronted`，产物会自动反映新栈，本 skill 无需修改
- 无任何上游产物 → 降级为"纯模板填槽"模式，生成的文档仍满足 task-spec 的最小契约，但缺失项目红线 / wiki 节点信息

---

## 人机协同触发器

| 触发条件 | 说明 |
|---------|------|
| **需求跨越多个主模块** | 若关键词命中 3+ 个 wiki 节点且位于不同分包 / 层，中断追问是否要拆多个需求文档 |
| **历史包袱直接冲突** | 若 wiki 节点 Legacy Constraints 明确禁止用户所求改造，中断告知用户并等待指令 |
| **红线硬冲突** | 若需求本身违反 AI_RULES.md（如要求换状态管理库），中断并提示需要人工评审豁免 |
| **Plan 草案反复不收敛** | 用户连续 3 次要求修改同一字段仍不满意，暂停并建议手工书写 |
| **绕过 Plan 模式的企图** | 若在用户批准前被误触发 Write/Edit `docs/requirements/`，立即中断并向用户汇报事故；禁止"补救式"写入 |

---

## 与 zacc-task-spec 的契约

本 skill 产出的文档**必须**满足以下机读契约，否则 zacc-task-spec 无法正确消费：

1. `## 元数据 (Meta)` 章节存在，且 `feature-name` / `主模块路径` / `关联 Wiki 节点` 三字段非占位符
2. 至少一个子需求包含完整的六段式（背景 / 现状问题 / 改造方案 / 验收标准 / 受影响文件 / 参考代码）
3. `## 全局约束` 章节存在（可为空但必须有标题）

校验脚本 `scripts/verify-requirement.sh` 强制校验上述三项，未通过禁止产出。

---

## 完整示例

参考仓库内 `docs/需求1.md`（手工撰写版）作为风格参照物；本 skill 产出的文档应与其接近，但补齐以下机读元素：

- `## 元数据 (Meta)` 机读表格（手工版缺失）
- `## 上游产物摘要` 表格（手工版缺失）
- `### 来自 AI_RULES.md 的红线` 子章节（手工版缺失）

---

## 输出模板

位置：`.claude/skills/zacc-requirement-spec/templates/REQUIREMENT.md.tpl`

生成时按模板替换全部占位符，不得保留 `{...}` 未替换项（校验脚本会警告）。
