# /fe-wiki-init — 初始化项目拓扑 Wiki

## 目的

深度解析当前项目，在 `.wiki/` 生成 AI 专属的结构化知识图谱。支持 12+ 语言（JS/TS、Java、Go、Python、Rust 等）。

> 此命令在 `/fe-init` 执行时会自动触发（步骤 8）。也可单独执行。

## 执行流程（三阶段，防超时）

读取 `.claude/skills/fe-init/wiki/WIKI.md` 的 SOP-1 部分并按流程执行。

> **性能关键**：文件写入必须并行，禁止逐个串行。单轮最多 8 个文件并行写入。

### 阶段 A — 扫描分析（只读）
1. **项目类型检测** — 识别语言、框架、源码目录、Monorepo
2. **核心模块扫描** — 按引用次数/文件数/git活跃度排序，动态选取深度扫描范围
3. **依赖关系提取** — Grep import 语句构建内部依赖图

> 阶段 A 完成后，在内存中准备好所有文件内容。

### 阶段 B — 批量写入（并行）
4. **并行写入节点文件** — `.wiki/nodes/{id}-{slug}.md`（每批 <= 8 个）
5. **并行写入索引** — `index.md`（含 Mermaid 图谱）+ `glossary.md` + `.wiki-state.json`

### 阶段 C — 收尾
6. **追加 CLAUDE.md** — Edit 追加 Wiki 规则章节
7. **输出结果摘要**

## 参考文件

- `references/project-detection.md` — 多语言项目检测
- `references/module-extraction.md` — 模块提取策略
- `references/dependency-analysis.md` — 依赖分析方法
- `references/monorepo-strategies.md` — Monorepo 处理
- `templates/wiki-index.md.tpl` — 索引模板（含 Mermaid 图谱）
- `templates/wiki-node.md.tpl` — 节点模板（含邻域图）
- `templates/wiki-glossary.md.tpl` — 术语表模板
