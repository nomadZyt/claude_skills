# claude_skills — Claude Skills 仓库

> **初始化模式：非前端降级（zacc-init-fronted）**

## 项目概述

这是一个 Claude Skills 仓库，包含多个可复用的技能包（nf-system、zacc-init-fronted、task-scheduler、weekly-report 等），用于增强 Claude Code 的能力。主要面向开发者，提供项目初始化、任务调度、周报生成等自动化能力。

## 技术栈

| 类别 | 技术选型 |
|------|---------|
| 项目类型 | Claude Skills 仓库 |
| 主要语言 | Markdown / Shell |
| 配置格式 | YAML Frontmatter |
| 版本控制 | Git |

## 项目结构

```
.claude/
├── commands/           # 斜杠命令定义（可选；Wiki 推荐用 fe-wiki 技能）
├── skills/             # 技能包目录
│   ├── zacc-init-fronted/  # 前端项目 AI 初始化（CLAUDE.md + AI 红线）
│   ├── nf-system/      # New Feature 系统
│   ├── nf-system/      # New Feature 系统
│   ├── task-scheduler/ # 多任务并发调度器
│   ├── weekly-report/  # 周报生成器
│   └── docs/           # 文档技能
├── settings.local.json # 本地设置
docs/
├── features/           # NF 功能文档
├── dev_guide/          # 开发规范
└── tasks/              # 任务文档
```

## 开发命令

```bash
# 安装依赖（各技能包独立，无统一依赖管理）
# Git 操作
git add .
git commit -m "feat: 描述"
git push

# 技能测试
# 在 Claude Code 中执行：/nf-status 查看所有 NF 状态
```

- 格式：`feat: [描述]` 或 `NF-XXX: [动词] [描述]`
- 示例：`feat: 添加用户登录组件`
- 动词用现在时：add, update, fix, refactor

## 代码规范

- 技能文件使用 Markdown 格式，必须包含 YAML Frontmatter
- 文件命名：kebab-case（如 `fe-init.md`）
- 遵循项目已有代码风格
- 添加必要的注释

## AI 红线规则

> 修改或添加代码时必须遵守的红线规则，详见：
> - [AI 红线规则](.claude/AI_RULES.md)

## 纠错记录

> AI 在本项目中犯过的错误和用户的纠正，避免重复犯错。

<!-- 格式：- [YYYY-MM-DD] {错误描述} → {正确做法} -->

---

## NF 系统

### 规则
- 所有功能开发先创建 NF 文件（>4 小时的工作）
- NF 状态流转：Planned → Design → Open → In Progress → Pending Verification → Complete
- 每个 commit 关联 NF 编号
- 完成后更新 FEATURE_INDEX.md 并归档

### 命令
- `/nf-new` - 创建新 NF
- `/nf-status` - 查看所有 NF 状态
- `/nf-explore` - 加载项目上下文
- `/nf-verify` - 验证代码
- `/nf-close` - 关闭并归档 NF
- `/nf-deep` - 并行深度分析（复杂问题）
- `/task-scheduler` - 多任务并发调度器（自动管理多个 NF）

### 文件位置
- NF 索引：`docs/features/FEATURE_INDEX.md`
- NF 模板：`docs/features/TEMPLATE.md`
- NF 文件：`docs/features/NF-XXX-*.md`
- 归档目录：`docs/features/archive/`
- 开发规范：`docs/dev_guide/`

---

## 项目拓扑 Wiki

### 规则
- 修改任何技能包前，必须先查阅 `.wiki/index.md` 了解模块关系
- 发现代码中的历史包袱或逻辑矛盾时，通过 **`/zacc-wiki-fronted`**（或技能 **zacc-wiki-fronted**）选择「增量更新 → **legacy**」记录
- 不得忽略 Wiki 节点中的 Legacy Constraints

### 命令
- 使用 **`/zacc-wiki-fronted`** 或技能 **`zacc-wiki-fronted`**：按交互选择 **初始化 / 查询 / 增量更新**；选「增量更新」时再选 **子命令**（scan / legacy / node add/deprecate/update / refresh）

### 文件位置
- Wiki 索引：`.wiki/index.md`
- Wiki 节点：`.wiki/nodes/`
- 术语表：`.wiki/glossary.md`
