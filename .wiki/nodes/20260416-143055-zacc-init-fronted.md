---
id: "20260416-143055"
type: foundation
title: "zacc-init-fronted"
path: ".claude/skills/zacc-init-fronted"
language: "Markdown"
dependencies: []
dependents:
  - "[[20260416-143056]]"
route_to: []
route_from: []
lazy_deps: []
exports:
  - "zacc-init-fronted"
import_in: 1
route_in: 0
status: active
last_scanned: "2026-04-16T14:30:55+08:00"
---

# zacc-init-fronted - 前端项目 AI 初始化

## 概述

为团队内部前端项目生成 AI 开发配置（CLAUDE.md + AI 红线），让 Claude Code 理解项目上下文并遵循现有开发模式。

## 公开接口

| 接口 | 类型 | 说明 |
|------|------|------|
| `zacc-init-fronted` | 技能 | 执行前端项目初始化 |

## 依赖关系

### 上游依赖
无

### 下游消费
- [[20260416-143056]] zacc-wiki-fronted — 配套技能，生成 `.wiki/`

## 关键文件

| 文件 | 角色 |
|------|------|
| `SKILL.md` | 技能定义和执行流程 |
| `references/tech-stack-detection.md` | 技术栈识别参考 |
| `references/ai-redlines.md` | AI 红线提取参考 |
| `references/non-frontend-degraded.md` | 非前端降级策略 |
| `templates/CLAUDE.md.tpl` | CLAUDE.md 模板 |
| `templates/AI_RULES.md.tpl` | AI 红线模板 |

## 设计决策

- 六维度分析：项目信息、结构、规范、数据流转、页面流转、红线
- 支持非前端项目降级初始化
- 增量更新策略：补缺失、更新过时、保留自定义

## 历史包袱 (Legacy Constraints)

（暂无）
