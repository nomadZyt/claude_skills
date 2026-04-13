# /wiki-init — 初始化项目拓扑 Wiki

## 目的

深度解析当前项目，生成 AI 专属的结构化知识图谱（`.wiki/`），让 AI 在编码前先理解项目架构。

## 前置检查

- 如果 `.wiki/` 已存在，询问用户：增量更新（推荐）/ 全量重建 / 取消
- 增量更新 → 转到 `/fe-wiki-update scan`
- 全量重建 → 继续执行以下步骤

## 执行流程（三阶段）

读取 `.claude/skills/fe-init/wiki/WIKI.md` 的 SOP-1 部分。

> **性能关键**：严格按三阶段执行，文件写入必须并行，禁止逐个串行写入。

### 阶段 A — 扫描分析（只读，不写任何文件）

1. **项目类型检测** — Glob 根目录 + Read 配置文件（参考 `references/project-detection.md`）
2. **核心模块扫描** — Glob 源码目录 + Grep 引用计数 + Read 入口文件（参考 `references/module-extraction.md`）
3. **依赖关系提取** — Grep import 语句，构建依赖图（参考 `references/dependency-analysis.md`）

> 阶段 A 完成后，所有分析结果应在内存中就绪，准备好所有节点的完整内容。

### 阶段 B — 批量生成文件（并行写入）

4. **并行写入节点文件** — 在同一轮工具调用中并行 Write 所有节点（每批 <= 8 个文件），模板 `templates/wiki-node.md.tpl`
5. **并行写入索引文件** — index.md（含 Mermaid 图谱）+ glossary.md + .wiki-state.json，与最后一批节点一起并行写入

### 阶段 C — 收尾

6. **追加 CLAUDE.md 规则** — 如有 CLAUDE.md 则 Edit 追加 Wiki 章节
7. **输出结果摘要**

## 参考文件

- `references/project-detection.md` — 多语言项目类型检测
- `references/module-extraction.md` — 核心模块提取策略
- `references/dependency-analysis.md` — 依赖关系分析方法
- `references/monorepo-strategies.md` — Monorepo 处理策略
- `templates/wiki-index.md.tpl` — 索引模板（含 Mermaid 图谱）
- `templates/wiki-node.md.tpl` — 节点模板（含邻域图）
- `templates/wiki-glossary.md.tpl` — 术语表模板
