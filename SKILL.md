---
name: nf-system
description: New Feature 系统 - 用 Markdown 规范驱动并行 Agent 开发。支持 NF 生命周期管理、多 Agent 协作、项目上下文加载。适合中大型项目开发。
metadata:
  openclaw:
    requires:
      tools: [read, write, edit, exec]
    optional:
      tools: [sessions_spawn, message]
---

# NF System - New Feature 开发系统

用 Markdown 规范驱动开发，支持并行运行 4-8 个 Coding Agent。

## 核心概念

每个功能一个 NF 文件（New Feature），包含：
- 问题描述
- 方案对比
- 实现计划
- 验证步骤

## 何时使用

### ✅ 适合
- 中大型项目（>1 万行代码）
- 多人协作（需要知识传承）
- 长期维护的项目
- 同时开发 3+ 个功能
- 工作量 > 4 小时的复杂功能

### ❌ 不适合
- < 1 小时的 bug 修复
- 探索性/实验性代码
- 超小项目（一人 + 几千行）

## 使用方式

### 初始化项目
```
帮我初始化 NF 系统
```

### 日常命令
| 命令 | 功能 |
|------|------|
| `/nf-new` | 创建新 NF |
| `/nf-status` | 查看所有 NF 状态 |
| `/nf-explore` | 加载项目上下文 |
| `/nf-verify` | 验证代码 |
| `/nf-close` | 关闭并归档 NF |
| `/nf-deep` | 并行深度分析 |

## 文件结构
```
project/
├── docs/features/
│   ├── FEATURE_INDEX.md
│   ├── TEMPLATE.md
│   ├── NF-001-xxx.md
│   └── archive/
├── .claude/commands/
│   ├── nf-new.md
│   ├── nf-status.md
│   └── ...
└── CLAUDE.md
```

## 最佳实践
- NF 粒度：Small 5-10 分钟，Medium 15-20 分钟，Large 30+ 分钟
- 并行上限：4-6 个 Agent（最多 8 个）
- Commit 格式：`NF-XXX: [动词] [描述]`

## 参考
- 原作者：Manuel Schipper
- 原文：https://schipper.ai/posts/parallel-coding-agents/
