#!/bin/bash

# 飞书 API 封装脚本
# 提供获取 token、上传文件、发送消息的功能

# 获取 tenant_access_token
# 参数：APP_ID, APP_SECRET
get_access_token() {
    local app_id="$1"
    local app_secret="$2"

    local response=$(curl -s -X POST \
        "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
        -H "Content-Type: application/json" \
        -d "{
            \"app_id\": \"$app_id\",
            \"app_secret\": \"$app_secret\"
        }")

    local token=$(echo "$response" | grep -o '"tenant_access_token":"[^"]*"' | sed 's/"tenant_access_token":"//;s/"//')

    if [ -z "$token" ]; then
        echo "Error: Failed to get access token" >&2
        echo "Response: $response" >&2
        return 1
    fi

    echo "$token"
}

# 根据文件扩展名判断文件类型
# 参数：FILE_PATH
get_file_type() {
    local file_path="$1"
    local extension="${file_path##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    case "$extension" in
        jpg|jpeg|png|gif|bmp|webp|svg)
            echo "image"
            ;;
        mp4|avi|mov|wmv|flv|mkv)
            echo "media"
            ;;
        mp3|wav|flac|aac|ogg)
            echo "media"
            ;;
        *)
            echo "stream"
            ;;
    esac
}

# 上传文件到飞书
# 参数：ACCESS_TOKEN, FILE_PATH
upload_file() {
    local access_token="$1"
    local file_path="$2"

    if [ ! -f "$file_path" ]; then
        echo "Error: File not found: $file_path" >&2
        return 1
    fi

    local filename=$(basename "$file_path")
    local file_type=$(get_file_type "$file_path")

    local response=$(curl -s -X POST \
        "https://open.feishu.cn/open-apis/im/v1/files" \
        -H "Authorization: Bearer $access_token" \
        -F "file_name=$filename" \
        -F "file_type=$file_type" \
        -F "file=@$file_path")

    local file_key=$(echo "$response" | grep -o '"file_key":"[^"]*"' | sed 's/"file_key":"//;s/"//')

    if [ -z "$file_key" ]; then
        echo "Error: Failed to upload file" >&2
        echo "Response: $response" >&2
        return 1
    fi

    echo "$file_key"
}

# 发送文件消息
# 参数：ACCESS_TOKEN, OPEN_ID, FILE_KEY
send_file_message() {
    local access_token="$1"
    local open_id="$2"
    local file_key="$3"

    local response=$(curl -s -X POST \
        "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        -d "{
            \"receive_id\": \"$open_id\",
            \"msg_type\": \"file\",
            \"content\": \"{\\\"file_key\\\": \\\"$file_key\\\"}\"
        }")

    local message_id=$(echo "$response" | grep -o '"message_id":"[^"]*"' | sed 's/"message_id":"//;s/"//')

    if [ -z "$message_id" ]; then
        echo "Error: Failed to send message" >&2
        echo "Response: $response" >&2
        return 1
    fi

    echo "$message_id"
}

# 如果直接运行此脚本，进行测试
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "Testing Feishu API wrapper..."

    # 读取配置
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG=$(bash "$SCRIPT_DIR/config.sh")

    IFS=',' read -r APP_ID APP_SECRET OPEN_ID <<< "$CONFIG"

    echo "App ID: $APP_ID"
    echo "Open ID: $OPEN_ID"
    echo "Getting access token..."

    TOKEN=$(get_access_token "$APP_ID" "$APP_SECRET")
    if [ $? -eq 0 ]; then
        echo "✅ Token obtained: ${TOKEN:0:20}..."
    else
        echo "❌ Failed to get token"
        exit 1
    fi
fi
