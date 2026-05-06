# zacc-init-fronted 使用指南

## 概述

`zacc-init-fronted` 是面向前端项目的 AI 初始化技能，通过六维度分析自动生成 `CLAUDE.md` 和 `.claude/AI_RULES.md`，让 Claude Code 理解项目上下文并遵循现有开发模式。

## 适用场景

- 新接手的前端项目需要快速配置 Claude Code
- 项目技术栈更新后需要同步 AI 配置
- 团队统一 AI 开发规范

## 前置条件

- 项目为前端工程（框架判定见 `references/tech-stack-detection.md`）
- 非前端项目也可运行，但会进入降级模式（需用户确认）

## 使用方式

### 1. 确保技能已安装

通过 `install.mjs` 或 `install-smart.mjs` 安装技能包后，技能自动可用。

### 2. 执行初始化

在 Claude Code 中执行：

```
/zacc-init-fronted
```

或直接让 Claude Code 执行 `zacc-init-fronted` 技能。

### 3. 等待分析完成

技能会自动执行以下六维度分析：

| 维度 | 说明 | 参考文档 |
|------|------|---------|
| 项目信息收集 | 读取 package.json、构建配置、lock 文件，识别技术栈 | `references/tech-stack-detection.md` |
| 项目结构分析 | 扫描源码目录，识别组织模式（按功能/类型/模块/路由/混合） | `references/project-structure-analysis.md` |
| 代码规范提取 | 读取 ESLint/Prettier/Biome/TS/Stylelint/EditorConfig 配置，推断命名和提交规范 | `references/code-standards-extraction.md` |
| 数据流转 + 页面流转 | 分析路由 → API → 状态 → 视图的链路关系，含 Modal/Drawer 流转 | `references/data-flow-analysis.md` + `references/page-flow-analysis.md` |
| 业务特性识别 | 识别配置化、多环境、埋点、权限体系、实时推送等特性 | `references/business-features.md` |
| AI 红线分析 | 提取技术栈/架构/风格/业务四类红线规则 | `references/ai-redlines.md` |

### 4. 非前端项目处理

若项目被判定为非前端工程，技能会：

1. 提示用户当前为非前端项目
2. 询问是否继续（降级初始化）
3. 选择继续后，按降级策略执行，生成的文件会标注降级模式

详见 `references/non-frontend-degraded.md`。

## 输出文件

| 文件 | 位置 | 说明 |
|------|------|------|
| CLAUDE.md | 项目根目录 | 项目配置：技术栈、命令、规范、业务特性、纠错记录、初始化日志 |
| AI_RULES.md | .claude/ 目录 | AI 红线规则：技术栈/架构/风格/业务逻辑 + 纠错追加规则 |
| zacc-init-fronted.md | .claude/commands/ | 斜杠命令入口（可选，步骤 6b） |

## 已有文件的处理

| 情况 | 策略 |
|------|------|
| 无 CLAUDE.md | 基于模板完整生成 |
| 已有 CLAUDE.md | 增量更新：补缺失章节、更新过时信息、保留用户自定义内容 |
| 无 AI_RULES.md | 基于模板完整生成 |
| 已有 AI_RULES.md | 询问用户选择：**增量更新**（保留纠错追加规则）或 **重新生成** |

## 产出校验（步骤 6c）

文件生成后会自动运行校验脚本：

```bash
bash .claude/skills/zacc-init-fronted/scripts/verify-init.sh
```

校验项包括：
- 占位符是否全部填充（支持中英文占位符检测）
- 必要章节是否完整
- 红线规则是否非空
- CLAUDE.md 与 AI_RULES.md 的交叉一致性（包管理器等）
- 模板 HTML 注释是否已清理

FAIL 项必须修正后才能完成初始化，WARN 项向用户汇报。

## 初始化日志（步骤 6d）

每次执行会在 CLAUDE.md 底部的「初始化日志」表格追加一行记录，包含时间、技能版本、模式（标准/降级）、变更摘要。

## 何时应重新执行初始化

以下场景建议重新运行 `zacc-init-fronted`：

| 场景 | 原因 |
|------|------|
| **重大依赖升级** | 如 React 18 → 19、Vue 2 → 3、Umi 3 → 4 等框架大版本升级 |
| **框架迁移** | 如从 Webpack 迁到 Vite、从 Redux 迁到 Zustand |
| **目录结构重构** | 如从按类型组织改为按功能组织 |
| **规范配置变更** | 如从 ESLint + Prettier 迁到 Biome |
| **新增业务域** | 新增大量页面/模块后，原有分析不再完整 |
| **包管理器切换** | 如从 npm 迁到 pnpm |

增量更新模式会保留用户自定义内容和纠错记录，安全无损。

## 纠错自学习

初始化完成后，当用户纠正 AI 输出时，技能会自动将纠错记录追加到 CLAUDE.md 的「纠错记录」章节和 AI_RULES.md 的「纠错追加规则」章节，实现持续学习。

## 参考文档清单

| 文件 | 用途 |
|------|------|
| `references/tech-stack-detection.md` | 技术栈识别关键词（框架判定唯一信源） |
| `references/project-structure-analysis.md` | 项目结构扫描策略与组织模式识别 |
| `references/code-standards-extraction.md` | 代码规范配置文件读取与命名风格推断 |
| `references/data-flow-analysis.md` | 数据流转分析方法 |
| `references/page-flow-analysis.md` | 页面流转与 Modal/Drawer 流转分析 |
| `references/business-features.md` | 业务特性识别指引 |
| `references/ai-redlines.md` | AI 红线提取方法 |
| `references/non-frontend-degraded.md` | 非前端降级策略 |
| `templates/CLAUDE.md.tpl` | CLAUDE.md 生成模板 |
| `templates/AI_RULES.md.tpl` | AI_RULES.md 生成模板 |
| `scripts/verify-init.sh` | 产出完整性校验脚本 |

## 配套技能

| 技能 | 说明 |
|------|------|
| zacc-init-wiki-fronted | 生成 `wiki/` 项目拓扑图谱（需单独安装） |

## 常见问题

**Q: 初始化需要多长时间？**
A: 通常 1-3 分钟，取决于项目规模和复杂度。

**Q: 会不会覆盖我已有的 CLAUDE.md 自定义内容？**
A: 不会。增量更新模式下，用户自定义章节会完整保留。

**Q: AI_RULES.md 的纠错追加规则会被覆盖吗？**
A: 选择增量更新时不会，纠错追加规则章节会被完整保留。

**Q: monorepo 项目如何处理？**
A: 技能会检测 pnpm-workspace.yaml / lerna.json / nx.json / turbo.json，自动识别 monorepo 结构。对于 monorepo，建议指定具体子目录进行初始化。

**Q: 全栈项目能用吗？**
A: 只要 package.json 中包含前端框架依赖即可正常识别。边界情况下可能进入降级模式，需用户确认。

**Q: 校验脚本报 FAIL 怎么办？**
A: FAIL 项表示产出不完整（如占位符残留、章节缺失），技能会自动修正后重新校验。
