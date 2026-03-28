# OpenClaw Memory System

基于 frontmatter 语义标签的记忆管理系统。

## 环境要求

- **Python 3.9+**（脚本仅使用标准库，无需额外安装包）

检查是否已安装：

```bash
python3 --version
```

如未安装，按系统选择安装方式：

| 系统 | 安装命令 |
|------|---------|
| macOS | `brew install python3` 或从 [python.org](https://www.python.org/downloads/) 下载 |
| Ubuntu/Debian | `sudo apt install python3` |
| CentOS/RHEL | `sudo yum install python3` |
| Windows | 从 [python.org](https://www.python.org/downloads/) 下载安装，勾选 "Add to PATH" |

## 安装

```bash
# 1. 复制到 OpenClaw skills 目录
cp -r memory-system ~/.openclaw/workspace/skills/

# 2. 初始化 memory 目录
python3 ~/.openclaw/workspace/skills/memory-system/scripts/init_memory.py
```

## 快速开始

### 创建一条记忆

在 `~/.openclaw/workspace/memory/active/` 下创建文件，必须包含 frontmatter：

```markdown
---
id: mem-20260313-001
type: decision
tags: [feishu, webhook]
project: openclaw-config
importance: high
created: 2026-03-13
expires: null
summary: "选择 webhook 方式接收飞书消息"
---

# 飞书消息接收方式选择

选择 webhook 而非轮询，因为...
```

### 重建索引

```bash
python3 ~/.openclaw/workspace/skills/memory-system/scripts/build_index.py
```

### 归档旧记录

```bash
python3 ~/.openclaw/workspace/skills/memory-system/scripts/archive_daily.py
```

## 记忆类型

| type | 用途 | 自动归档 | 命名前缀 |
|------|------|----------|----------|
| `decision` | 技术决策 | 否 | `dec-` |
| `learning` | 经验教训 | 否 | `learn-` |
| `preference` | 用户偏好 | 否 | `pref-` |
| `context` | 项目状态 | 否 | `ctx-` |
| `log` | 每日记录 | 是（7天后） | `log-` |

## 触发时机

| 场景 | 加载内容 |
|------|----------|
| 新会话启动 | `MEMORY.md` 索引 |
| 用户提问匹配 tag/project | `active/` 下具体文件 |
| 匹配归档摘要 | `archive/` 下对应周文件 |
| 用户说"记住" | 写入 `active/` + 重建索引 |
| 每周维护 | 运行 `archive-daily.sh` |

## 归档机制

- 只归档 `type: log` 的记忆
- `decision`、`learning`、`preference`、`context` 永不自动归档
- 归档 = 按周合并 + 摘要写入索引
- 归档后记忆的摘要始终在 `MEMORY.md` 可见，Agent 可按需加载原文

## 脚本说明

| 脚本 | 用途 | 建议频率 |
|------|------|----------|
| `init_memory.py` | 初始化目录 | 仅一次 |
| `build_index.py` | 重建索引 | 每次新增记忆后 |
| `archive_daily.py` | 归档旧 log | 每周一次 |

所有脚本支持自定义 memory 目录：`python3 script.py /custom/path`
