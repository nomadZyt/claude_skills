---
id: "20260416-task-scheduler"
type: "module"
title: "Task Scheduler"
path: ".claude/skills/task-scheduler"
language: "Markdown"
dependencies:
  - "[[20260416-nf-system]]"
dependents: []
exports:
  - "/task-scheduler"
import_in: 0
route_in: 0
status: "active"
last_scanned: "2026-04-16T14:30:00+08:00"
---

# Task Scheduler — 多任务并发调度器

## 概述

基于 Team 机制自动创建 NF 并管理多个 Agent 并发执行的技能包。

## 公开接口

| 名称 | 类型 | 签名 | 说明 |
|------|------|------|------|
| /task-scheduler | command | `/task-scheduler` | 启动多任务调度器 |

## 依赖关系

### 邻域图 (Neighborhood Graph)

```mermaid
graph LR
    NF(["NF System"]) -->|"uses"| SELF
    SELF(["**Task Scheduler**<br/>.claude/skills/task-scheduler"])

    classDef self fill:#fff9c4,stroke:#f57f17,stroke-width:3px
    classDef upstream fill:#e3f2fd,stroke:#1565c0

    class SELF self
    class NF upstream
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
| templates/ | 模板 | 任务模板 |

## 设计决策

- 基于 Claude Code Team 机制
- 自动创建和管理 NF
- 支持多 Agent 并发执行
