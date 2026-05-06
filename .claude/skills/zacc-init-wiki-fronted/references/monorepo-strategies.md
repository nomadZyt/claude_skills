# Monorepo 处理策略

> SOP-1 步骤 1 检测到 Monorepo 时使用此文档。

## Monorepo 类型与解析

### JavaScript / TypeScript Workspace

| 工具 | 配置文件 | 子包列表来源 |
|------|---------|------------|
| pnpm | `pnpm-workspace.yaml` | `packages` 字段（glob 模式） |
| yarn | `package.json` workspaces | `workspaces` 字段 |
| npm | `package.json` workspaces | `workspaces` 字段 |
| lerna | `lerna.json` | `packages` 字段 |
| nx | `nx.json` + `workspace.json` | `projects` 或按目录扫描 |
| turbo | `turbo.json` | 结合 workspace 配置 |

**解析步骤**：
1. 读取配置文件获取 glob 模式（如 `packages/*`）
2. 用 Glob 展开，列出所有子包目录
3. 每个子包读取 `package.json` 获取名称和描述

### Go Workspace

| 工具 | 配置文件 | 子模块来源 |
|------|---------|----------|
| go.work | `go.work` | `use` 声明 |
| 多 go.mod | 多个 `go.mod` | `Glob("**/go.mod")` |

### Java Multi-Module

| 工具 | 配置文件 | 子模块来源 |
|------|---------|----------|
| Maven | 父 `pom.xml` | `<modules>` 子节点 |
| Gradle | `settings.gradle(.kts)` | `include` 声明 |

### Rust Workspace

| 配置 | 子 crate 来源 |
|------|-------------|
| `Cargo.toml` [workspace] | `members` 字段 |

## 处理策略

### 小型 Monorepo（<= 10 子包）

全部处理：
1. 每个子包作为一个 `type: module` 节点
2. `index.md` 增加 **Workspace 层**（在 Entry 层之上）
3. 子包间依赖从 `package.json` dependencies 提取

```
{project_name}
│
├── Workspace 层
│   ├── packages/app-a → wiki/nodes/{id}-app-a.md
│   ├── packages/app-b → wiki/nodes/{id}-app-b.md
│   └── packages/shared → wiki/nodes/{id}-shared.md
│
├── 入口层 (每个子包内部)
│   └── ...
└── ...
```

### 中型 Monorepo（11-50 子包）

选择性处理：
1. 用 AskUserQuestion 展示子包列表
2. 让用户选择 1-5 个关注的子包
3. 对选中的子包执行完整 SOP-1
4. 其余子包创建轻量索引节点（只有名称、路径、描述）

### 大型 Monorepo（> 50 子包）

聚焦处理：
1. 用 AskUserQuestion 让用户指定 1-3 个子包
2. 只对指定子包执行 SOP-1
3. 不创建其他子包的节点
4. 在 `index.md` 注明"此 Wiki 仅覆盖以下子包"

## 跨包依赖追踪

### JavaScript Workspace

```json
// packages/app-a/package.json
{
  "dependencies": {
    "@project/shared": "workspace:*"   // 内部依赖
  }
}
```

Grep 模式：搜索 `package.json` 中 `"workspace:` 或包名出现在 dependencies 中。

### Maven Multi-Module

```xml
<!-- module-a/pom.xml -->
<dependency>
    <groupId>${project.groupId}</groupId>
    <artifactId>module-b</artifactId>
</dependency>
```

Grep 模式：搜索 `<artifactId>` 匹配项目内其他模块。

### Go Workspace

Go workspace 内模块直接通过 module path 引用，同普通 Go 依赖分析。

## 节点路径格式

Monorepo 中节点 `path` 使用项目根相对路径：

```yaml
path: "packages/app-a/src/services/user"   # 不是 "src/services/user"
```

## 术语表处理

跨子包的术语表合并到一个 `glossary.md`，每个术语标注所属子包。
