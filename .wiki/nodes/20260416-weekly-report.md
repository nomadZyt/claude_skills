---
id: "20260416-weekly-report"
type: "module"
title: "Weekly Report"
path: ".claude/skills/weekly-report"
language: "Markdown"
dependencies: []
dependents: []
exports:
  - "/weekly-report"
import_in: 0
route_in: 0
status: "active"
last_scanned: "2026-04-16T14:30:00+08:00"
---

# Weekly Report — 众安车险周报生成器

## 概述

一个用于自动生成项目周报的 Claude Skill，可以分析 Git 提交记录并生成结构化的周报文档。

## 公开接口

| 名称 | 类型 | 签名 | 说明 |
|------|------|------|------|
| /weekly-report | command | `/weekly-report` | 生成周报 |

## 依赖关系

### 邻域图 (Neighborhood Graph)

```mermaid
graph LR
    SELF(["**Weekly Report**<br/>.claude/skills/weekly-report"])

    classDef self fill:#fff9c4,stroke:#f57f17,stroke-width:3px
    class SELF self
```

### 入度摘要

| 指标 | 值 | 含义 |
|------|:--:|------|
| import_in | 0 | 独立技能包 |
| route_in | 0 | 非页面模块 |

## 关键文件

| 文件 | 角色 | 说明 |
|------|------|------|
| SKILL.md | 入口 | 技能定义 |

## 设计决策

- 分析 Git 提交记录
- 按时间范围分类提交内容
- 生成结构化周报文档
