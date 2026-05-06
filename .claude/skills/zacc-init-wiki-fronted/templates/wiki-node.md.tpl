---
id: "{stable_id}"
slug: "{slug}"
type: "{module|api|page|component|hook|store|logic|legacy|foundation|config}"
title: "{module_title}"
path: "{relative_path}"
previous_paths:
  - "{previous_path}"
language: "{language}"
aliases:
  - "{alias}"
tags:
  - "{tag}"
module_kind: "{page|component|hook|store|service|api|util|context|constant|config}"
layer: "{entry|business|foundation|cross-cutting}"
key_files:
  - "{key_file}"
related_paths:
  - "{related_path}"
dependencies:
  - "[[{dep_id}]]"    # import: {dep_title}
dependents:
  - "[[{dep_id}]]"    # import: {dep_title}
route_to:
  - "[[{dep_id}]]"    # route → {dep_title}
route_from:
  - "[[{dep_id}]]"    # route ← {dep_title}
lazy_deps:
  - "[[{dep_id}]]"    # dynamic: {dep_title}
exports:
  - "{function_or_class_name}"
search_hints:
  - "{symbol_or_keyword}"
import_in: {N}
route_in: {N}
status: "{active|deprecated}"
coverage: "{deep|light}"
confidence: "{high|medium|low}"
freshness: "{fresh|partial|stale}"
created_at: "{ISO-8601}"
last_scanned: "{ISO-8601}"
---

<!--
章节顺序约束（深度节点必须严格按以下顺序生成；轻量节点只保留 1 和「文件列表」）：
  1. 概述
  2. 快速定位
  3. 公开接口
  4. 依赖关系（含邻域图、静态引用、路由跳转、入度摘要）
  5. 关键文件
  6. 设计决策
  7. 历史包袱 (Legacy Constraints)

用户自定义章节（非上述 7 项）必须附加在「历史包袱」之后。
详见 references/operational-guidelines.md#阶段-b节点写入执行策略 与 #阶段-c冲突合并策略用户手改保护。
-->

# {module_title}

## 概述

{一句话描述模块职责和在系统中的位置}

## 快速定位

| 字段 | 内容 |
|------|------|
| 别名 | {alias_list} |
| 标签 | {tag_list} |
| 推荐先读 | `{key_file}` |
| 邻近路径 | `{related_path}` |
| 搜索提示 | `{symbol_or_keyword}` |

## 公开接口

| 名称 | 类型 | 签名 | 说明 |
|------|------|------|------|
| {name} | function/class/method | `{signature}` | {说明} |

## 依赖关系

### 邻域图 (Neighborhood Graph)

> 以本模块为中心，展示直接上下游关系。
> 实线箭头 = import 依赖；虚线箭头 = 路由跳转。

```mermaid
graph LR
    %% import 上游（本模块静态引用的）
    {upstream_id_1}("{upstream_title_1}") -->|"import"| SELF
    {upstream_id_2}("{upstream_title_2}") -->|"import"| SELF

    %% 本模块
    SELF(["**{module_title}**<br/>{relative_path}"])

    %% import 下游（静态引用本模块的）
    SELF -->|"import"| {downstream_id_1}("{downstream_title_1}")

    %% 路由跳转（如有）
    SELF -.->|"route"| {route_target_id}("{route_target_title}")
    {route_source_id}("{route_source_title}") -.->|"route"| SELF

    %% 样式
    classDef self fill:#fff9c4,stroke:#f57f17,stroke-width:3px
    classDef upstream fill:#e3f2fd,stroke:#1565c0
    classDef downstream fill:#e8f5e9,stroke:#2e7d32
    classDef route fill:#f3e5f5,stroke:#6a1b9a

    class SELF self
    class {upstream_ids} upstream
    class {downstream_ids} downstream
    class {route_ids} route
```

### 静态引用（Import）

| 关系 | 模块 | 节点链接 | 用途 |
|------|------|---------|------|
| 本模块依赖 | {dep_title} | [[{dep_id}]] | {为什么依赖它} |
| 依赖本模块 | {dep_title} | [[{dep_id}]] | {怎么使用本模块} |

### 路由跳转（Route）

> 仅前端项目。路由跳转入度反映页面被使用的频率，与 import 入度独立统计。

| 方向 | 模块 | 节点链接 | 跳转方式 |
|------|------|---------|---------|
| 本页面跳转到 | {dep_title} | [[{dep_id}]] | router.push / Link |
| 其他页面跳转到本页 | {dep_title} | [[{dep_id}]] | router.push / Link |

### 入度摘要

| 指标 | 值 | 含义 |
|------|:--:|------|
| import_in | {N} | 被多少模块静态引用（代码耦合度） |
| route_in | {N} | 被多少页面路由跳转到（业务使用频率） |

## 关键文件

| 文件 | 角色 | 说明 |
|------|------|------|
| {file_path} | 入口/核心/配置/测试 | {文件职责} |

## 设计决策

> 从代码注释、README、命名模式推断的设计选择。如无法推断则标注"待补充"。

- {决策 1}：{说明}
- {决策 2}：{说明}

## 历史包袱 (Legacy Constraints)

> 此章节由 **zacc-init-wiki-fronted** 选「增量更新 → **legacy**」追加，记录代码中的技术债和不可触碰的逻辑。
> **规则**：只追加，不修改已有条目。

<!-- 初始化时为空，由 SOP-2 填充 -->
