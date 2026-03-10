# NF System + tmux 实战指南

## 🎯 核心思路

| 层级 | 工具 | 职责 |
|------|------|------|
| **窗口管理** | tmux | 分窗口、导航、通知 |
| **内容管理** | NF 系统 | NF 创建、实现、验证 |
| **Agent 会话** | Claude Code | 每个窗口一个独立 Agent |

---

## 📁 快速开始（3 步）

### 1️⃣ 安装 tmux 配置
```bash
# 备份现有配置
cp ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null || true

# 使用 NF 系统配置
cp ~/.openclaw/workspace/skills/nf-system/tmux/.tmux.conf ~/.tmux.conf

# 重载配置（如果 tmux 已运行）
tmux source-file ~/.tmux.conf
```

### 2️⃣ 添加启动脚本到 PATH
```bash
# 复制脚本
cp ~/.openclaw/workspace/skills/nf-system/tmux/nf-tmux.sh /usr/local/bin/nf-tmux
chmod +x /usr/local/bin/nf-tmux

# 或者添加到 ~/.zshrc
echo 'alias nf-tmux="bash ~/.openclaw/workspace/skills/nf-system/tmux/nf-tmux.sh"' >> ~/.zshrc
source ~/.zshrc
```

### 3️⃣ 启动会话
```bash
# 进入项目
cd ~/your-frontend-project

# 启动 NF tmux 会话
nf-tmux my-project
```

---

## 🪟 窗口布局

```
┌─────────────────────────────────────────────────────────────┐
│  NF System: my-project                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  窗口 1: PM          窗口 2-4: Planner    窗口 5-7: Worker  │
│  - /nf-status        - /nf-explore        - 实现 NF-XXX    │
│  - /nf-new           - 设计 NF            - /nf-verify     │
│  - 管理 Backlog      - /nf-deep           - 写代码         │
│                                                             │
│  窗口 8: bash（手动命令/测试/运行）                          │
│  - git status        - npm test          - npm run dev     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## ⌨️ 核心快捷键

### 窗口导航
| 快捷键 | 功能 |
|--------|------|
| `Ctrl-b 1-9` | 跳转到窗口 1-9 |
| `Shift + ←/→` | 上一个/下一个窗口 |
| `Ctrl-b ,` | 重命名窗口 |
| `Ctrl-b s` | 浏览所有窗口 |

### 窗口管理
| 快捷键 | 功能 |
|--------|------|
| `Ctrl-b c` | 创建新窗口 |
| `Ctrl-b &` | 关闭当前窗口 |
| `Ctrl-b d` | 分离会话（后台运行） |

### 分屏
| 快捷键 | 功能 |
|--------|------|
| `Ctrl-b \|` | 垂直分屏（左右） |
| `Ctrl-b -` | 水平分屏（上下） |
| `Ctrl-b 方向键` | 切换分屏焦点 |

### 其他
| 快捷键 | 功能 |
|--------|------|
| `Ctrl-b r` | 重载 tmux 配置 |
| `Ctrl-b [` | 进入滚动模式（查看历史） |
| `Ctrl-b ]` | 粘贴 |

---

## 🎬 典型工作流

### 场景 1：开始一天的工作

```bash
# 1. 进入项目
cd ~/my-project

# 2. 启动/恢复 tmux 会话
nf-tmux my-project

# 或连接到现有会话
tmux attach -t my-project
```

### 场景 2：处理新需求

```
窗口 1 (PM):
┌─────────────────────────┐
│ /nf-status              │
│ /nf-new 用户登录优化    │
│                         │
│ ✅ 已创建 NF-001        │
└─────────────────────────┘

窗口 2 (Planner-1):
┌─────────────────────────┐
│ /nf-explore             │
│ 设计 NF-001             │
│ - 问题是什么？          │
│ - 方案有哪些？          │
│ - 要改哪些文件？        │
│                         │
│ ✅ NF-001 状态→Open     │
└─────────────────────────┘
```

### 场景 3：并行实现多个 NF

```
窗口 5 (Worker-1):
┌─────────────────────────┐
│ 实现 NF-001             │
│ - 创建登录组件          │
│ - 写 hooks              │
│ - /nf-verify            │
└─────────────────────────┘

窗口 6 (Worker-2):
┌─────────────────────────┐
│ 实现 NF-002             │
│ - 深色模式切换          │
│ - 主题 Context          │
│ - /nf-verify            │
└─────────────────────────┘

