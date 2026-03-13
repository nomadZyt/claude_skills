# NF System - New Feature 开发系统

用 Markdown 规范驱动开发，支持并行运行 4-8 个 Coding Agent。

---

## 🚀 快速开始

### 1. 安装到你的项目

```bash
# 进入你的项目
cd ~/your-project

# 运行初始化脚本
bash /path/to/nf-system/init.sh
```

### 2. 配置 tmux（可选）

```bash
# 备份现有配置
cp ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null || true

# 使用 NF 系统配置
cp /path/to/nf-system/tmux/.tmux.conf ~/.tmux.conf

# 重载配置
tmux source-file ~/.tmux.conf
```

### 3. 添加快捷命令（可选）

```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
echo 'alias nf-tmux="bash /path/to/nf-system/tmux/nf-tmux.sh"' >> ~/.zshrc
source ~/.zshrc
```

---

## 📚 使用文档

- **README.md** - 技能说明和使用指南
- **TMUX-GUIDE.md** - tmux 完整实战指南
- **SKILL.md** - 技能详细文档

---

## 📋 核心命令

| 命令 | 功能 |
|------|------|
| `/nf-new` | 创建新 NF |
| `/nf-status` | 查看所有 NF 状态 |
| `/nf-explore` | 加载项目上下文 |
| `/nf-verify` | 验证代码 |
| `/nf-close` | 关闭并归档 NF |
| `/nf-deep` | 并行深度分析 |
| `nf-tmux` | 启动 tmux 会话 |

---

## 📁 文件结构

```
nf-system/
├── README.md           # 使用指南
├── SKILL.md            # 技能说明
├── TMUX-GUIDE.md       # tmux 指南
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

## 💡 典型工作流

```bash
# 1. 启动 tmux 会话
nf-tmux my-project

# 2. 查看状态
/nf-status

# 3. 创建新 NF
/nf-new 用户登录功能优化

# 4. 加载上下文
/nf-explore

# 5. 开始实现
实现 NF-001，plan mode on

# 6. 验证代码
/nf-verify

# 7. 关闭 NF
/nf-close NF-001
```

---

## 📖 参考

- 原作者：Manuel Schipper
- 原文：https://schipper.ai/posts/parallel-coding-agents/

---

## 📦 分发说明

1. 将整个 `nf-system` 文件夹复制到其他电脑
2. 在任何项目中运行 `init.sh` 即可初始化
3. 建议配置 tmux 以获得最佳体验

---

**版本：** 1.0  
**日期：** 2026-03-03
