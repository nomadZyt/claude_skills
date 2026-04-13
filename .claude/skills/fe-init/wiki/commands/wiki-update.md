# /wiki-update — 增量更新 Wiki

## 目的

增量更新项目拓扑 Wiki，记录历史包袱，管理节点生命周期。

## 子命令

| 子命令 | 用法 | 说明 |
|--------|------|------|
| `scan` | `/wiki-update scan` | 增量扫描，检测结构变更并更新 |
| `legacy` | `/wiki-update legacy --node {id或名称} --constraint "描述"` | 记录历史包袱 |
| `node add` | `/wiki-update node add --path {path}` | 新增节点 |
| `node deprecate` | `/wiki-update node deprecate --id {id}` | 废弃节点 |
| `node update` | `/wiki-update node update --id {id}` | 重新扫描节点 |
| `refresh` | `/wiki-update refresh` | 全量重建（保留历史包袱） |

不带子命令时默认执行 `scan`。

## 步骤

读取 `.claude/skills/fe-init/wiki/WIKI.md` 的 SOP-2 部分。

### scan（增量扫描）

1. 读取 `.wiki/.wiki-state.json`（不存在则提示先执行 `/wiki-init`）
2. 重新生成目录结构 hash，与存储的 hash 对比
3. 仅对变更模块重新执行模块提取和依赖分析
4. 更新对应节点文件（保留历史包袱章节）
5. 重新生成 index.md

### legacy（记录历史包袱）

核心原则：**绝不修改节点已有内容，只追加 Legacy Constraints。**

1. 定位目标节点（按 id 或名称匹配）
2. 读取 `templates/wiki-legacy-section.md.tpl`
3. 在节点的 `## 历史包袱 (Legacy Constraints)` 章节追加新条目
4. 更新 index.md 的"含历史包袱的模块"列表

### refresh（全量重建）

1. 备份所有现有节点的历史包袱章节
2. 执行完整 SOP-1
3. 将备份的历史包袱按 path 回写到对应新节点
4. 无法匹配的历史包袱归入 index.md 的"孤立历史包袱"章节

## 参考文件

- `references/legacy-constraint-patterns.md` — 历史包袱识别模式
- `templates/wiki-legacy-section.md.tpl` — 历史包袱条目模板
