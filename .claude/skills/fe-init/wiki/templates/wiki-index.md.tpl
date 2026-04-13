---
project: "{project_name}"
type: "{project_type}"
language: "{language}"
monorepo: {true|false}
generated: "{ISO-8601}"
last_updated: "{ISO-8601}"
node_count: {N}
---

# {project_name} — 项目拓扑索引

> 此文件由 `/wiki-init` 自动生成，是 AI 理解项目架构的入口。
> 修改任何模块前，**必须**先阅读此文件。

---

## 概念层次图 (Concept Hierarchy)

> 展示项目的分层架构：入口层 → 业务层 → 基础层。
> 方框 = 架构层级，圆角框 = 具体模块。

```mermaid
graph TD
    subgraph Entry["🔵 入口层 (Entry)"]
        {entry_id_1}["{entry_title_1}"]
        {entry_id_2}["{entry_title_2}"]
    end

    subgraph Business["🟢 业务层 (Business)"]
        {biz_id_1}["{biz_title_1}"]
        {biz_id_2}["{biz_title_2}"]
        {biz_id_3}["{biz_title_3}"]
    end

    subgraph Foundation["🟠 基础层 (Foundation)"]
        {found_id_1}["{found_title_1}"]
        {found_id_2}["{found_title_2}"]
    end

    Entry --> Business
    Business --> Foundation
```

---

## 模块依赖关系图 (Entity Relationship Graph)

> 展示模块间的真实依赖关系。
> 实线箭头 `→` = import 静态依赖；虚线箭头 `-.->` = 路由跳转关系。
> 两类边的入度含义不同，图中颜色区分：蓝=入口/页面，绿=业务，橙=基础，红=废弃。

```mermaid
graph LR
    %% 节点定义
    {id_1}("{title_1}<br/><small>{path_1}</small>")
    {id_2}("{title_2}<br/><small>{path_2}</small>")
    {id_3}("{title_3}<br/><small>{path_3}</small>")

    %% import 依赖（实线）
    {id_1} -->|"import"| {id_2}
    {id_1} -->|"import"| {id_3}

    %% 路由跳转（虚线，仅前端）
    {id_2} -.->|"route"| {id_3}

    %% 样式
    classDef entry fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    classDef business fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
    classDef foundation fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef deprecated fill:#fce4ec,stroke:#c62828,stroke-dasharray:5

    class {entry_ids} entry
    class {biz_ids} business
    class {found_ids} foundation
```

---

## 依赖热力矩阵 (Dependency Heatmap)

> **两个维度独立统计，不合并**：
> - `import_in` = 静态引用入度（被多少模块 import），反映**代码耦合度**
> - `route_in` = 路由跳转入度（被多少页面跳转到），反映**业务使用频率**
>
> 页面类模块通常 import_in ≈ 0（路由懒加载），但 route_in 可能很高——这是正常的，不代表该模块"不重要"。

### Import 依赖矩阵（代码耦合）

> 行 = 调用方，列 = 被调用方。`●` = 存在 import 依赖，`◌` = 无。

| 模块 ↓ import → | {title_1} | {title_2} | {title_3} | {title_4} | 出度 |
|----------------|:---------:|:---------:|:---------:|:---------:|:----:|
| **{title_1}** | — | ● | ◌ | ● | 2 |
| **{title_2}** | ◌ | — | ● | ◌ | 1 |
| **{title_3}** | ◌ | ◌ | — | ◌ | 0 |
| **{title_4}** | ● | ● | ● | — | 3 |
| **import_in** | 1 | 2 | 2 | 1 | — |

### 路由跳转矩阵（业务使用频率）

> 行 = 跳转发起方（页面），列 = 跳转目标（页面）。`→` = 存在跳转，`◌` = 无。
> 仅前端项目，非页面类模块此表为空。

