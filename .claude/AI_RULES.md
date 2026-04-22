# AI 红线规则

> 本文件由 zacc-init-fronted 技能自动生成（降级模式），记录 AI 修改/添加代码时必须遵守的规则。
> 生成时间：2026-04-16
> 初始化模式：非前端降级（zacc-init-fronted）

---

## 1. 技术栈红线

### 项目技术栈

| 类别 | 技术选型 |
|------|---------|
| 项目类型 | Claude Skills 仓库 |
| 主要语言 | Markdown / Shell |
| 配置格式 | YAML Frontmatter |
| 版本控制 | Git |

### 禁止操作

- 不得在技能包中引入与技能功能无关的依赖
- 不得修改已发布技能的核心接口（SKILL.md 中的 input/output 定义）
- 不得删除或移动已有技能包目录

---

## 2. 架构模式红线

### 目录规范

新建技能必须放在对应目录：

| 文件类型 | 目标目录 |
|---------|---------|
| 技能包 | `.claude/skills/{skill-name}/` |
| 斜杠命令 | `.claude/commands/{command-name}.md` |
| NF 文档 | `docs/features/NF-XXX-{name}.md` |
| 开发规范 | `docs/dev_guide/` |
| 任务文档 | `docs/tasks/` |

### 技能包结构规范

每个技能包必须包含：

```
.claude/skills/{skill-name}/
├── SKILL.md              # 技能定义（必须，含 YAML Frontmatter）
├── references/           # 参考文档（可选）
└── templates/            # 模板文件（可选）
```

### 模块边界

- 技能包之间应保持独立，避免循环依赖
- 公共工具或引用放在技能包的 `references/` 目录
- 修改公共技能（nf-system、task-scheduler 等）前必须先查阅 `.wiki/index.md`

---

## 3. 代码风格红线

### 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 技能目录 | kebab-case | `nf-system/`, `task-scheduler/` |
| 技能文件 | 大写 SKILL.md | `SKILL.md` |
| 参考文档 | kebab-case | `ai-redlines.md` |
| 模板文件 | kebab-case + .tpl | `CLAUDE.md.tpl` |
| NF 文件 | NF-XXX-kebab-case | `NF-001-feature-name.md` |

### Markdown 规范

- 技能文件使用 Markdown 格式，必须包含 YAML Frontmatter
- Frontmatter 必须包含 `name`、`description` 字段
- 使用 ATX 风格标题（`#` 开头）
- 代码块必须指定语言

### Git 规范

- Commit 格式：`feat: [描述]` 或 `NF-XXX: [动词] [描述]`
- 动词用现在时：add, update, fix, refactor
- 每个 commit 关联 NF 编号（如适用）

---

## 4. 业务逻辑红线

### NF 系统规则

- 所有功能开发（>4 小时的工作）先创建 NF 文件
- NF 状态流转：Planned → Design → Open → In Progress → Pending Verification → Complete
- 完成后更新 `docs/features/FEATURE_INDEX.md` 并归档

### 技能包修改规则

- 修改任何技能包前，必须先查阅 `.wiki/index.md` 了解模块关系
- 发现代码中的历史包袱或逻辑矛盾时，使用 `fe-wiki` 技能执行增量更新并记录 legacy
- 不得忽略 Wiki 节点中的 Legacy Constraints

---

## 5. 功能修改确认规则

以下操作在执行前**必须使用 AskUserQuestion 弹窗确认**：

| 操作 | 影响范围 |
|------|---------|
| 修改现有技能的 SKILL.md 定义 | 所有使用该技能的用户 |
| 删除或重命名现有技能包 | 所有引用该技能的配置 |
| 修改 NF 系统核心流程 | 所有进行中的 NF |
| 修改公共命令文件 | 所有使用该命令的用户 |
| 删除或移动 Wiki 节点 | 项目拓扑完整性 |

---

## 附录：项目特有规则

### 技能开发约束

1. 新技能必须经过测试验证后才能发布
2. 技能文档中必须包含使用示例
3. 涉及外部 API 的技能必须在文档中说明前置条件

### 文档维护

1. 重要功能变更需同步更新 README.md
2. 技能包目录结构变更需更新 CLAUDE.md 中的项目结构章节

<!-- 用户纠错后可能追加的规则会自动写入此处 -->
