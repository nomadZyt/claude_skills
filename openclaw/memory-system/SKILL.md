---
name: memory-system
description: |
  OpenClaw 记忆管理系统。基于 frontmatter 语义标签的知识管理，支持分类、归档、按需检索。
  触发词："记住"、"记录"、"回忆"、"之前说过"、"我的偏好"、"项目进展"、"remember"、"recall"
---

# Memory System - 记忆管理技能

## 概述

基于 frontmatter 语义标签的记忆管理系统。所有记忆通过 `type`、`tags`、`project`、`importance` 字段分类，通过 `MEMORY.md` 索引驱动按需加载。

## 目录结构

安装后在 `~/.openclaw/workspace/memory/` 下创建：

```
memory/
├── MEMORY.md          # 索引文件（会话启动时加载）
├── active/            # 活跃记忆（按需加载具体文件）
│   ├── pref-*.md      # type: preference
│   ├── dec-*.md       # type: decision
│   ├── ctx-*.md       # type: context
│   ├── learn-*.md     # type: learning
│   └── log-*.md       # type: log（每日记录）
└── archive/           # 归档记忆（索引可见，按需加载）
    ├── 2026-W10.md    # 按周合并的 daily log
    └── ...
```

## 记忆分类规范

每条记忆必须包含以下 frontmatter：

```yaml
---
id: mem-YYYYMMDD-NNN        # 唯一标识
type: decision               # 记忆类型（见下方说明）
tags: [feishu, config]       # 语义标签，支持多标签
project: openclaw-config     # 关联项目（可选）
importance: high             # high / medium / low
created: 2026-03-13          # 创建日期
expires: null                # null = 永不过期，或 YYYY-MM-DD
summary: "一句话描述"          # 必填，用于索引显示
---
```

### 记忆类型（type）说明

| type | 用途 | 生命周期 | 示例 |
|------|------|----------|------|
| `decision` | 技术决策、方案选择 | 长期 | "选择 webhook 而非轮询" |
| `learning` | 学到的知识、经验教训 | 长期 | "飞书 API 的 token 有效期 2 小时" |
| `preference` | 用户偏好、工作习惯 | 长期 | "先问后做" |
| `context` | 项目当前状态、进展 | 中期（随项目更新） | "NF 系统进入测试阶段" |
| `log` | 每日工作记录 | 短期（7 天后归档） | "2026-03-13 完成飞书配置" |

### 区分规则

当需要记录一条新记忆时，按以下顺序判断 type：

1. 用户明确说"我喜欢/我习惯/以后都这样做" → `preference`
2. 做了一个有多个选项的选择，记录了为什么选 A 不选 B → `decision`
3. 解决问题过程中发现的规律/坑/技巧 → `learning`
4. 描述项目当前在做什么、进展到哪里 → `context`
5. 日常工作流水账、今天完成了什么 → `log`

## 触发时机

### 1. 会话启动 - 自动加载索引

**何时**：每次新会话开始
**动作**：读取 `memory/MEMORY.md`
**目的**：获取所有记忆的摘要视图，不加载具体内容

### 2. 用户提问 - 按需加载

**何时**：用户提问内容与索引中的 tag/project/summary 匹配
**动作**：读取 `memory/active/` 下匹配的具体文件
**示例**：
- 用户问"飞书配置怎么做的" → 匹配 tag `feishu`，加载相关 active 文件
- 用户问"之前为什么选了 DDD" → 匹配 type `decision`，加载相关文件

### 3. 归档记忆检索 - 按需加载

**何时**：用户问题与 MEMORY.md 中 Archived 部分的摘要匹配
**动作**：读取 `memory/archive/` 下对应的周文件
**示例**：
- 用户问"上周做了什么" → 加载 `archive/2026-W12.md`
- 索引显示 `2026-W10: feishu 配置, skill 开发` → 按需加载

### 4. 新记忆写入

**何时**：
- 用户明确说"记住这个"
- 做出了重要技术决策
- 发现了值得记录的经验
- 每日工作结束时

**动作**：
1. 按模板在 `memory/active/` 下创建新 .md 文件
2. 运行 `build-index.sh` 重建 MEMORY.md 索引

### 5. 定期维护

**何时**：每周执行一次（建议周日）
**动作**：运行 `archive-daily.sh`
- 将 7 天前的 `type: log` 文件按周合并到 `archive/`
- 自动重建索引，归档摘要写入 MEMORY.md 的 Archived 部分

## 归档与检索机制

### 归档规则

- 只归档 `type: log` 的记忆（每日记录）
- `decision`、`learning`、`preference`、`context` 类型**永不自动归档**
- 归档 = 按周合并 + 生成摘要行 + 写入索引
- 归档文件头部包含该周所有记忆的 summary 列表

### 归档后的可检索性

```
MEMORY.md 索引（始终加载）
  │
  ├── Active 部分 → 直接看到每条记忆的 summary、type、tags
  │     └── 匹配 → 读取 active/xxx.md 获取完整内容
  │
  └── Archived 部分 → 看到每周的摘要（包含关键词）
        └── 匹配 → 读取 archive/2026-WXX.md 获取完整内容
```

**关键：归档后的记忆不会"消失"，它的摘要始终在索引中可见，只是完整内容需要按需加载。**

## 文件命名规范

| type | 前缀 | 示例 |
|------|------|------|
| decision | `dec-` | `dec-feishu-webhook.md` |
| learning | `learn-` | `learn-token-expiry.md` |
| preference | `pref-` | `pref-coding-style.md` |
| context | `ctx-` | `ctx-nf-system.md` |
| log | `log-` | `log-2026-03-13.md` |

## 维护命令

```bash
# 初始化 memory 目录
python3 ~/.openclaw/workspace/skills/memory-system/scripts/init_memory.py

# 重建索引
python3 ~/.openclaw/workspace/skills/memory-system/scripts/build_index.py

# 归档 7 天前的 daily log
python3 ~/.openclaw/workspace/skills/memory-system/scripts/archive_daily.py
```

## 安装

```bash
# 复制到 OpenClaw skills 目录
cp -r memory-system ~/.openclaw/workspace/skills/

# 初始化 memory 目录
python3 ~/.openclaw/workspace/skills/memory-system/scripts/init_memory.py
```
