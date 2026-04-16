---
name: fe-init
description: "前端项目 AI 初始化 - 融合六维度项目分析 + 拓扑 Wiki 图谱生成，自动生成 CLAUDE.md + .claude/AI_RULES.md + .wiki/，让 Claude Code 快速理解项目并遵循现有模式"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
version: "1.0.1"
tags: ["frontend", "init", "wiki", "fe-wiki"]
---

# fe-init — 前端项目 AI 初始化

为团队内部前端项目生成 AI 开发配置，让 Claude Code 理解项目上下文并遵循现有开发模式。

## 输出文件

| 文件 | 位置 | 作用 |
|------|------|------|
| CLAUDE.md | 项目根目录 | 项目配置（技术栈、命令、规范、纠错记录） |
| AI_RULES.md | .claude/ 目录 | AI 红线规则（技术栈/架构/风格/业务逻辑） |
| index.md | .wiki/ | 全局拓扑索引（含 Mermaid 图谱） |
| glossary.md | .wiki/ | 项目术语表 |
| {id}-{slug}.md | .wiki/nodes/ | 原子知识节点（每个模块一个） |
| .wiki-state.json | .wiki/ | 增量更新状态快照 |
| fe-init.md 等 ×4 | .claude/commands/ | Claude Code 斜杠命令（与技能包同步） |

## 执行流程

### 步骤 1：项目信息收集

**必读文件**：
- `package.json` → 项目名称/描述、依赖版本、脚本命令
- 构建配置 → `vite.config.*` / `webpack.config.*` / `next.config.*` / `nuxt.config.*`
- `README.md` → 项目说明
- lock 文件 → 判断包管理器（`package-lock.json` → npm / `yarn.lock` → yarn / `pnpm-lock.yaml` → pnpm）

**monorepo 检测**：
- `pnpm-workspace.yaml` / `lerna.json` / `nx.json` / `turbo.json`

**技术栈识别**：
- 参考 `references/tech-stack-detection.md` 中的识别方法和关键词
- 输出：类别 | 技术选型 | 版本 表格

### 步骤 2：项目结构分析

- 使用 Glob/LS 扫描 `src/` 目录（深度 2-3 层）
- 识别组织模式：
  - 按功能（feature-based）：`src/features/xxx/`
  - 按类型（type-based）：`src/components/`, `src/pages/`, `src/api/`
  - 按模块（module-based）：`src/modules/xxx/`
- 标注关键目录用途（api / components / pages / router / store / utils / hooks / styles / assets）

### 步骤 3：代码规范提取

**配置文件读取**：
- ESLint：`.eslintrc.*` / `eslint.config.*` / `package.json` 的 `eslintConfig`
- Prettier：`.prettierrc.*` / `prettier.config.*`
- TypeScript：`tsconfig.json` → strict/paths/baseUrl
- Stylelint：`.stylelintrc.*`（如有）

**命名风格推断**（从现有代码采样）：
- 用 Glob 找 3-5 个典型文件，分析文件名、组件名、变量名的命名风格
- 文件命名：kebab-case / PascalCase / camelCase
- 组件命名：PascalCase（几乎所有框架的惯例）
- 变量/函数命名：camelCase / snake_case

**Commit 规范推断**：
- 用 `git log --oneline -20` 查看最近提交
- 识别是否使用 Conventional Commits / 自定义格式

### 步骤 4：数据流转 + 页面流转分析

此步骤的分析结果不输出为文档，仅作为中间数据用于步骤 5 提取红线规则和步骤 6 填充 CLAUDE.md。

**数据流转分析**：
- 参考 `references/data-flow-analysis.md`
- 追踪链路：路由层 → API 层 → 状态层 → 视图层
- 识别项目使用的具体模式（如 API 封装方式、Store 模式、参数传递方式）

**页面流转分析**：
- 参考 `references/page-flow-analysis.md`
- 从路由配置识别页面入口和层级关系
- 识别页面状态控制模式（step/mode/phase 等）

**业务特性识别**：
- 参考 `references/business-features.md`
- 配置化能力、多环境支持、埋点、错误处理等

### 步骤 5：AI 红线分析

基于步骤 1-4 的分析结果，提取红线规则。

- 参考 `references/ai-redlines.md` 中的提取方法
- 提取四类红线：
  1. **技术栈红线**：不能引入未使用的框架/库，不能改变构建配置、包管理器
  2. **架构模式红线**：必须遵循现有目录结构、分层模式、状态管理方式、API 封装方式
  3. **代码风格红线**：必须遵循现有命名规范、文件命名方式、组件写法风格
  4. **业务逻辑红线**：不能破坏数据流转链路、不能改变路由参数传递方式
- **功能修改确认规则**：修改以下内容时必须先弹窗确认：
  - 现有组件的 props/接口定义
  - 路由配置或页面跳转逻辑
  - 状态管理 Store 结构
  - API 请求/响应处理逻辑
  - 删除或重命名现有文件/函数/组件

### 步骤 6：生成/更新文件

**使用模板**：
- `templates/CLAUDE.md.tpl` → 生成 CLAUDE.md
- `templates/AI_RULES.md.tpl` → 生成 .claude/AI_RULES.md

**已有文件处理策略**：

| 情况 | 策略 |
|------|------|
| 无 CLAUDE.md | 基于模板完整生成 |
| 已有 CLAUDE.md | 增量更新：补缺失章节、更新过时信息、保留用户自定义内容 |
| 无 .claude/AI_RULES.md | 基于模板完整生成 |
| 已有 .claude/AI_RULES.md | 询问用户是否重新生成 |

