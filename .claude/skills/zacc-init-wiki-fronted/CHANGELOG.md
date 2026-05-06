# 更新日志

## 更新日志

### v1.0.0（2026‑04‑16）

- **初始版本发布**
  - 统一入口交互：`/zacc-init-wiki-fronted` 一个入口自动分流初始化/增量更新/查询三种 SOP。
  - SOP-1 项目拓扑初始化：项目类型检测（含 Taro 小程序识别）、核心模块扫描、依赖关系提取（import/route/dynamic 三层边）、节点文件生成（深度节点 + 轻量节点）、全局索引（index.md + index.json）、术语表、状态快照。
  - SOP-2 增量更新与冲突记录：支持 `scan`（增量扫描）、`legacy`（历史包袱记录）、`node add`、`node deprecate`、`node update`、`refresh`（全量重建保留历史包袱）六个子命令。
  - SOP-3 架构感知查询：Wiki-first 检索协议，强制读取索引 → 收敛候选 → 读邻居 → 定向代码校验 → 有限扩圈，查询结果必须包含上下游依赖和历史包袱提醒。
  - 节点元数据契约：身份字段、检索字段、关系字段、质量字段四类元数据。
  - 性能优化：并行写入节点文件（单轮最多 8 个），浅扫描 + 入口文件优先。
  - 与 `zacc-init-fronted` 互补：Wiki 与 CLAUDE.md / AI_RULES.md 协同。
  - 包含 7 份参考文档和 4 份模板文件。

### v1.0.1（2026‑04‑29）

- **输出目录重命名**
  - 将 Wiki 产出目录从 `.wiki/` 改为 `wiki/`，去除隐藏目录前缀，提升可见性。
  - 涉及文件：`SKILL.md`、`USAGE.md`、`references/operational-guidelines.md`、`references/monorepo-strategies.md`、`templates/wiki-index.md.tpl`。

### v1.0.2（2026‑04‑30）

- **评分优化（基于内部评分报告）**
  - 版本号治理：修复 SKILL.md frontmatter 版本号与 CHANGELOG 不一致的问题。
  - SKILL.md 主文件瘦身：将 SOP-1 步骤 4/5 的执行细节（并行写入策略、节点正文结构、Mermaid 生成规则）下沉到 `references/operational-guidelines.md`，主文件只保留流程骨架。
  - 节点元数据契约补齐：在「检索字段」中补入 `exports`（之前只在模板中出现、未纳入契约清单）。
  - 新增扫描中间产物 Schema：定义阶段 A（项目检测 → 模块扫描 → 依赖分析）之间的统一内存结构，支持断点恢复。
  - 新增冲突合并策略：规定 `scan` / `refresh` / `node update` 在用户手改节点后的保留规则（历史包袱、自定义章节、字段级补注）。
  - 新增 Mermaid 大型项目降级策略：按深度节点数量分 4 档（≤15 / 16–30 / 31–60 / >60）定义依赖关系图渲染策略，避免大型项目出图不可读。
  - 节点模板强制章节顺序：`wiki-node.md.tpl` 顶部以 HTML 注释形式注明 7 章节的严格顺序约束，并指向 operational-guidelines.md 对应小节。
  - 交叉引用补齐：SKILL.md 「动态分层」段末明确指向 SOP-2 的 `node update` 子命令，完善轻量 → 深度节点的升级路径。

