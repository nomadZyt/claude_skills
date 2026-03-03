#!/bin/bash
# nf-init - 在任何项目中初始化 NF 系统
# 用法：./nf-init.sh [项目路径]

set -e

PROJECT_PATH="${1:-.}"

echo "🚀 NF 系统安装程序"
echo "====================="
echo ""

# 确认项目路径
if [ "$PROJECT_PATH" = "." ]; then
    PROJECT_PATH=$(pwd)
fi

echo "目标：$PROJECT_PATH"
echo ""

# 创建目录
echo "📁 创建目录..."
mkdir -p "$PROJECT_PATH/docs/features/archive"
mkdir -p "$PROJECT_PATH/docs/dev_guide"
mkdir -p "$PROJECT_PATH/.claude/commands"

# 复制模板
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📄 创建 FEATURE_INDEX.md..."
cp "$SKILL_DIR/templates/FEATURE_INDEX.md" "$PROJECT_PATH/docs/features/FEATURE_INDEX.md"
# 更新 FEATURE_INDEX.md 中的日期
sed -i.bak "s/{{date}}/$(date +%Y-%m-%d)/g" "$PROJECT_PATH/docs/features/FEATURE_INDEX.md"
rm -f "$PROJECT_PATH/docs/features/FEATURE_INDEX.md.bak"

echo "📄 创建 TEMPLATE.md..."
cp "$SKILL_DIR/templates/NF-TEMPLATE.md" "$PROJECT_PATH/docs/features/TEMPLATE.md"
sed -i.bak "s/{{date}}/$(date +%Y-%m-%d)/g" "$PROJECT_PATH/docs/features/TEMPLATE.md"
rm -f "$PROJECT_PATH/docs/features/TEMPLATE.md.bak"

echo "📄 创建开发规范示例..."
cat > "$PROJECT_PATH/docs/dev_guide/README.md" << 'EOF'
# 开发指南

此目录包含项目特定的开发规范。

## 建议的文件

- `react-components.md` - React 组件约定
- `testing.md` - 测试策略和工具
- `styling.md` - CSS/样式约定
- `api.md` - API 设计模式

## 使用方式

Agent 通过 `/nf-explore` 或在提示时按需读取这些文件。
EOF

echo "📄 复制斜杠命令..."
cp "$SKILL_DIR/commands/"*.md "$PROJECT_PATH/.claude/commands/"

echo "📄 更新 CLAUDE.md..."
if [ -f "$PROJECT_PATH/CLAUDE.md" ]; then
    # 如果不存在则追加 NF 系统章节
    if ! grep -q "NF 系统" "$PROJECT_PATH/CLAUDE.md"; then
        echo "" >> "$PROJECT_PATH/CLAUDE.md"
        cat "$SKILL_DIR/templates/CLAUDE.md" >> "$PROJECT_PATH/CLAUDE.md"
    else
        echo "  (CLAUDE.md 已有 NF 系统章节)"
    fi
else
    cp "$SKILL_DIR/templates/CLAUDE.md" "$PROJECT_PATH/CLAUDE.md"
fi

echo "📄 创建初始 NF-000..."
cat > "$PROJECT_PATH/docs/features/NF-000-init.md" << EOF
NF-000: NF 系统初始化

状态：Complete      优先级：High
工作量：Small       影响：开发工作流基础

## 问题
需要结构化的方法来管理 AI Agent 的功能开发。

## 方案
实现 NF (New Feature) 系统：
1. 创建 docs/features/ 目录结构
2. 创建 FEATURE_INDEX.md 用于追踪
3. 创建 NF 模板
4. 安装 6 个斜杠命令
5. 更新 CLAUDE.md 约定

## 修改的文件
- docs/features/FEATURE_INDEX.md (新增)
- docs/features/TEMPLATE.md (新增)
- docs/dev_guide/README.md (新增)
- .claude/commands/nf-*.md (新增 6 个)
- CLAUDE.md (修改)

## 验证
- [x] 目录结构已创建
- [x] 所有文件到位
- [x] 斜杠命令已安装

---
创建日期：$(date +%Y-%m-%d)
完成日期：$(date +%Y-%m-%d)
EOF

echo ""
echo "✅ NF 系统安装成功！"
echo ""
echo "📁 已创建的结构："
echo "   docs/features/FEATURE_INDEX.md"
echo "   docs/features/TEMPLATE.md"
echo "   docs/features/NF-000-init.md"
echo "   docs/dev_guide/"
echo "   .claude/commands/nf-*.md (6 个命令)"
echo "   CLAUDE.md (已更新)"
echo ""
echo "🚀 下一步："
echo "   1. 查看 docs/features/NF-000-init.md"
echo "   2. 运行 /nf-explore 加载上下文"
echo "   3. 运行 /nf-new 创建第一个 NF"
echo ""
echo "📚 可用命令："
echo "   /nf-new      - 创建新 NF"
echo "   /nf-status   - 查看所有 NF"
echo "   /nf-explore  - 加载项目上下文"
echo "   /nf-verify   - 验证代码"
echo "   /nf-close    - 关闭 NF"
echo "   /nf-deep     - 并行分析"
echo ""
