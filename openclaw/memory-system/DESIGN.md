# OpenClaw Memory System - 系统设计文档

> 版本：v2.0
> 日期：2026-03-25

---

## 一、整体架构

```
┌─────────────────────────────────────────────────────┐
│                   MEMORY.md 索引                      │
│  （唯一常驻加载文件，所有记忆的"目录页"）                    │
│                                                       │
│  By Type:     Decisions / Learnings / Preferences ... │
│  By Project:  openclaw-config / nf-system ...         │
│  Archived:    2026-W10 / 2026-W11 ...                 │
└──────────┬──────────────────────┬─────────────────────┘
           │ 匹配 → 按需读取       │ 匹配 → 按需读取
           ▼                      ▼
    ┌──────────────┐      ┌───────────────┐
    │   active/    │      │   archive/    │
    │  dec-*.md    │      │  2026-W10.md  │
    │  learn-*.md  │      │  2026-W11.md  │
    │  pref-*.md   │      │    ...        │
    │  ctx-*.md    │      └───────────────┘
    │  log-*.md    │
    └──────────────┘
```

**核心思想：索引常驻，原文按需加载。**

Agent 每次会话只消耗索引的 token（每条记忆一行），不是所有记忆文件的 token。

---

## 二、数据流：5 个触发点

```
① 会话启动
   └→ 自动读取 MEMORY.md（只读索引，不加载原文）

② 用户提问
   └→ 问题关键词 匹配 索引中的 tag/project/summary
      ├→ 命中 active → 读取 active/xxx.md
      └→ 命中 archived 摘要 → 读取 archive/2026-WXX.md

③ 新记忆写入
   └→ 判断 type（preference > decision > learning > context > log）
      └→ 创建 active/{prefix}-{name}.md（含 frontmatter）
         └→ 运行 build_index.py → 重建 MEMORY.md

④ 每周维护
   └→ 运行 archive_daily.py
      └→ 扫描 active/ 中 type=log 且 >7天 的文件
         └→ 按 ISO 周合并到 archive/2026-WXX.md
            └→ 删除原文件
               └→ 自动调用 build_index.py → 重建索引

⑤ 手动重建索引
   └→ 运行 build_index.py → 全量扫描 active/ + archive/ → 重写 MEMORY.md
```

---

## 三、记忆生命周期

```
创建                 活跃期                归档               检索
 │                    │                    │                  │
 ▼                    ▼                    ▼                  ▼
写入 active/    ←── 会话中按需加载 ──→  7天后(仅log)    索引摘要始终可见
带 frontmatter       读取完整内容         按周合并         匹配后按需加载原文
                                         删除原文
```

