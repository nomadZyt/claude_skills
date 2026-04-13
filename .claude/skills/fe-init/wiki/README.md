# Project Topology Wiki

为任意技术栈项目生成 AI 专属的结构化知识图谱，让 AI 先理解再编码。

## 核心理念

**LLM Wiki + Harness Engineering**

- **LLM Wiki**：用机器友好的 YAML Frontmatter + 双链格式构建项目知识库，专为 AI Agent 消费设计
- **Harness Engineering**：通过硬规则约束 AI 行为——修改前必查 Wiki，禁止忽略历史包袱

## 解决什么问题

| 问题 | 解决方案 |
|------|---------|
| AI 不了解项目架构就开始改代码 | `/wiki-init` 先生成项目拓扑图 |
| AI 不知道哪些代码不能碰 | Legacy Constraints 记录历史包袱 |
| AI 修改模块不考虑影响范围 | `/wiki-query` 追踪上下游依赖 |
| 每次新会话都从零开始理解项目 | `.wiki/` 持久化知识，跨会话复用 |

## 快速开始

```bash
# 在任意项目中执行
/wiki-init
```

初始化完成后会在项目中生成：

```
.wiki/
├── index.md              # 全局拓扑索引（三层架构视图）
├── glossary.md           # 项目术语表
├── .wiki-state.json      # 增量更新状态
└── nodes/
    ├── 20260413-143052-user-service.md
    ├── 20260413-143053-auth-module.md
    └── ...
```

## 命令

| 命令 | 说明 |
|------|------|
| `/wiki-init` | 初始化项目拓扑 Wiki |
| `/wiki-query {问题}` | 架构感知查询（修改前必查） |
| `/wiki-update` | 增量扫描更新 |
| `/wiki-update legacy --node {名称} --constraint "描述"` | 记录历史包袱 |
| `/wiki-update refresh` | 全量重建（保留历史包袱） |

## 支持的语言

JavaScript/TypeScript, Java, Go, Python, Rust, C#/.NET, PHP, Ruby, Elixir, Dart/Flutter, Swift, C/C++

## 三个 SOP

### SOP-1: 项目拓扑初始化 (`/wiki-init`)

1. 自动检测项目类型（12+ 语言）
2. 扫描源码识别 Top-5 核心模块
3. Grep import 语句构建依赖图
4. 生成带 YAML Frontmatter 的知识节点
5. 输出三层架构视图（入口 → 业务 → 基础）

### SOP-2: 增量更新 (`/wiki-update`)

- 目录结构 hash 对比，只处理变更
- 历史包袱只追加不修改
- 支持节点新增/废弃/更新

### SOP-3: 架构感知查询 (`/wiki-query`)

**四条硬规则**：
1. 必须先读 Wiki 索引
2. 必须追踪上下游依赖
3. 必须合并 Legacy Constraints
4. 禁止未查 Wiki 直接给建议

## 节点元数据示例

```yaml
---
id: "20260413-143052"
type: module
title: "用户服务模块"
path: "src/services/user"
language: "TypeScript"
dependencies:
  - "[[20260413-143053]]"    # auth-module
dependents:
  - "[[20260413-143058]]"    # api-controller
exports:
  - "getUserById"
  - "createUser"
status: active
last_scanned: "2026-04-13T14:30:52+08:00"
---
```

## 与其他 Skill 协作

| Skill | 协作方式 |
|-------|---------|
| `/fe-init` | Wiki 是其超集，AI_RULES.md 和 Legacy Constraints 互补 |
| `/nf-new` | NF 可引用 Wiki 节点 |
| `/nf-explore` | 上下文加载可包含 Wiki 节点 |
