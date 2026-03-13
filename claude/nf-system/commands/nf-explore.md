# /nf-explore - 加载项目上下文

## 目的
为新 Agent 会话加载完整的项目上下文。

## 要加载的文件

1. **CLAUDE.md** - 项目约定
2. **docs/features/FEATURE_INDEX.md** - 所有 NF 概览
3. **项目配置文件** - 根据项目类型自动检测（见下方）
4. **项目结构** - 列出关键目录
5. **用户提到的任何 NF**

## 步骤

### 1. 读取核心文件
```
- CLAUDE.md
- docs/features/FEATURE_INDEX.md
```

### 2. 自动检测并加载项目配置
按优先级检测项目类型，加载对应的配置文件：

| 检测文件 | 项目类型 | 需加载的配置 |
|----------|---------|-------------|
| `package.json` | Node.js | `package.json`、`tsconfig.json`（如有） |
| `pyproject.toml` | Python | `pyproject.toml` |
| `requirements.txt` | Python | `requirements.txt` |
| `go.mod` | Go | `go.mod` |
| `Cargo.toml` | Rust | `Cargo.toml` |
| `pom.xml` | Java (Maven) | `pom.xml`（仅依赖部分） |
| `build.gradle` / `build.gradle.kts` | Java (Gradle) | `build.gradle` / `build.gradle.kts` |
| `mix.exs` | Elixir | `mix.exs` |
| `Gemfile` | Ruby | `Gemfile` |
| `composer.json` | PHP | `composer.json` |

如果以上都不存在，跳过此步并提示用户手动指定。

### 3. 列出项目结构
运行 `ls` 或使用 Glob 工具展示顶层目录结构。

### 4. 检查进行中的 NF
- 注意任何 "In Progress" 的 NF
- 注意任何 "Pending Verification" 的 NF

### 5. 提示用户
```
✅ 上下文已加载

项目类型：[自动检测结果]

进行中的 NF:
- NF-001: [标题] (状态：Open)
- NF-002: [标题] (状态：In Progress)

你想做什么？
- "实现 NF-XXX"
- "设计 NF-XXX"
- "创建新 NF"
```

## 提示

- 高效加载上下文（不要读取每个文件）
- 按需读取特定 NF 文件
- 记住已加载的上下文以回答后续问题
