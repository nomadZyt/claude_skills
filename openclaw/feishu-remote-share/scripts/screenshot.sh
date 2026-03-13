#!/bin/bash

# 截图并发送到飞书
# 用法：
#   ./screenshot.sh              # 全屏截图
#   ./screenshot.sh --select     # 交互式选区
#   ./screenshot.sh --delay 3    # 延时3秒
#   ./screenshot.sh --window     # 窗口选择

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

# 解析参数
SCREENSHOT_MODE="fullscreen"
DELAY_SECONDS=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --select)
            SCREENSHOT_MODE="interactive"
            shift
            ;;
        --window)
            SCREENSHOT_MODE="window"
            shift
            ;;
        --delay)
            DELAY_SECONDS="$2"
            shift 2
            ;;
        --help)
            echo "用法："
            echo "  $0              # 全屏截图"
            echo "  $0 --select     # 交互式选区"
            echo "  $0 --window     # 窗口选择"
            echo "  $0 --delay 3    # 延时3秒后截图"
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            exit 1
            ;;
    esac
done

# 延时
if [ "$DELAY_SECONDS" -gt 0 ]; then
    log_info "延时 ${DELAY_SECONDS} 秒后截图..."
    sleep "$DELAY_SECONDS"
fi

# 创建临时文件
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCREENSHOT_PATH="/tmp/screenshot_${TIMESTAMP}.png"

# 执行截图
log_info "正在截图..."

case $SCREENSHOT_MODE in
    fullscreen)
        screencapture -x "$SCREENSHOT_PATH"
        ;;
    interactive)
        screencapture -i "$SCREENSHOT_PATH"
        ;;
    window)
        screencapture -w "$SCREENSHOT_PATH"
        ;;
esac

# 检查截图是否成功
if [ ! -f "$SCREENSHOT_PATH" ]; then
    log_error "截图失败或被取消"
    exit 1
fi

log_success "截图已保存: $SCREENSHOT_PATH"

# 读取配置
log_info "读取飞书配置..."
CONFIG=$(bash "$SCRIPT_DIR/config.sh")

if [ $? -ne 0 ]; then
    log_error "读取配置失败"
    log_warning "文件路径已复制到剪贴板"
    echo "$SCREENSHOT_PATH" | pbcopy
    exit 1
fi

IFS=',' read -r APP_ID APP_SECRET OPEN_ID <<< "$CONFIG"

# 获取 access token
log_info "获取飞书访问令牌..."
source "$SCRIPT_DIR/feishu-api.sh"
TOKEN=$(get_access_token "$APP_ID" "$APP_SECRET")

if [ $? -ne 0 ] || [ -z "$TOKEN" ]; then
    log_error "获取访问令牌失败"
    log_warning "文件路径已复制到剪贴板"
    echo "$SCREENSHOT_PATH" | pbcopy
    exit 1
fi

log_success "访问令牌获取成功"

# 上传文件
log_info "上传截图到飞书..."
FILE_KEY=$(upload_file "$TOKEN" "$SCREENSHOT_PATH")

if [ $? -ne 0 ] || [ -z "$FILE_KEY" ]; then
    log_error "上传文件失败"
    log_warning "文件路径已复制到剪贴板"
    echo "$SCREENSHOT_PATH" | pbcopy
    exit 1
fi

log_success "文件上传成功"

# 发送消息
log_info "发送截图到会话..."
MESSAGE_ID=$(send_file_message "$TOKEN" "$OPEN_ID" "$FILE_KEY")

if [ $? -ne 0 ] || [ -z "$MESSAGE_ID" ]; then
    log_error "发送消息失败"
    log_warning "文件路径已复制到剪贴板"
    echo "$SCREENSHOT_PATH" | pbcopy
    exit 1
fi

log_success "截图已发送到飞书会话！"

# 清理临时文件
rm -f "$SCREENSHOT_PATH"
log_info "临时文件已清理"

# 显示通知（如果支持）
if command -v osascript &> /dev/null; then
    osascript -e "display notification \"截图已发送到飞书\" with title \"截图成功\""
fi

echo ""
echo "🎉 完成！截图已自动发送到你的飞书会话"
