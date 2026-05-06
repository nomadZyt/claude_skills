---
name: zacc-init-fronted
description: "众安前端（zacc）— 项目 AI 初始化：六维度分析 + CLAUDE.md / .claude/AI_RULES.md，不含 wiki/。拓扑 Wiki 请用技能 zacc-init-wiki-fronted。"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
version: "1.3.0"
tags: ["frontend", "init-fronted"]
---

# zacc-init-fronted — 前端项目 AI 初始化（CLAUDE.md + AI 红线）

为团队内部前端项目生成 AI 开发配置，让 Claude Code 理解项目上下文并遵循现有开发模式。

> **配套技能**：生成 `wiki/` 拓扑图谱请使用 **`zacc-init-wiki-fronted`**（本技能不包含 Wiki 步骤）。

### Wiki 技能未安装时的提醒（不影响 init）

执行本技能收尾时，**用 Glob 或 Read 探测**当前环境是否具备 **`zacc-init-wiki-fronted`**（例如工作区或技能目录下是否存在 `zacc-init-wiki-fronted/SKILL.md`、`.claude/skills/zacc-init-wiki-fronted/SKILL.md` 等常见路径；以实际可解析路径为准）。

- **若未找到**（判定为仅安装了 init、未安装 wiki 技能）：在步骤 7 的输出摘要中**追加一行简短提醒**——`zacc-init-wiki-fronted` 未安装，项目拓扑 Wiki（`wiki/`）需安装该技能后单独执行；**不影响**本次 `zacc-init-fronted` 流程与已生成的 `CLAUDE.md` / `AI_RULES.md` 等产出。
- **若已找到**：不必重复此提醒；可照常提示「需要 Wiki 时使用 `zacc-init-wiki-fronted`」。

## 输出文件

| 文件 | 位置 | 作用 |
|------|------|------|
| CLAUDE.md | 项目根目录 | 项目配置（技术栈、命令、规范、纠错记录） |
| AI_RULES.md | .claude/ 目录 | AI 红线规则（技术栈/架构/风格/业务逻辑） |
| （可选）zacc-init-fronted.md | .claude/commands/ | 斜杠命令入口，见步骤 6b |

## 执行流程

### 步骤 0：项目类型门禁（前端 / 非前端）

**必须先于步骤 1 执行**，用于避免在明显非前端的仓库上套用前端六维分析。

1. **判定是否前端项目**（与 `references/tech-stack-detection.md` 一致）：
   - 读取 `package.json`（若存在）的 `dependencies` / `devDependencies`，检查是否出现典型 **Web UI 框架或元框架**（完整框架清单见 `references/tech-stack-detection.md` 的「框架」识别表，此处不重复列举，以该文档为唯一信源）。
   - 无 `package.json` 或依赖表明 **纯后端 / 其他语言 / 非浏览器 UI 工程** → 判为 **非前端**。
   - 边界情况（全栈 Monorepo、依赖表不清晰）：宁可判为 **非前端**，走下方告知与确认，避免误报。

2. **若判定为前端项目**：直接进入 **步骤 1**（标准流程）。

3. **若判定为非前端项目**：
   - **必须先告知用户**：明确说明「当前仓库在本技能口径下为 **非前端项目**（或未识别到典型 Web 前端栈），`zacc-init-fronted` 默认面向前端六维分析」。
   - **必须询问是否继续**：使用 **AskUserQuestion**（或当前环境支持的等价确认交互），选项至少包含：**继续（降级初始化）** / **取消**。
   - **若用户选择取消**：结束流程，**不生成、不修改** `CLAUDE.md`、`.claude/AI_RULES.md`（除非用户另行明确要求仅输出说明）。
   - **若用户选择继续**：进入 **步骤 1**，且全程采用 **`references/non-frontend-degraded.md`** 中的 **降级策略**（步骤 2～6 按该文档收缩/替换；步骤 7 摘要须标注降级模式）。

> 降级策略的逐步说明见 `references/non-frontend-degraded.md`（含步骤 1～7 的对应关系与红线调整方式）。

### 步骤 1：项目信息收集

