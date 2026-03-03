#!/bin/bash
# 上传 NF System 到 GitHub 仓库
# 用法：./upload-to-github.sh

set -e

echo "🚀 上传 NF System 到 GitHub"
echo "=============================="
echo ""

cd ~/Desktop/nf-system

# 检查是否已有 git 仓库
if [ ! -d ".git" ]; then
    echo "📁 初始化 Git 仓库..."
    git init
fi

# 添加所有文件
echo "📦 添加文件..."
git add .

# 提交
echo "💾 提交更改..."
git commit -m "feat: NF System - New Feature 开发系统

- 添加完整的 NF 系统技能（Markdown 规范驱动开发）
- 支持并行运行 4-8 个 Coding Agent
- 包含 6 个斜杠命令（nf-new, status, explore, verify, close, deep）
- 集成 tmux 多窗口管理
- 添加完整文档（README, USAGE, TMUX-GUIDE）

参考：https://schipper.ai/posts/parallel-coding-agents/" || echo "（没有新更改）"

# 设置分支名
git branch -M main

# 添加远程仓库（如果还没有）
if ! git remote | grep -q origin; then
    echo "🔗 添加远程仓库..."
    git remote add origin https://github.com/nomadZyt/claude_skills.git
fi

# 推送
echo "📤 推送到 GitHub..."
echo ""
echo "需要输入 GitHub 用户名和密码（或 Personal Access Token）"
echo ""
git push -u origin main

echo ""
echo "✅ 上传完成！"
echo "🌐 查看：https://github.com/nomadZyt/claude_skills"
