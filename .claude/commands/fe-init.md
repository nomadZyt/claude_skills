# /fe-init — 前端项目 AI 初始化

## 目的

为前端项目生成 AI 开发配置（CLAUDE.md + .claude/AI_RULES.md）+ 项目拓扑 Wiki（.wiki/），让 Claude Code 理解项目上下文并遵循现有开发模式。

## 步骤

读取 `.claude/skills/fe-init/SKILL.md` 并按以下流程执行：

1. **项目信息收集** — 读取 package.json、构建配置、lock 文件，识别技术栈
2. **项目结构分析** — 扫描 src/ 目录，识别组织模式
3. **代码规范提取** — 读取 ESLint/Prettier/tsconfig 配置，推断命名风格和 commit 规范
4. **数据流转 + 页面流转分析** — 追踪数据链路和页面跳转模式（参考 references/ 目录下的分析方法）
5. **AI 红线分析** — 基于分析结果提取技术栈/架构/风格/业务逻辑红线
6. **生成/更新文件** — 输出 CLAUDE.md 和 .claude/AI_RULES.md（已有文件则增量更新）
7. **输出结果** — 展示分析摘要和红线规则
8. **生成项目拓扑 Wiki** — 读取 `wiki/WIKI.md` SOP-1，复用步骤 1-2 数据，生成 `.wiki/`（含 Mermaid 图谱）

## 参考文件

**fe-init 核心**：
- `references/tech-stack-detection.md` — 技术栈识别方法
- `references/data-flow-analysis.md` — 数据流转分析方法
- `references/page-flow-analysis.md` — 页面流转分析方法
- `references/business-features.md` — 业务特性识别
- `references/ai-redlines.md` — 红线规则提取方法
- `templates/CLAUDE.md.tpl` — CLAUDE.md 生成模板
- `templates/AI_RULES.md.tpl` — AI_RULES.md 生成模板

**Wiki 图谱（步骤 8）**：
- `wiki/references/module-extraction.md` — 模块提取策略
- `wiki/references/dependency-analysis.md` — 依赖分析方法
- `wiki/templates/wiki-index.md.tpl` — 索引模板（含 Mermaid 图谱）
- `wiki/templates/wiki-node.md.tpl` — 节点模板

## Wiki 独立命令

Wiki 也可单独使用，无需重新执行 fe-init：

| 命令 | 说明 |
|------|------|
| `/fe-wiki-init` | 单独初始化/重建 Wiki |
| `/fe-wiki-query {问题}` | 架构感知查询 |
| `/fe-wiki-update` | 增量更新 Wiki |