**必读文件**：
- `package.json` → 项目名称/描述、依赖版本、脚本命令
- 构建配置 → `vite.config.*` / `webpack.config.*` / `next.config.*` / `nuxt.config.*`
- `README.md` → 项目说明
- lock 文件 → 判断包管理器（`package-lock.json` → npm / `yarn.lock` → yarn / `pnpm-lock.yaml` → pnpm）

**monorepo 检测**：
- `pnpm-workspace.yaml` / `lerna.json` / `nx.json` / `turbo.json`

**Monorepo 子包范围限定**（检测到 monorepo 时）：
- 使用 **AskUserQuestion** 询问用户要初始化的子包路径（如 `packages/web`、`apps/admin`），或选择「仅描述仓库整体」
- 若用户指定了子包路径，**后续步骤 2～6 的所有扫描、采样、路由分析均以该子包为根目录**（即用子包的 `package.json`、`src/`、`tsconfig.json` 等）
- 生成的 `CLAUDE.md` 和 `.claude/AI_RULES.md` 仍放在**仓库根目录**，但在项目概述中标注 `初始化范围：{子包路径}`
- 若用户选择「仅描述仓库整体」，则在 CLAUDE.md 中注明「未绑定具体子包，建议后续指定子包重新初始化」

**技术栈识别**：
- 参考 `references/tech-stack-detection.md` 中的识别方法和关键词
- 输出：类别 | 技术选型 | 版本 表格
- **若非前端降级模式**（步骤 0 已确认）：按 `references/non-frontend-degraded.md` 收集与表述技术栈，勿虚构前端框架。

### 步骤 2：项目结构分析

- 参考 `references/project-structure-analysis.md` 中的扫描策略和组织模式识别方法
- 使用 Glob/LS 扫描 `src/` 目录（深度 2-3 层）
- 识别组织模式：
  - 按功能（feature-based）：`src/features/xxx/`
  - 按类型（type-based）：`src/components/`, `src/pages/`, `src/api/`
  - 按模块（module-based）：`src/modules/xxx/`
- 标注关键目录用途（api / components / pages / router / store / utils / hooks / styles / assets）
- **若非前端降级模式**：不强行套用前端目录语义；按 `references/non-frontend-degraded.md` 扫描与归纳。

### 步骤 3：代码规范提取

- 参考 `references/code-standards-extraction.md` 中的配置文件读取优先级和命名风格推断方法

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
- **若非前端降级模式**：以该仓库实际存在的规范配置为准；无则注明未检测到。

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

**若非前端降级模式**：跳过「路由 → 视图」式前端链路；改为按 `references/non-frontend-degraded.md` 做简要分层/模块依赖描述，供步骤 5～6 使用。

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

**若非前端降级模式**：红线条目须与仓库类型一致（见 `references/non-frontend-degraded.md`），不写与当前工程无关的「组件 props / 前端路由」类规则。

### 步骤 6：生成/更新文件

**使用模板**：
- `templates/CLAUDE.md.tpl` → 生成 CLAUDE.md
- `templates/AI_RULES.md.tpl` → 生成 .claude/AI_RULES.md
- **若非前端降级模式**：在 `CLAUDE.md` 的项目概述或技术栈处 **显式标注** `初始化模式：非前端降级（zacc-init-fronted）`；内容须与仓库证据一致，见 `references/non-frontend-degraded.md`。

**已有文件处理策略**：

| 情况 | 策略 |
|------|------|
| 无 CLAUDE.md | 基于模板完整生成 |
| 已有 CLAUDE.md | 增量更新：补缺失章节、更新过时信息、保留用户自定义内容 |
| 无 .claude/AI_RULES.md | 基于模板完整生成 |
| 已有 .claude/AI_RULES.md | 询问用户：**增量更新** / **重新生成**。增量更新时保留「附录 → 纠错追加规则」章节的已有条目，仅更新四类红线正文 |

**增量更新 CLAUDE.md 的规则**：
1. 读取现有 CLAUDE.md 内容
2. 逐章节对比：
   - 标准章节（技术栈、命令、规范等）缺失 → 追加
   - 标准章节内容过时（如版本号变化）→ 更新
   - 非标准章节（用户自定义）→ 保留不动
   - 纠错记录章节 → 保留所有已有记录
3. 使用 Edit 工具增量修改，不覆盖整个文件