| 页面 ↓ 跳转 → | {page_1} | {page_2} | {page_3} | route_out |
|--------------|:--------:|:--------:|:--------:|:---------:|
| **{page_1}** | — | → | ◌ | 1 |
| **{page_2}** | ◌ | — | → | 1 |
| **{page_3}** | ◌ | ◌ | — | 0 |
| **route_in** | 0 | 1 | 1 | — |

### 核心模块速查

> 按风险分类，辅助评估修改影响范围。

| 模块 | import_in | route_in | 分类 | 修改风险 |
|------|:---------:|:--------:|------|---------|
| {title} | {N} | {N} | 基础设施 / 高频页面 / 聚合模块 | 🔴 高 / 🟡 中 / 🟢 低 |

> **分类规则**：
> - `import_in ≥ 5` → **基础设施**，改动影响面广，需全局回归
> - `route_in ≥ 5` → **高频页面**，改动影响用户主路径
> - 出度高且入度低 → **聚合模块**，依赖多方但自身不被依赖，易受上游变更

---

## 分层架构视图 (Text)

```
{project_name}
│
├── 入口层 (Entry)
│   ├── {entry_module_1} → .wiki/nodes/{id_1}-{slug_1}.md
│   └── {entry_module_2} → .wiki/nodes/{id_2}-{slug_2}.md
│
├── 业务层 (Business)
│   ├── {biz_module_1} → .wiki/nodes/{id_3}-{slug_3}.md
│   ├── {biz_module_2} → .wiki/nodes/{id_4}-{slug_4}.md
│   └── {biz_module_3} → .wiki/nodes/{id_5}-{slug_5}.md
│
└── 基础层 (Foundation)
    ├── {foundation_1} → .wiki/nodes/{id_6}-{slug_6}.md
    └── {foundation_2} → .wiki/nodes/{id_7}-{slug_7}.md
```

---

## 模块关系总表

| ID | 名称 | 类型 | 路径 | import_in | route_in | 出度 | 状态 |
|----|------|------|------|:---------:|:--------:|:----:|------|
| {id} | {title} | {type} | {path} | {import_in} | {route_in} | {out} | {status} |

> `import_in` = 代码耦合入度（静态 import 计数）；`route_in` = 业务使用入度（路由跳转计数，仅前端）。页面类模块 import_in 通常为 0，以 route_in 判断重要性。

---

## 快速导航

### 按类型

**入口模块 (entry)**：
- [{title}](nodes/{id}-{slug}.md) — {一句话概述}

**业务模块 (module)**：
- [{title}](nodes/{id}-{slug}.md) — {一句话概述}

**基础模块 (foundation)**：
- [{title}](nodes/{id}-{slug}.md) — {一句话概述}

**API 模块 (api)**：
- [{title}](nodes/{id}-{slug}.md) — {一句话概述}

**配置模块 (config)**：
- [{title}](nodes/{id}-{slug}.md) — {一句话概述}

### 核心枢纽模块（入度 >= 3）

> 以下模块被 3 个以上模块依赖，是系统的核心支撑。修改前必须评估全局影响。

- [{title}](nodes/{id}-{slug}.md) — 入度 {N}，被 {module_list} 依赖

### 含历史包袱的模块

> 以下模块包含 Legacy Constraints，修改前务必仔细阅读。

- [{title}](nodes/{id}-{slug}.md) — {constraint_count} 条约束

---

## 图谱生成说明

> **Mermaid 渲染**：上方图谱使用 Mermaid 语法。支持在 GitHub、VS Code（Markdown Preview Mermaid 插件）、Obsidian 等环境中直接渲染。
>
> **图谱更新**：执行 `/wiki-update scan` 或 `/wiki-update refresh` 时会自动重新生成图谱。
>
> **AI 消费方式**：AI 读取此文件时，会同时解析 Mermaid 代码块中的节点和边关系，用于理解模块间的依赖拓扑。Mermaid 的结构化语法对 AI 来说是高密度的关系表达。
