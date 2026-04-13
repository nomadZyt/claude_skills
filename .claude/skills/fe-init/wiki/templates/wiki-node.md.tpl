---
id: "{YYYYMMDD-HHMMSS}"
type: "{module|api|page|logic|legacy|foundation|config}"
title: "{module_title}"
path: "{relative_path}"
language: "{language}"
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
import_in: {N}
route_in: {N}
status: "{active|deprecated}"
last_scanned: "{ISO-8601}"
---

# {module_title}

## 概述

{一句话描述模块职责和在系统中的位置}

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

> 此章节由 `/fe-wiki-update legacy` 追加，记录代码中的技术债和不可触碰的逻辑。
> **规则**：只追加，不修改已有条目。

<!-- 初始化时为空，由 SOP-2 填充 -->
