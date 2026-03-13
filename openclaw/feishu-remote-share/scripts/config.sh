#!/bin/bash

# 从 OpenClaw 配置中读取飞书配置
# 输出格式：APP_ID,APP_SECRET,OPEN_ID

CONFIG_FILE="$HOME/.openclaw/openclaw.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: OpenClaw config not found at $CONFIG_FILE" >&2
    exit 1
fi

# 读取飞书配置（从 feishu 节点读取）
APP_ID=$(cat "$CONFIG_FILE" | grep -A 50 '"feishu":' | grep '"appId"' | head -1 | sed 's/.*"appId": "\([^"]*\)".*/\1/')
APP_SECRET=$(cat "$CONFIG_FILE" | grep -A 50 '"feishu":' | grep '"appSecret"' | head -1 | sed 's/.*"appSecret": "\([^"]*\)".*/\1/')

# 读取当前用户的 Open ID
PAIRING_FILE="$HOME/.openclaw/credentials/feishu-pairing.json"
if [ -f "$PAIRING_FILE" ]; then
    OPEN_ID=$(cat "$PAIRING_FILE" | grep '"id":' | head -1 | sed 's/.*"id": "\([^"]*\)".*/\1/')
fi

# 如果配对文件不存在或为空，尝试从环境变量或默认配置读取
if [ -z "$OPEN_ID" ]; then
    # 尝试从环境变量读取
    OPEN_ID="${FEISHU_OPEN_ID:-}"

    # 如果环境变量也没有，提示用户配置
    if [ -z "$OPEN_ID" ]; then
        echo "Warning: Feishu OPEN_ID not found" >&2
        echo "Please either:" >&2
        echo "  1. Run 'openclaw pair' to pair your Feishu account" >&2
        echo "  2. Set FEISHU_OPEN_ID environment variable" >&2
        echo "  3. Or manually set OPEN_ID in this script" >&2
        echo "" >&2
        echo "Using empty OPEN_ID (will fail if not configured)" >&2
    fi
fi

# 验证配置
if [ -z "$APP_ID" ] || [ -z "$APP_SECRET" ] || [ -z "$OPEN_ID" ]; then
    echo "Error: Invalid Feishu configuration" >&2
    echo "APP_ID: $APP_ID" >&2
    echo "APP_SECRET: ${APP_SECRET:0:10}..." >&2
    echo "OPEN_ID: $OPEN_ID" >&2
    exit 1
fi

# 输出配置（用逗号分隔）
echo "$APP_ID,$APP_SECRET,$OPEN_ID"