窗口 7 (Worker-3):
┌─────────────────────────┐
│ 实现 NF-003             │
│ - 性能优化              │
│ - 懒加载                │
│ - /nf-verify            │
└─────────────────────────┘
```

### 场景 4：复杂问题深度分析

```
窗口 3 (Planner-2):
┌─────────────────────────┐
│ /nf-deep 架构重构       │
│                         │
│ 正在启动 4 个并行 Agent:  │
│ 1. 算法角度分析         │
│ 2. 结构角度分析         │
│ 3. 渐进角度分析         │
│ 4. 环境角度分析         │
│                         │
│ ⏳ 分析中...            │
└─────────────────────────┘
```

---

## 🔔 Bell 通知配置

当 Agent 空闲时，tmux 窗口会变红提醒你需要输入。

### 配置 Claude Code 发送 Bell

在 `~/.claude/settings.json` 添加：
```json
{
  "hooks": {
    "Notification": {
      "matcher": "idle_prompt",
      "command": "echo -a '\\a'"
    }
  }
}
```

### tmux 自动高亮
已在 `.tmux.conf` 配置：
```bash
set -g monitor-bell on
set -g bell-action any
set-window-option -g window-status-bell-style fg=red,bold,reverse
```

---

## 📊 实际布局示例

### 三屏工作站
```
┌──────────────┬──────────────┬──────────────┐
│   Cursor     │   Ghostty 1  │   Ghostty 2  │
│   (IDE)      │   tmux       │   tmux       │
│              │              │              │
│  代码浏览    │  PM 窗口     │  Worker-1    │
│  手动编辑    │  Planner-1   │  Worker-2    │
│  跨模型检查  │  Planner-2   │  bash        │
└──────────────┴──────────────┴──────────────┘
```

### 单屏分屏
```bash
# 启动会话
nf-tmux my-project

# 垂直分屏：左边 PM，右边 Planner
Ctrl-b %

# 在右边再分屏
Ctrl-b "

# 现在你有 3 个 pane:
# [ PM | Planner ]
# [ PM | Worker  ]
```

---

## 🚀 高级技巧

### 1. 窗口命名规范
```bash
# 重命名窗口体现当前工作
Ctrl-b ,
# 输入：worker-nf001

# 结果：
# 1:PM  2:planner-nf001  3:worker-nf001
```

### 2. 快速跳转项目
在 `~/.zshrc` 添加：
```bash
alias gproj='cd ~/my-frontend-project'
alias gapi='cd ~/services/api-service'
alias gdata='cd ~/services/data-pipeline'

# 让 Agent 也能用
export -f gproj gapi gdata
```

使用：
```
你：在 gproj 运行 /nf-explore
Agent: ✅ 已加载 ~/my-frontend-project 上下文
```

### 3. 会话持久化
```bash
# 分离会话（后台运行）
Ctrl-b d

# 之后恢复
tmux attach -t my-project

# 查看所有会话
tmux ls
```

### 4. 日志记录
```bash
# 在 Worker 窗口记录实现过程
tmux pipe-pane -o my-project:Worker-1 'cat >> ~/logs/nf-worker1.log'
```

---

## ⚠️ 常见问题

### Q: 窗口太多记不住怎么办？
**A:** 
- 用 `Ctrl-b ,` 重命名窗口（如 `worker-nf001`）
- 用 `Ctrl-b s` 浏览所有窗口
- 保持 4-6 个活跃窗口，多了关掉

### Q: 如何同时运行多个 Agent？
**A:**
- 每个 tmux 窗口启动一个 Claude Code 会话
- 窗口 1: `claude` (PM)
- 窗口 2: `claude` (Planner)
- 窗口 5: `claude` (Worker)

### Q: Agent 卡住了怎么办？
**A:**
- `Ctrl-b [` 进入滚动模式查看历史
- `Ctrl-c` 中断当前命令
- 关闭窗口 `Ctrl-b &` 重新开一个

### Q: 如何备份会话配置？
**A:**
```bash
# 保存当前布局
tmux list-windows -t my-project

# 保存会话状态（需要 tmux-resurrect 插件）
```

---

## 📚 推荐插件

### tmux-resurrect（会话持久化）
```bash
# 安装 TPM (tmux plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 在 ~/.tmux.conf 添加
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'

# 安装插件
# 在 tmux 内按 Ctrl-b I
```

### tmux-continuum（自动保存）
```bash
# 在 ~/.tmux.conf 添加
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
```

---

## 🎯 每日工作流模板

```bash
# 早上开始
cd ~/my-project
nf-tmux my-project

# 窗口 1 (PM): 查看今天要做的事
/nf-status

# 窗口 2 (Planner): 设计新功能
/nf-explore
设计 NF-005

# 窗口 5 (Worker): 实现昨天的设计
实现 NF-004

# 窗口 8 (bash): 运行测试
npm test
npm run dev

# 中午休息
Ctrl-b d  # 分离会话

# 下午继续
tmux attach -t my-project

# 下班前
/nf-verify  # 验证完成的工作
/nf-close NF-004  # 归档完成的 NF

Ctrl-b d  # 分离，明天继续
```

---

## 📖 参考

- tmux 官方文档：https://github.com/tmux/tmux/wiki
- NF System 原文：https://schipper.ai/posts/parallel-coding-agents/
- 本技能位置：`~/.openclaw/workspace/skills/nf-system/`
