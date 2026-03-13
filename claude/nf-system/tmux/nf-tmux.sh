#!/bin/bash
# nf-tmux - 启动 NF 系统专用的 tmux 会话
# 用法：nf-tmux [--with-claude] [项目名称] [项目路径]

set -e

# 解析参数
WITH_CLAUDE=false
if [ "$1" = "--with-claude" ]; then
    WITH_CLAUDE=true
    shift
fi

PROJECT_NAME="${1:-dev}"
PROJECT_PATH="${2:-$(pwd)}"

echo "🚀 启动 NF System tmux 会话：$PROJECT_NAME"
echo "📁 项目路径：$PROJECT_PATH"
[ "$WITH_CLAUDE" = true ] && echo "🤖 自动启动 Claude：已开启"
echo ""

# 检查会话是否已存在
if tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
    echo "⚠️  会话已存在，切换到现有会话"
    tmux attach-session -t "$PROJECT_NAME"
    exit 0
fi

# 创建新会话（窗口 1: PM）
tmux new-session -d -s "$PROJECT_NAME" -n "PM" -c "$PROJECT_PATH"

# 窗口 2-4: Planner（设计 NF）
tmux new-window -t "$PROJECT_NAME" -n "Planner-1" -c "$PROJECT_PATH"
tmux new-window -t "$PROJECT_NAME" -n "Planner-2" -c "$PROJECT_PATH"
tmux new-window -t "$PROJECT_NAME" -n "Planner-3" -c "$PROJECT_PATH"

# 窗口 5-7: Worker（实现 NF）
tmux new-window -t "$PROJECT_NAME" -n "Worker-1" -c "$PROJECT_PATH"
tmux new-window -t "$PROJECT_NAME" -n "Worker-2" -c "$PROJECT_PATH"
tmux new-window -t "$PROJECT_NAME" -n "Worker-3" -c "$PROJECT_PATH"

# 窗口 8: bash（手动命令/测试）
tmux new-window -t "$PROJECT_NAME" -n "bash" -c "$PROJECT_PATH"

# 在每个窗口打印提示
tmux send-keys -t "$PROJECT_NAME:PM" "echo '📋 PM 窗口 - 管理 Backlog' && echo '常用命令：/nf-status, /nf-new' && echo ''" Enter

for i in 1 2 3; do
    tmux send-keys -t "$PROJECT_NAME:Planner-$i" "echo '🧠 Planner 窗口 - 设计 NF' && echo '常用命令：/nf-explore, 设计 NF-XXX' && echo ''" Enter
done

for i in 1 2 3; do
    tmux send-keys -t "$PROJECT_NAME:Worker-$i" "echo '🔨 Worker 窗口 - 实现 NF' && echo '常用命令：实现 NF-XXX, /nf-verify' && echo ''" Enter
done

tmux send-keys -t "$PROJECT_NAME:bash" "echo '💻 bash 窗口 - 手动命令' && echo ''" Enter

# 如果指定了 --with-claude，在非 bash 窗口自动启动 claude
if [ "$WITH_CLAUDE" = true ]; then
    echo "🤖 在各窗口启动 Claude..."
    tmux send-keys -t "$PROJECT_NAME:PM" "claude" Enter
    for i in 1 2 3; do
        tmux send-keys -t "$PROJECT_NAME:Planner-$i" "claude" Enter
    done
    for i in 1 2 3; do
        tmux send-keys -t "$PROJECT_NAME:Worker-$i" "claude" Enter
    done
fi

# 附加到会话
echo "✅ 会话创建完成，正在连接..."
tmux attach-session -t "$PROJECT_NAME"
