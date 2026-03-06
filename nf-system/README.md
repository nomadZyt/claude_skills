# NF System - New Feature 开发系统

> 用 Markdown 规范驱动 AI Agent 并行开发，让你从"聊天管理员"变成"真正的开发者"。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🎯 解决什么痛点

| 痛点 | NF 系统解决方案 |
|------|----------------|
| 对话即失，没有追踪 | NF 文件永久记录决策历史 |
| Agent 每次都从零开始 | `/nf-explore` 自动加载上下文 |
| 并行开发脑子不够用 | `/nf-status` 一眼看清所有功能 |
| 代码质量不稳定 | `/nf-verify` 自动按清单检查 |
| 需求来源混乱 | `/nf-new` 统一记录到 backlog |
| 知识无法积累 | NF 归档 = 决策历史库 |

---

## 🚀 快速开始

### 1. 克隆或下载

```bash
# 克隆仓库
git clone https://github.com/nomadZyt/claude_skills.git
cd claude_skills/nf-system

# 或下载 ZIP 解压
```

### 2. 初始化项目

```bash
# 进入你的项目
cd ~/your-project

# 运行初始化脚本
bash /path/to/nf-system/init.sh
```

### 3. 开始使用

```bash
# 查看状态
/nf-status

# 创建新 NF
/nf-new 用户登录功能

# 加载上下文
/nf-explore

# 开始实现
实现 NF-001

# 验证代码
/nf-verify

# 关闭 NF
/nf-close NF-001
```

---

## 📋 核心命令

| 命令 | 功能 | 何时使用 |
|------|------|----------|
| `/nf-new` | 创建新 NF | 接到新需求时 |
| `/nf-status` | 查看所有 NF | 每天开始工作时 |
| `/nf-explore` | 加载项目上下文 | 新 Agent 会话开始时 |
| `/nf-verify` | 验证代码 | 功能实现完成后 |
| `/nf-close` | 关闭并归档 NF | 功能验证通过后 |
| `/nf-deep` | 并行深度分析 | 复杂问题需要多角度探索 |

---

## 🪟 配合 tmux 使用（推荐）

### 配置

```bash
# 备份现有配置
cp ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null || true

# 使用 NF 系统配置
cp /path/to/nf-system/tmux/.tmux.conf ~/.tmux.conf

# 重载配置
tmux source-file ~/.tmux.conf
```

### 添加快捷命令

```bash
echo 'alias nf-tmux="bash /path/to/nf-system/tmux/nf-tmux.sh"' >> ~/.zshrc
source ~/.zshrc
```

### 启动会话

```bash
cd ~/your-project
nf-tmux my-project
```

### 窗口分配

| 窗口 | 角色 | 用途 |
|------|------|------|
| 1 | PM | 管理 backlog |
| 2-4 | Planner | 设计 NF |
| 5-7 | Worker | 实现 NF |
| 8 | bash | 手动命令 |

---

## 📁 文件结构

```
nf-system/
├── README.md           # 本文件
├── USAGE.md            # 详细使用指南
├── SKILL.md            # 技能说明
├── init.sh             # 初始化脚本
├── tmux/
│   ├── .tmux.conf      # tmux 配置
│   └── nf-tmux.sh      # 启动脚本
├── templates/
│   ├── FEATURE_INDEX.md
│   ├── NF-TEMPLATE.md
│   └── CLAUDE.md
└── commands/
    ├── nf-new.md
    ├── nf-status.md
    ├── nf-explore.md
    ├── nf-verify.md
    ├── nf-close.md
    └── nf-deep.md
```

---

## 💡 最佳实践

### NF 粒度

| 工作量 | 写 NF 时间 | 说明 |
|--------|-----------|------|
| Small (<4h) | 5-10 分钟 | 简单功能 |
| Medium (4-16h) | 15-20 分钟 | 中等功能 |
| Large (>16h) | 30+ 分钟 | 复杂功能 |

### 并行上限

- **推荐**: 4-6 个 Agent
- **最大**: 8 个

### Commit 规范

```bash
NF-XXX: [动词] [描述]

# 示例
NF-001: 添加用户登录组件
```

---

## ⚠️ 何时使用

### ✅ 适合
- 中大型项目（>1 万行代码）
- 多人协作（需要知识传承）
- 长期维护的项目
- 同时开发 3+ 个功能

### ❌ 不适合
- < 1 小时的 bug 修复
- 探索性/实验性代码
- 超小项目

---

## 📖 详细文档

- **[USAGE.md](USAGE.md)** - 完整使用指南
- **[TMUX-GUIDE.md](TMUX-GUIDE.md)** - tmux 实战指南

---

## 📄 License

MIT License

---

**版本**: 1.0  
**日期**: 2026-03-03  
**作者**: nomad
