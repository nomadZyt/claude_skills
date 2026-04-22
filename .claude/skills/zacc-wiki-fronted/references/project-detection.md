# 多语言项目类型检测

> SOP-1 步骤 1 使用此文档。目标：自动识别项目类型、语言、入口文件、源代码根目录。

## 检测优先级表

按顺序检查以下文件。命中第一个即确定项目类型。多个命中表示混合项目。

| 优先级 | 检测文件 | 项目类型 | 语言 | 项目名称来源 |
|--------|----------|---------|------|-------------|
| 1 | `package.json` | Node.js / 前端 | JS/TS | `name` 字段 |
| 2 | `go.mod` | Go | Go | `module` 声明 |
| 3 | `Cargo.toml` | Rust | Rust | `[package].name` |
| 4 | `pom.xml` | Java Maven | Java | `<artifactId>` |
| 5 | `build.gradle` / `build.gradle.kts` | Java Gradle | Java/Kotlin | rootProject.name 或目录名 |
| 6 | `pyproject.toml` | Python (现代) | Python | `[project].name` |
| 7 | `setup.py` / `setup.cfg` | Python (传统) | Python | `name` 参数 |
| 8 | `requirements.txt` | Python (最小) | Python | 目录名 |
| 9 | `mix.exs` | Elixir | Elixir | `project[:app]` |
| 10 | `Gemfile` | Ruby | Ruby | `*.gemspec` name 或目录名 |
| 11 | `composer.json` | PHP | PHP | `name` 字段 |
| 12 | `*.csproj` / `*.sln` | .NET | C# | `<RootNamespace>` |
| 13 | `CMakeLists.txt` | C/C++ | C/C++ | `project()` 名称 |
| 14 | `pubspec.yaml` | Dart/Flutter | Dart | `name` 字段 |
| 15 | `Package.swift` | Swift | Swift | `name` 参数 |

## 源代码根目录识别

| 语言 | 常见源码目录（按优先级） |
|------|----------------------|
| JS/TS | `src/`, `app/`, `pages/`, `lib/` |
| Java | `src/main/java/`, `src/` |
| Go | 根目录, `cmd/`, `internal/`, `pkg/` |
| Python | `src/`, 与包名同名目录, 根目录 |
| Rust | `src/` |
| C# | `src/`, 与项目名同名目录 |
| PHP | `src/`, `app/` |
| Ruby | `lib/`, `app/` |
| C/C++ | `src/`, `lib/`, `include/` |

**检测方法**：
1. 用 Glob 检查上表中各目录是否存在
2. 选第一个命中的作为源码根
3. 如都不存在，用 AskUserQuestion 询问

## Monorepo 检测

| 信号 | Monorepo 类型 | 处理方式 |
|------|-------------|---------|
| `pnpm-workspace.yaml` | PNPM Workspace | 读取 `packages` 字段获取子包列表 |
| `lerna.json` | Lerna | 读取 `packages` 字段 |
| `nx.json` | Nx | 读取 `projects` 或扫描项目目录 |
| `turbo.json` | Turborepo | 结合 workspace 配置 |
| `go.work` | Go Workspace | 读取 `use` 声明 |
| 多个 `go.mod` | Go Multi-Module | Glob `**/go.mod` 列出 |
| `pom.xml` 含 `<modules>` | Maven Multi-Module | 读取 `<modules>` 子节点 |
| `build.gradle` 含 `include` | Gradle Multi-Project | 读取 `settings.gradle` 的 `include` |
| `Cargo.toml` 含 `[workspace]` | Cargo Workspace | 读取 `members` 字段 |

检测到 Monorepo 后，参考 `monorepo-strategies.md` 处理。

## TypeScript 检测

命中 `package.json` 后，额外检查：
- 是否存在 `tsconfig.json` → TypeScript 项目
- `package.json` 中 `devDependencies` 是否包含 `typescript`

如是 TypeScript，语言标记为 `TypeScript` 而非 `JavaScript`。

## 混合项目处理

一个仓库可能包含多种语言（如 Java 后端 + React 前端）。

**检测方法**：
1. 如果顶层同时命中多个入口文件（如 `pom.xml` + `package.json`），标记为混合项目
2. 用 AskUserQuestion 询问用户关注哪部分
3. 或按目录分别生成 Wiki 节点

## 项目描述提取

| 来源 | 提取方法 |
|------|---------|
| `README.md` | 读取第一个 `#` 标题后的首段文字 |
| `package.json` | `description` 字段 |
| `pyproject.toml` | `[project].description` |
| `Cargo.toml` | `[package].description` |
| `pom.xml` | `<description>` 标签 |

取第一个非空值作为项目描述。

## 未知项目类型

如果以上所有检测都未命中：
1. 用 Glob 列出根目录文件
2. 用 AskUserQuestion 展示文件列表，询问：
   - 项目使用什么语言/框架？
   - 源代码在哪个目录？
   - 项目名称是什么？
