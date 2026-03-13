#!/bin/bash

# 安全检测模块
# 提供文件和路径的安全检查功能

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 敏感文件扩展名
SENSITIVE_EXTENSIONS=(
    "env"
    "pem"
    "key"
    "p12"
    "pfx"
    "secret"
    "credentials"
)

# 敏感文件名模式
SENSITIVE_PATTERNS=(
    "id_rsa"
    "id_ed25519"
    "id_dsa"
    "id_ecdsa"
    "credentials"
    "secrets"
    ".htpasswd"
    "shadow"
    "passwd"
    "private"
)

# 禁止访问的路径模式
FORBIDDEN_PATHS=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
    "/root"
)

# 安全检测：路径遍历检查
check_path_traversal() {
    local file_path="$1"

    if [[ "$file_path" == *".."* ]]; then
        echo -e "${RED}❌ 安全警告：检测到路径遍历攻击${NC}" >&2
        echo "   路径包含 '..'，禁止访问" >&2
        return 1
    fi

    return 0
}

# 安全检测：禁止路径检查
check_forbidden_path() {
    local file_path="$1"

    local normalized_path=$(cd "$(dirname "$file_path")" 2>/dev/null && pwd)/$(basename "$file_path")

    for forbidden in "${FORBIDDEN_PATHS[@]}"; do
        if [[ "$normalized_path" == *"$forbidden"* ]]; then
            echo -e "${RED}❌ 安全警告：禁止访问系统关键路径${NC}" >&2
            echo "   路径: $forbidden" >&2
            return 1
        fi
    done

    return 0
}

# 安全检测：敏感文件检查
check_sensitive_file() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    local extension="${filename##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    for ext in "${SENSITIVE_EXTENSIONS[@]}"; do
        if [ "$extension" = "$ext" ]; then
            echo -e "${YELLOW}⚠️  警告：检测到敏感文件类型${NC}" >&2
            echo "   文件扩展名: .$extension" >&2
            echo "   该文件可能包含敏感信息（密钥、凭证等）" >&2
            return 1
        fi
    done

    local filename_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if [[ "$filename_lower" == *"$pattern"* ]]; then
            echo -e "${YELLOW}⚠️  警告：检测到敏感文件名${NC}" >&2
            echo "   文件名匹配模式: $pattern" >&2
            echo "   该文件可能包含敏感信息" >&2
            return 1
        fi
    done

    if [[ "$file_path" == *"/.ssh/"* ]]; then
        echo -e "${YELLOW}⚠️  警告：检测到 SSH 密钥目录${NC}" >&2
        echo "   该目录通常包含 SSH 私钥" >&2
        return 1
    fi

    return 0
}

# 安全检测：文件权限检查
check_file_permission() {
    local file_path="$1"

    if [ ! -e "$file_path" ]; then
        echo -e "${RED}❌ 文件不存在${NC}" >&2
        return 1
    fi

    if [ ! -f "$file_path" ]; then
        echo -e "${RED}❌ 不是文件${NC}" >&2
        echo "   如果是目录，请先打包" >&2
        return 1
    fi

    if [ ! -r "$file_path" ]; then
        echo -e "${RED}❌ 权限不足：无法读取文件${NC}" >&2
        return 1
    fi

    return 0
}

# 安全检测：文件大小检查
check_file_size() {
    local file_path="$1"
    local max_size_mb="${2:-30}"

    local file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    local max_size=$((max_size_mb * 1024 * 1024))

    if [ "$file_size" -gt "$max_size" ]; then
        local size_mb=$(($file_size / 1024 / 1024))
        echo -e "${RED}❌ 文件太大: ${size_mb}MB${NC}" >&2
        echo "   飞书限制单个文件最大 ${max_size_mb}MB" >&2
        return 1
    fi

    return 0
}

# 综合安全检测
comprehensive_security_check() {
    local file_path="$1"
    local force="${2:-false}"

    echo "🔍 执行安全检测..."
    echo ""

    check_path_traversal "$file_path"
    if [ $? -ne 0 ]; then
        return 1
    fi

    check_forbidden_path "$file_path"
    if [ $? -ne 0 ]; then
        return 1
    fi

    check_file_permission "$file_path"
    if [ $? -ne 0 ]; then
        return 1
    fi

    check_file_size "$file_path"
    if [ $? -ne 0 ]; then
        return 1
    fi

    check_sensitive_file "$file_path"
    if [ $? -ne 0 ]; then
        if [ "$force" = "true" ]; then
            echo ""
            echo -e "${YELLOW}⚠️  使用 --force 参数，跳过敏感文件警告${NC}"
        else
            echo ""
            echo "💡 如果确认文件安全，请使用 --force 参数："
            echo "   send --force \"$file_path\""
            return 1
        fi
    fi

    echo "✅ 安全检测通过"
    return 0
}
