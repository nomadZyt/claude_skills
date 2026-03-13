# NF System - 使用指南

> 用 Markdown 规范驱动 AI Agent 并行开发，让你从"聊天管理员"变成"真正的开发者"。

---

## 🎯 何时使用 NF 系统

### ✅ 适合的场景

| 场景 | 说明 |
|------|------|
| **中大型项目** | 代码量 > 1 万行，功能模块多 |
| **多人协作** | 需要知识传承，新人会接手 |
| **长期维护** | 决策历史重要，不能丢 |
| **并行开发** | 同时开发 3+ 个功能 |
| **复杂功能** | 工作量 > 4 小时，需要设计方案 |

### ❌ 不适合的场景

| 场景 | 说明 |
|------|------|
| **小 bug 修复** | < 1 小时的工作，直接用 |
| **探索性代码** | 先跑起来再说，以后再补 |
| **超小项目** | 一个人 + 几千行代码，可能太重 |

---

## 🚀 快速开始

### 1. 初始化项目

```bash
# 进入你的项目
cd ~/your-project

# 运行初始化脚本
bash /path/to/nf-system/init.sh
```

### 2. 开始使用

```bash
# 查看所有 NF
/nf-status

# 创建新 NF
/nf-new 用户登录功能

# 加载上下文
/nf-explore

# 开始实现
实现 NF-001，plan mode on

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

### 配置 tmux

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
# 添加到 ~/.zshrc 或 ~/.bashrc
echo 'alias nf-tmux="bash /path/to/nf-system/tmux/nf-tmux.sh"' >> ~/.zshrc
source ~/.zshrc
```

### 启动会话

```bash
# 进入项目
cd ~/your-project

# 启动 tmux 会话（自动创建 8 个窗口）
nf-tmux my-project
```

### 窗口分配

| 窗口 | 角色 | 用途 |
|------|------|------|
| 1 | PM | 管理 backlog，`/nf-status`，`/nf-new` |
| 2-4 | Planner | 设计 NF，`/nf-explore`，`/nf-deep` |
| 5-7 | Worker | 实现 NF，写代码，`/nf-verify` |
| 8 | bash | 手动命令，测试，运行 |

---

## 📁 NF 文件结构

每个 NF 文件包含：

```markdown
NF-XXX: [功能名称]

状态：Open    优先级：High
工作量：Medium  影响：[描述业务影响]

## 问题
[要解决的问题]

## 方案
[最终方案 + 实现步骤]

### 考虑过的替代方案
1. [方案 A] - 优点/缺点
2. [方案 B] - 优点/缺点

## 要修改的文件
- src/xxx.tsx (新增)

## 验证
- [ ] 单元测试
- [ ] E2E 测试
- [ ] 手动测试

## 备注
[其他注意事项]
```

---

## 🎯 典型工作流

### 每天开始工作

```bash
# 1. 启动/恢复 tmux 会话
nf-tmux my-project

# 2. 查看状态
/nf-status

# 输出示例：
# ## 进行中的功能
# | NF | 标题 | 状态 | 优先级 |
# |----|------|------|--------|
# | NF-001 | 登录 | Pending Verification | High |
# | NF-002 | 深色模式 | In Progress | Medium |
```

### 处理新需求

```bash
# 1. 创建 NF
/nf-new 用户反馈的问题

# 2. 设计 NF
/nf-explore
设计 NF-003

# 3. 实现 NF
实现 NF-003

# 4. 验证
/nf-verify

# 5. 关闭
/nf-close NF-003
```

### 复杂问题

```bash
# 启动 4 个 Agent 并行分析
/nf-deep 架构重构方案

# 输出：
# 1. 算法角度分析
# 2. 结构角度分析
# 3. 渐进角度分析
# 4. 环境角度分析
# → 综合建议
```

---

## 💡 最佳实践

### NF 粒度

| 工作量 | 写 NF 时间 | 说明 |
|--------|-----------|------|
| Small (<4h) | 5-10 分钟 | 简单功能 |
| Medium (4-16h) | 15-20 分钟 | 中等功能 |
| Large (>16h) | 30+ 分钟 | 复杂功能，考虑 /nf-deep |

### 并行上限

- **推荐**: 4-6 个 Agent
- **最大**: 8 个（再多认知超载）
- **信号**: 需要 Agent 总结工作时，就是太多了

### Commit 规范

```bash
# 格式
NF-XXX: [动词] [描述]

# 示例
NF-001: 添加用户登录组件
NF-002: 实现深色模式切换
NF-003: 修复登录页样式问题
```

---

## ⚠️ 常见问题

### Q: 小项目也需要 NF 吗？
**A**: 不需要每个功能都 NF。建议：
- > 4 小时的工作 → 创建 NF
- < 1 小时的 bug 修复 → 直接做

### Q: NF 写太细会不会浪费时间？
**A**: 经验法则：
- Small: 5-10 分钟写 NF
- Medium: 15-20 分钟
- Large: 30+ 分钟（可能需 /nf-deep）

### Q: 团队怎么用？
**A**: 
- 共享 FEATURE_INDEX.md
- 每人认领 NF 时更新负责人字段
- 每日站会过一遍 /nf-status

---

## 📖 参考
https://schipper.ai/posts/parallel-coding-agents/

---

**版本**: 1.0  
**日期**: 2026-03-03
