# zacc-init-wiki-fronted 使用指南

## 概述

`zacc-init-wiki-fronted` 是项目拓扑 Wiki 生成技能，为前端项目在 `wiki/` 目录生成结构化的 AI 知识图谱，与业务代码完全解耦。支持初始化、增量更新和架构感知查询三种模式。

## 适用场景

- 新项目需要建立 AI 可检索的架构知识库
- 项目结构复杂，希望 AI 修改代码前先理解全局拓扑
- 项目迭代后需要增量更新拓扑信息
- 开发中需要快速查询模块上下游依赖关系

## 核心哲学

| 原则 | 说明 |
|------|------|
| 解耦记忆 | AI 的架构认知独立于业务代码，存储在 `wiki/` |
| 机器友好 | 使用 Frontmatter + YAML 声明，抛弃散文叙述 |
| 有界检索 | 先用 Wiki 收敛候选范围，再定向读代码校验 |
| 尊重现状 | 不了解项目现况前，禁止任何破坏性修改 |
| 增量演进 | Wiki 随项目演进，只追加不覆盖历史包袱 |

## 使用方式

### 统一入口

在 Claude Code 中执行：

```
/zacc-init-wiki-fronted
```

技能会根据意图自动分流到三个 SOP。

### 三种操作模式

| 模式 | 触发方式 | SOP | 说明 |
|------|----------|-----|------|
| 初始化 | 说「首次生成 Wiki」或在菜单中选「初始化」 | SOP-1 | 全量扫描生成 `wiki/` |
| 增量更新 | 说「scan 一下」「记 legacy」或在菜单中选「增量更新」 | SOP-2 | 按子命令操作 |
| 查询 | 说「支付模块上下游有哪些」或在菜单中选「查询」 | SOP-3 | 架构感知问答 |

### 增量更新子命令

| 子命令 | 说明 |
|--------|------|
| `scan` | 检测项目变更，增量更新受影响节点 |
| `legacy` | 记录历史包袱到节点，只追加不修改 |
| `node add` | 新增一个节点（指定目录） |
| `node deprecate` | 废弃一个节点（标记 deprecated） |
| `node update` | 重新扫描单个节点 |
| `refresh` | 全量重建（保留历史包袱） |

## 输出文件

| 文件 | 位置 | 作用 |
|------|------|------|
| index.md | `wiki/` | 全局拓扑索引（人类可读，三层架构视图） |
| index.json | `wiki/` | 机器可读索引（按 path/alias/export/tag 检索） |
| glossary.md | `wiki/` | 项目术语表 |
| {id}.md | `wiki/nodes/` | 原子知识节点（每个模块一个） |
| .wiki-state.json | `wiki/` | 增量更新状态快照 |

## 初始化流程（SOP-1）

1. **项目类型检测** — 识别语言、入口文件、是否 Monorepo、是否 Taro 小程序
2. **核心模块扫描** — 按容器目录（components/pages/api/hooks/store/utils 等）提取模块
3. **依赖关系提取** — 维护 import/route/dynamic 三层边
4. **生成节点文件** — 为每个模块生成 `wiki/nodes/{id}.md`
5. **生成全局索引** — index.md（人类版）+ index.json（机器版）
6. **生成术语表** — 从模块名、类名、核心方法名提取术语
7. **保存状态并输出** — 生成 .wiki-state.json，检查 CLAUDE.md 追加 Wiki 规则

## 查询流程（SOP-3）硬规则

1. 禁止在未读 Wiki 前直接全仓扫描 `src/`
2. 必须先读 `wiki/index.md` 与 `wiki/index.json`
3. 必须追踪上下游依赖至少一层
4. 必须合并历史包袱到回答中
5. 仅当 Wiki 命中不足或节点过期时，才允许扩大搜索范围

## 配套技能

| 技能 | 说明 |
|------|------|
| zacc-init-fronted | 前端项目 AI 初始化（CLAUDE.md + AI_RULES.md），与本技能互补 |

## 常见问题

**Q: Wiki 会修改业务代码吗？**
A: 不会。所有 Wiki 文件存储在 `wiki/` 目录，与业务代码完全解耦。

**Q: 大型 Monorepo 如何处理？**
A: 支持全量、聚焦、选择性三种策略，详见 `references/monorepo-strategies.md`。

**Q: 增量更新会丢失历史包袱吗？**
A: 不会。历史包袱章节在 scan/refresh 中始终保留，只追加不覆盖。

**Q: Taro 小程序项目支持吗？**
A: 支持。会额外识别 `app.config.ts`、分包结构等 Taro 专属信号。

**Q: 节点 ID 会变化吗？**
A: 节点 ID 是稳定标识（如 `page.checkout`），不使用时间戳。增量更新时尽量复用原 ID。
