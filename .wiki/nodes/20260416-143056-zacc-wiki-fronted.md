---
id: "20260416-143056"
type: foundation
title: "zacc-wiki-fronted"
path: ".claude/skills/zacc-wiki-fronted"
language: "Markdown"
dependencies:
  - "[[20260416-143055]]"
dependents: []
route_to: []
route_from: []
lazy_deps: []
exports:
  - "zacc-wiki-fronted"
  - "/zacc-wiki-fronted"
import_in: 0
route_in: 0
status: active
last_scanned: "2026-04-16T14:30:56+08:00"
---

# zacc-wiki-fronted - 项目拓扑 Wiki 生成

## 概述

为任意技术栈项目生成结构化的 AI 专属知识图谱，存储在 `.wiki/`，与业务代码完全解耦。

## 公开接口

| 接口 | 类型 | 说明 |
|------|------|------|
| `zacc-wiki-fronted` | 技能 | 统一入口，支持初始化/查询/增量更新 |
| `/zacc-wiki-fronted` | 命令 | 斜杠命令入口 |

## 依赖关系

### 上游依赖
- [[20260416-143055]] zacc-init-fronted — 配套技能，生成 CLAUDE.md

### 下游消费
无

## 关键文件

| 文件 | 角色 |
|------|------|
| `SKILL.md` | 技能定义和 SOP 流程 |
| `references/project-detection.md` | 项目类型检测策略 |
| `references/module-extraction.md` | 模块提取算法 |
| `references/dependency-analysis.md` | 依赖关系分析方法 |
| `references/legacy-constraint-patterns.md` | 历史包袱识别模式 |
| `references/monorepo-strategies.md` | Monorepo 处理策略 |
| `templates/wiki-node.md.tpl` | Wiki 节点模板 |
| `templates/wiki-index.md.tpl` | Wiki 索引模板 |
| `templates/wiki-glossary.md.tpl` | 术语表模板 |

## 设计决策

- 三层边模型：import / route / dynamic
- 统一入口分流：初始化 / 查询 / 增量更新
- 节点元数据契约：YAML Frontmatter + 规范字段
- 历史包袱只追加不覆盖

## 历史包袱 (Legacy Constraints)

（暂无）