**增量更新 CLAUDE.md 的规则**：
1. 读取现有 CLAUDE.md 内容
2. 逐章节对比：
   - 标准章节（技术栈、命令、规范等）缺失 → 追加
   - 标准章节内容过时（如版本号变化）→ 更新
   - 非标准章节（用户自定义）→ 保留不动
   - 纠错记录章节 → 保留所有已有记录
3. 使用 Edit 工具增量修改，不覆盖整个文件

### 步骤 6b：同步 Claude Code 命令（.claude/commands/）

> **每次执行 `/fe-init` 必须做**：把技能包里的命令模板落到**当前项目根目录**下的 `.claude/commands/`，这样团队成员可用 `/fe-init`、`/fe-wiki-init` 等斜杠命令。

**目录**：

- 若项目根目录没有 `.claude/`，创建它
- 若没有 `.claude/commands/`，创建它（例如：`mkdir -p .claude/commands`）
- 若已存在，直接在 `commands/` 下写入或覆盖同名文件即可

**源文件（相对技能根目录 `.claude/skills/fe-init/`）→ 目标（相对项目根）**：

| 模板路径 | 写入目标 |
|----------|----------|
| `templates/commands/fe-init.md` | `.claude/commands/fe-init.md` |
| `templates/commands/fe-wiki-init.md` | `.claude/commands/fe-wiki-init.md` |
| `templates/commands/fe-wiki-query.md` | `.claude/commands/fe-wiki-query.md` |
| `templates/commands/fe-wiki-update.md` | `.claude/commands/fe-wiki-update.md` |

**做法**：用 Read 读取技能包内上述四个模板，再用 Write 写入项目对应路径（与模板内容保持一致，保证与当前 fe-init 技能版本同步）。

### 步骤 7：输出初始化结果

```
✅ 前端项目 AI 初始化完成

📊 项目分析结果：
- 项目名称：{name}
- 框架：{framework} {version}
- UI 库：{uiLib}
- 状态管理：{stateManagement}
- 构建工具：{buildTool}
- 包管理器：{packageManager}
- TypeScript：{yes/no}

📄 已生成/更新文件：
- CLAUDE.md — 项目配置（{新建/更新}）
- .claude/AI_RULES.md — AI 红线规则（{新建/更新}）
- .claude/commands/ — fe-init、fe-wiki-init、fe-wiki-query、fe-wiki-update（已同步）

🚫 AI 红线摘要：
- 技术栈：{N} 条规则
- 架构模式：{N} 条规则
- 代码风格：{N} 条规则
- 业务逻辑：{N} 条规则

⏳ 正在生成项目拓扑 Wiki...
```

### 步骤 8：生成项目拓扑 Wiki（.wiki/）

> 此步骤复用 `wiki/WIKI.md` 的 SOP-1 流程。
> 也可通过 `/fe-wiki-init` 单独执行。

**读取** `wiki/WIKI.md` 的 SOP-1 部分，按三阶段执行：

**阶段 A — 补充扫描（复用步骤 1-2 的数据）**：
- 步骤 1-2 已经完成了项目类型检测和结构分析，此处**复用已有数据**，不重复扫描
- 补充执行：模块排序评分（引用次数/文件数/git活跃度）+ 依赖关系提取（Grep import）
- 参考 `wiki/references/module-extraction.md` 和 `wiki/references/dependency-analysis.md`

**阶段 B — 批量写入（并行）**：
- 并行写入所有节点文件到 `.wiki/nodes/`（每批 <= 8 个）
- 并行写入 `index.md`（含 Mermaid 图谱）+ `glossary.md` + `.wiki-state.json`
- 模板来自 `wiki/templates/`

**阶段 C — 输出 Wiki 结果**：

```
📊 项目拓扑 Wiki 已生成

📦 识别的核心模块：{N} 个深度节点 + {N} 个轻量节点
🔗 内部依赖：{N} 条
📄 文件：.wiki/index.md + .wiki/nodes/ × {N}

💡 Wiki 命令：
- /fe-wiki-query {问题} — 架构感知查询
- /fe-wiki-update — 增量更新 Wiki
- /fe-wiki-update legacy — 记录历史包袱

💡 建议：
- 检查生成的文件内容是否准确
- 根据团队实际情况补充自定义规则
- AI 在开发中犯错时会自动记录到 CLAUDE.md 纠错记录
```

---

## 纠错自学习机制

> 这不是初始化步骤，而是 /fe-init 初始化后的持续行为。
> 此机制依赖 CLAUDE.md 中的"纠错记录"章节被 Claude Code 自动加载。

### 触发条件

用户对 AI 输出进行纠正时，识别以下信号：
- 用户说"不对"、"错了"、"不是这样"、"应该用 xxx"
- 用户说"这里要用 xxx 而不是 xxx"
- 用户撤销/拒绝 AI 的修改并给出正确做法
- 用户明确指出 AI 不理解项目的某个模式

### 执行动作

1. 提取纠错要点：错误是什么、正确做法是什么
2. 用 Edit 工具在 CLAUDE.md 的"纠错记录"章节追加一条记录：
   ```
   - [YYYY-MM-DD] {错误描述} → {正确做法}
   ```
3. 如果纠错涉及红线级规则（命名规范、架构模式、数据流转等），同时用 Edit 更新 `.claude/AI_RULES.md` 对应章节

### 示例

```
- [2026-04-10] 在 api/ 目录下直接用了 axios.get → 必须通过 utils/request.ts 封装调用
- [2026-04-10] 组件文件用了 camelCase 命名 → 组件文件必须用 PascalCase
- [2026-04-11] 新增页面没有添加路由守卫 → 所有新页面必须配置 meta.requiresAuth
```
