# AI 红线规则

> 本文件由 `/fe-init` 自动生成，记录 AI 修改/添加代码时必须遵守的规则。
> 生成时间：2026-04-16
> 最后更新：2026-04-16

---

## 1. 技术栈红线

### 项目类型

这是一个 **Claude Skills 仓库**，不是标准前端项目。没有 `package.json`、构建配置或 lock 文件。

### 禁止操作

- 不得创建 `package.json` 或其他前端项目配置文件
- 不得引入 npm/yarn/pnpm 依赖
- 不得创建构建配置文件
- 不得将此项目当作标准前端项目处理

---

## 2. 架构模式红线

### 目录规范

| 文件类型 | 目标目录 |
|---------|---------|
| 技能定义文件 | `.claude/skills/{skill-name}/SKILL.md` |
| 斜杠命令 | `.claude/commands/{command-name}.md` |
| NF 功能文档 | `docs/features/NF-XXX-*.md` |
| 开发规范 | `docs/dev_guide/` |
| 参考文档 | `.claude/skills/{skill-name}/references/` |
| 模板文件 | `.claude/skills/{skill-name}/templates/` |

### 技能文件规范

每个技能包必须包含：
- `SKILL.md` — 技能定义文件（必须包含 YAML Frontmatter）
- `README.md` — 使用说明（可选）
- `references/` — 参考文档目录（可选）
- `templates/` — 模板文件目录（可选）

### Frontmatter 规范

技能定义文件必须包含以下 Frontmatter 字段：

```yaml
---
name: {skill-name}
description: "{技能描述}"
user-invocable: true|false
disable-model-invocation: true|false
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
version: "{版本号}"
tags: ["标签1", "标签2"]
---
```

---

## 3. 代码风格红线

### 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 技能目录 | kebab-case | `fe-init`, `nf-system` |
| 技能文件 | 大写 SKILL.md | `SKILL.md` |
| 命令文件 | kebab-case | `fe-init.md` |
| 文档文件 | kebab-case | `tech-stack-detection.md` |

### Markdown 规范

- 使用标准 Markdown 格式
- 标题层级清晰（H1 > H2 > H3）
- 代码块指定语言
- 表格使用标准格式

### 格式规范

| 项目 | 规则 |
|------|------|
| 缩进 | 2 空格 |
| 引号 | 单引号（YAML 中使用双引号） |
| 换行 | LF（Unix 风格） |

---

## 4. 业务逻辑红线

### 技能包边界

- 每个技能包应该是独立、自包含的
- 技能之间通过斜杠命令协作，不直接引用内部文件
- 新增技能必须在 `.claude/skills/` 下创建独立目录

### NF 系统

- 所有功能开发先创建 NF 文件（>4 小时的工作）
- NF 状态流转：Planned → Design → Open → In Progress → Pending Verification → Complete
- 每个 commit 关联 NF 编号
- 完成后更新 FEATURE_INDEX.md 并归档

---

## 5. 功能修改确认规则

以下操作在执行前**必须使用 AskUserQuestion 弹窗确认**：

| 操作 | 影响范围 |
|------|---------|
| 删除或重命名现有技能包 | 所有使用者 |
| 修改现有技能的 Frontmatter | 技能加载行为 |
| 修改斜杠命令定义 | 命令执行行为 |
| 删除或移动 NF 文档 | 功能追踪 |
| 修改项目根目录 CLAUDE.md | 项目配置 |

---

## 附录：项目特有规则

### 技能开发

1. 新建技能必须先阅读现有技能的结构（参考 `nf-system` 或 `fe-init`）
2. 技能的 `allowed-tools` 必须明确声明，避免过度权限
3. 技能描述必须准确反映功能，避免误导

### 文档规范

1. README.md 应包含：前置要求、安装步骤、使用方法、功能说明
2. 参考文档放在 `references/` 目录
3. 模板文件放在 `templates/` 目录

### Git 操作

1. Commit 信息使用 `feat:` 前缀或 `NF-XXX:` 格式
2. 重要修改应更新相关文档
3. 不要提交敏感信息（如 token、密码）
