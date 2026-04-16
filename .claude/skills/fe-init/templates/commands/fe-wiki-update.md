# /fe-wiki-update — 增量更新 Wiki

## 目的

增量更新 `.wiki/` 知识图谱，记录历史包袱，管理节点生命周期。

## 子命令

| 子命令 | 用法 | 说明 |
|--------|------|------|
| `scan` | `/fe-wiki-update scan` | 增量扫描，检测变更（默认） |
| `legacy` | `/fe-wiki-update legacy --node {名称} --constraint "描述"` | 记录历史包袱 |
| `node add` | `/fe-wiki-update node add --path {path}` | 新增节点 |
| `node deprecate` | `/fe-wiki-update node deprecate --id {id}` | 废弃节点 |
| `node update` | `/fe-wiki-update node update --id {id}` | 重新扫描节点 |
| `refresh` | `/fe-wiki-update refresh` | 全量重建（保留历史包袱） |

## 步骤

读取 `.claude/skills/fe-init/wiki/WIKI.md` 的 SOP-2 部分并按流程执行。

## 参考文件

- `references/legacy-constraint-patterns.md` — 历史包袱识别模式
- `templates/wiki-legacy-section.md.tpl` — 历史包袱条目模板
