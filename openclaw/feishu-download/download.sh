#!/bin/bash

# 飞书文档附件下载脚本
# 用法：./download.sh {doc_token} {save_dir}

set -e

DOC_TOKEN=$1
SAVE_DIR=${2:-~/Desktop}

# 配置
APP_ID="cli_a92bca802c389bdb"
APP_SECRET="rn61evSKk9vSpHeBo4IO7g5acW60gjJB"
FEISHU_API="https://open.feishu.cn"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查参数
if [ -z "$DOC_TOKEN" ]; then
    echo "用法：$0 {doc_token} [save_dir]"
    echo "示例：$0 XsfHwT4ESi6ZOYkvq8VczxOgnmb ~/Desktop"
    exit 1
fi

# 创建保存目录
mkdir -p "$SAVE_DIR"

# 1. 获取 tenant_access_token
echo_info "📝 获取访问令牌..."
TOKEN_RESPONSE=$(curl -s -X POST "$FEISHU_API/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}")

TENANT_TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"tenant_access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TENANT_TOKEN" ]; then
    echo_error "❌ 获取 token 失败"
    echo "$TOKEN_RESPONSE"
    exit 1
fi

echo_info "✅ Token 获取成功（有效期 2 小时）"

# 2. 读取文档块
echo_info "📖 读取文档块..."
BLOCKS_RESPONSE=$(curl -s -X GET "$FEISHU_API/open-apis/docx/v1/documents/$DOC_TOKEN/blocks" \
  -H "Authorization: Bearer $TENANT_TOKEN")

# 检查响应
if echo $BLOCKS_RESPONSE | grep -q '"code":0'; then
    echo_info "✅ 文档读取成功"
else
    echo_error "❌ 读取文档失败"
    echo "$BLOCKS_RESPONSE"
    exit 1
fi

# 3. 提取媒体 token（支持 image 和 file 类型）
echo_info "🔍 提取附件信息..."

# 使用更精确的提取方式
MEDIA_TOKENS=$(echo $BLOCKS_RESPONSE | grep -oE '"token":"[A-Za-z0-9_]+"' | cut -d'"' -f4 | sort -u)

if [ -z "$MEDIA_TOKENS" ]; then
    echo_warn "⚠️  未找到附件"
    exit 0
fi

echo "找到以下附件："
echo "$MEDIA_TOKENS" | while read TOKEN; do
    echo "  - $TOKEN"
done

# 4. 下载每个附件
echo_info "⬇️  开始下载..."
DOWNLOADED=0
FAILED=0

for TOKEN in $MEDIA_TOKENS; do
    OUTPUT_FILE="$SAVE_DIR/feishu_$TOKEN"
    
    echo "  下载：$TOKEN"
    
    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$OUTPUT_FILE" \
      -X GET "$FEISHU_API/open-apis/drive/v1/medias/$TOKEN/download" \
      -H "Authorization: Bearer $TENANT_TOKEN")
    
    if [ "$HTTP_CODE" = "200" ]; then
        FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
        echo "    ✅ 成功 ($FILE_SIZE)"
        ((DOWNLOADED++))
    else
        echo "    ❌ 失败 (HTTP $HTTP_CODE)"
        rm -f "$OUTPUT_FILE"
        ((FAILED++))
    fi
done

# 总结
echo ""
echo "================================"
echo_info "下载完成！"
echo "  成功：$DOWNLOADED 个文件"
echo "  失败：$FAILED 个文件"
echo "  保存位置：$SAVE_DIR"
echo "================================"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
