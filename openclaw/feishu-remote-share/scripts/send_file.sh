#!/bin/bash

# 发送文件到飞书
# 用法：./send-file.sh /path/to/file [--force]

set -e

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# 检查参数
if [ -z "$1" ]; then
    log_error "请提供文件路径"
    echo ""
    echo "用法："
    echo "  $0 /path/to/file"
    echo "  $0 /path/to/file --force  # 强制发送敏感文件"
    echo ""
    echo "示例："
    echo "  $0 ~/Documents/report.pdf"
    echo "  $0 /var/log/system.log"
    exit 1
fi

FILE_PATH="$1"
FORCE="false"

# 检查 --force 参数
if [ "$2" = "--force" ]; then
    FORCE="true"
fi

# 处理 ~ 路径
FILE_PATH="${FILE_PATH/#\~/$HOME}"

# 加载安全检测模块
source "$SCRIPT_DIR/security-check.sh"

# 执行安全检测
comprehensive_security_check "$FILE_PATH" "$FORCE"
if [ $? -ne 0 ]; then
    exit 1
fi

echo ""

# 显示文件信息
log_info "准备发送文件..."
FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null)
echo "   文件: $(basename "$FILE_PATH")"
echo "   大小: $(($FILE_SIZE / 1024))KB"
echo "   路径: $FILE_PATH"
echo ""

# 读取配置
log_info "读取飞书配置..."
CONFIG=$(bash "$SCRIPT_DIR/config.sh")

if [ $? -ne 0 ]; then
    log_error "读取配置失败"
    exit 1
fi

IFS=',' read -r APP_ID APP_SECRET OPEN_ID <<< "$CONFIG"

# 获取 access token
log_info "获取飞书访问令牌..."
source "$SCRIPT_DIR/feishu-api.sh"
TOKEN=$(get_access_token "$APP_ID" "$APP_SECRET")

if [ $? -ne 0 ] || [ -z "$TOKEN" ]; then
    log_error "获取访问令牌失败"
    exit 1
fi

log_success "访问令牌获取成功"

# 上传文件
log_info "上传文件到飞书..."
FILE_KEY=$(upload_file "$TOKEN" "$FILE_PATH")

if [ $? -ne 0 ] || [ -z "$FILE_KEY" ]; then
    log_error "上传文件失败"
    exit 1
fi

log_success "文件上传成功"
echo "   File Key: $FILE_KEY"

# 发送消息
log_info "发送文件到会话..."
MESSAGE_ID=$(send_file_message "$TOKEN" "$OPEN_ID" "$FILE_KEY")

if [ $? -ne 0 ] || [ -z "$MESSAGE_ID" ]; then
    log_error "发送消息失败"
    exit 1
fi

log_success "文件已发送到飞书会话！"
echo "   Message ID: $MESSAGE_ID"

# 显示通知（如果支持）
if command -v osascript &> /dev/null; then
    osascript -e "display notification \"$(basename "$FILE_PATH") 已发送到飞书\" with title \"文件发送成功\""
fi

echo ""
echo "🎉 完成！文件已自动发送到你的飞书会话"