> **decision / learning / preference / context → 永不自动归档，常驻 active/**

---

## 四、记忆分类规范

### Frontmatter 结构

```yaml
---
id: mem-YYYYMMDD-NNN        # 唯一标识
type: decision               # 记忆类型
tags: [feishu, config]       # 语义标签，支持多标签
project: openclaw-config     # 关联项目（可选）
importance: high             # high / medium / low
created: 2026-03-13          # 创建日期
expires: null                # null = 永不过期，或 YYYY-MM-DD
summary: "一句话描述"          # 必填，用于索引显示
---
```

### 五级分类与判断优先级

| type | 用途 | 生命周期 | 命名前缀 | 判断规则 |
|------|------|----------|----------|----------|
| `preference` | 用户偏好、工作习惯 | 永久 | `pref-` | 用户说"我喜欢/我习惯/以后都这样做" |
| `decision` | 技术决策、方案选择 | 永久 | `dec-` | 在多个选项中做了选择，记录了为什么 |
| `learning` | 经验教训、知识点 | 永久 | `learn-` | 解决问题过程中发现的规律/坑/技巧 |
| `context` | 项目当前状态 | 中期 | `ctx-` | 描述项目在做什么、进展到哪里 |
| `log` | 每日工作记录 | 7 天后归档 | `log-` | 日常流水账、今天完成了什么 |

**判断时从上到下匹配，命中第一个即停。**

---

## 五、归档与检索机制

### 归档规则

- 只归档 `type: log`（每日记录）
- 其余四种类型永不自动归档
- 归档动作 = 按 ISO 周合并 + 生成摘要行 + 删除原文件 + 重建索引

### 归档后的三层可检索保障

```
第一层：MEMORY.md Archived 部分
        └→ 保留每个周文件的摘要链接（始终可见）

第二层：archive/2026-WXX.md 头部 Summary 区
        └→ 该周所有记忆的一句话描述列表（快速扫描）

第三层：archive/2026-WXX.md Entries 区
        └→ 完整原文（按需加载获取全部细节）
```

**归档 ≠ 丢失。摘要始终在索引中，Agent 判断相关后按需加载原文。**

---

## 六、系统特点

### 1. Frontmatter 驱动，而非目录驱动

所有记忆文件平铺在 `active/`，靠 frontmatter 的 `type`、`tags`、`project` 三个字段做语义分类。分类信息跟着文件走，不依赖目录位置，不会因为放错目录而找不到。

### 2. 索引-原文分离

| 层级 | 内容 | 加载时机 | Token 开销 |
|------|------|----------|-----------|
| MEMORY.md | 每条记忆一行摘要 | 每次会话启动 | 极小 |
| active/xxx.md | 完整内容 | 按需加载 | 仅需要时消耗 |
| archive/xxx.md | 归档完整内容 | 按需加载 | 仅需要时消耗 |

### 3. 多维查询

同一条记忆可以同时通过 type、tag、project 三个维度被找到：

- "飞书相关的决策" → type=decision + tag=feishu
- "openclaw-config 项目的所有记忆" → project=openclaw-config
- "上周做了什么" → archived 摘要按时间匹配

### 4. 脚本单一职责 + 代码复用

| 脚本 | 职责 | 依赖 |
|------|------|------|
| `init_memory.py` | 建目录 + 生成空索引 | 无 |
| `build_index.py` | 扫描 frontmatter → 生成索引 | 无 |
| `archive_daily.py` | 归档过期 log → 重建索引 | 复用 `build_index.extract_frontmatter()` |

三个脚本均为 Python 3.9+ 标准库实现，零外部依赖，跨平台运行。

### 5. 环境安全

- 脚本入口自动检测 Python 版本，不满足时打印安装指引并退出
- 所有操作仅限 `memory/` 目录范围内
- `init_memory.py` 幂等执行，不覆盖已有 MEMORY.md

---

## 七、与原方案对比

| 维度 | 原方案 | 当前系统 |
|------|--------|---------|
| **会话 token 消耗** | 16 个文件全量加载 | 只加载 MEMORY.md 索引（1 个文件） |
| **分类方式** | 靠目录位置（容易放错） | 靠 frontmatter 标签（跟着文件走） |
| **多维查询** | 按目录找（跨目录要遍历） | type + tag + project 任意维度交叉 |
| **归档后检索** | 归档 = 消失 | 摘要始终在索引中，按需加载原文 |
| **加载策略** | config.yaml（OpenClaw 不执行） | 写在 SKILL.md system prompt 里（Agent 实际执行） |
| **跨平台** | zsh 脚本（bash 3.x 不兼容） | Python 3.9+（macOS / Linux / Windows） |
| **文件数量** | 24 个文件，多层目录 | 8 个文件，2 层目录 |
| **代码复用** | 3 个独立 shell，逻辑重复 | `extract_frontmatter()` 共享 |

---

## 八、文件清单

```
openclaw/memory-system/
├── SKILL.md                              # Skill 入口（触发时机、分类规则）
├── README.md                             # 安装和使用文档
├── scripts/
│   ├── init_memory.py                    # 初始化 memory 目录
│   ├── build_index.py                    # 扫描 frontmatter → 重建索引
│   └── archive_daily.py                  # 归档过期 log → 重建索引
└── templates/
    ├── memory-entry.md.template          # 单条记忆模板
    ├── daily.md.template                 # 每日记录模板
    └── MEMORY.md.template                # 索引文件模板
```

---

## 九、安装运行后的目录结构

```
~/.openclaw/workspace/memory/
├── MEMORY.md          # 索引（会话启动时加载）
├── active/            # 活跃记忆
│   ├── dec-feishu-webhook.md
│   ├── learn-token-expiry.md
│   ├── pref-coding-style.md
│   ├── ctx-nf-system.md
│   └── log-2026-03-25.md
└── archive/           # 归档记忆
    ├── 2026-W10.md
    └── 2026-W11.md
```

---

*文档版本：v2.0 | 日期：2026-03-25*