**增量更新 AI_RULES.md 的规则**（用户选择增量更新时）：
1. 读取现有 AI_RULES.md 内容
2. 逐章节对比：
   - 四类红线正文（技术栈/架构/代码风格/业务逻辑）→ 用最新分析结果更新
   - 功能修改确认规则 → 用最新分析结果更新
   - 附录 → 纠错追加规则 → **保留所有已有记录**，不删除不覆盖
   - 元信息（版本、日期）→ 更新
3. 使用 Edit 工具增量修改，不覆盖整个文件

### 步骤 6b：同步斜杠命令（可选）

> 若团队需要 **`/zacc-init-fronted`** 斜杠入口：把本技能包里的 `templates/commands/zacc-init-fronted.md` 落到项目根目录 `.claude/commands/zacc-init-fronted.md`。

**目录**：

- 若项目根目录没有 `.claude/`，创建它
- 若没有 `.claude/commands/`，创建它（例如：`mkdir -p .claude/commands`）

**源 → 目标**（相对技能根目录 `zacc-init-fronted/`）：

| 模板路径 | 写入目标 |
|----------|----------|
| `templates/commands/zacc-init-fronted.md` | `.claude/commands/zacc-init-fronted.md` |

**做法**：用 Read 读取技能包内模板，再用 Write 写入项目对应路径。

### 步骤 6c：产出校验

文件生成/更新后，**必须运行校验脚本**验证产出完整性：

```bash
bash .claude/skills/zacc-init-fronted/scripts/verify-init.sh
```

校验项：
- 占位符是否全部填充（CLAUDE.md + AI_RULES.md）
- 必要章节是否完整
- 红线规则是否非空
- 交叉一致性（包管理器、AI_RULES 引用）
- 模板 HTML 注释是否已清理

若有 FAIL 项，必须修正后再进入步骤 7。WARN 项向用户汇报即可。

### 步骤 6d：填写初始化日志

在 CLAUDE.md 底部的「初始化日志」表格追加一行：

```
| {YYYY-MM-DD HH:MM} | v{参见 SKILL.md frontmatter version} | {标准/降级} | {新建/更新}：{变更摘要} |
```

> **版本号取值**：读取本技能 SKILL.md 顶部 frontmatter 的 `version` 字段，填入 `v` + 该值（如 `v1.3.0`）。

### 步骤 7：输出初始化结果

**标准模式（前端）**：

```
✅ 前端项目 AI 初始化完成（zacc-init-fronted）

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
- .claude/commands/zacc-init-fronted.md — 若执行了步骤 6b（可选）

🚫 AI 红线摘要：
- 技术栈：{N} 条规则
- 架构模式：{N} 条规则
- 代码风格：{N} 条规则
- 业务逻辑：{N} 条规则

💡 需要生成项目拓扑 Wiki（wiki/）时，请安装并执行技能 **zacc-init-wiki-fronted**。

⚠️ 若检测到 **zacc-init-wiki-fronted 未安装**（可选，仅当环境中无该技能时输出）：
- 提醒：拓扑 Wiki 技能未安装，无法在本环境直接生成 `wiki/`；**不影响**本次初始化已完成的内容。
```

**非前端降级模式**（用户于步骤 0 选择继续后）：在上述摘要基础上，**必须**增加一行：

- `初始化模式：非前端降级（已征得用户同意继续）`

并将标题行改为例如：`✅ 项目 AI 初始化完成（zacc-init-fronted · 非前端降级）`。

---

## 纠错自学习机制

> 这不是初始化步骤，而是初始化后的持续行为。
> 此机制依赖 CLAUDE.md 中的「纠错记录」章节被 Claude Code 自动加载。

### 触发条件

用户对 AI 输出进行纠正时，识别以下信号：
- 用户说「不对」、「错了」、「不是这样」、「应该用 xxx」
- 用户说「这里要用 xxx 而不是 xxx」
- 用户撤销/拒绝 AI 的修改并给出正确做法
- 用户明确指出 AI 不理解项目的某个模式

### 执行动作

1. 提取纠错要点：错误是什么、正确做法是什么
2. 用 Edit 工具在 CLAUDE.md 的「纠错记录」章节追加一条记录：
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
