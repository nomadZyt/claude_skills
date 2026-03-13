---
name: feishu-download
description: |
  飞书文档附件下载技能。支持下载飞书云文档中的图片、文件附件（ZIP、PDF、MD 等）。
  触发词："下载飞书文档"、"下载附件"、"download feishu doc"、"保存飞书图片"
---

# 飞书文档附件下载技能

## 功能说明

本技能用于下载飞书云文档中的附件，包括：
- 🖼️ 图片（PNG、JPG、GIF 等）
- 📄 文档（MD、PDF、DOCX 等）
- 📦 压缩包（ZIP、RAR 等）
- 📊 其他文件类型

---

## 使用方法

### 方式一：直接告诉我要下载的文档链接

```
"下载这个飞书文档的所有附件：https://xxx.feishu.cn/docx/ABC123def"
"保存飞书文档里的图片：https://xxx.feishu.cn/docx/ABC123def"
"把文档里的 INSTALL.md 下载到桌面"
```

### 方式二：提供文档 Token

```
"下载文档 XsfHwT4ESi6ZOYkvq8VczxOgnmb 的所有附件"
```

---

## 工作流程

### 1️⃣ 获取 tenant_access_token

```bash
curl -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "cli_xxx",
    "app_secret": "xxx"
  }'
```

**返回**：
```json
{
  "code": 0,
  "tenant_access_token": "t-xxx",
  "expire": 7200
}
```

---

### 2️⃣ 读取文档块，获取附件 Token

```bash
curl -X GET "https://open.feishu.cn/open-apis/docx/v1/documents/{doc_token}/blocks" \
  -H "Authorization: Bearer {tenant_access_token}"
```

**返回示例**：
```json
{
  "blocks": [
    {
      "block_type": 27,
      "image": {
        "token": "WEyvbJMeto4B9wxBrTYc6Uo4n1b",
        "width": 97,
        "height": 393
      }
    },
    {
      "block_type": 23,
      "file": {
        "name": "INSTALL.md",
        "token": "JVp2bF5zZoeWWlxMXvkc8QRCnZm"
      }
    }
  ]
}
```

---

### 3️⃣ 下载附件

**通用下载接口**（图片和文件都适用）：

```bash
curl -X GET "https://open.feishu.cn/open-apis/drive/v1/medias/{media_token}/download" \
  -H "Authorization: Bearer {tenant_access_token}" \
  -o {本地文件名}
```

**示例**：
```bash
# 下载图片
curl "https://open.feishu.cn/open-apis/drive/v1/medias/WEyvbJMeto4B9wxBrTYc6Uo4n1b/download" \
  -H "Authorization: Bearer t-xxx" \
  -o ~/Desktop/图片.jpg

# 下载 MD 文件
curl "https://open.feishu.cn/open-apis/drive/v1/medias/JVp2bF5zZoeWWlxMXvkc8QRCnZm/download" \
  -H "Authorization: Bearer t-xxx" \
  -o ~/Desktop/INSTALL.md

# 下载 ZIP 文件
curl "https://open.feishu.cn/open-apis/drive/v1/medias/SiNHbPaO0odxvNxYVz5cRjxRnUh/download" \
  -H "Authorization: Bearer t-xxx" \
  -o ~/Desktop/归档.zip
```

---

## 完整脚本

```bash
#!/bin/bash

# 飞书文档附件下载脚本
# 用法：./feishu-download.sh {doc_token} {save_dir}

DOC_TOKEN=$1
SAVE_DIR=${2:-~/Desktop}

# 配置（从配置文件读取）
APP_ID="cli_a92bca802c389bdb"
APP_SECRET="rn61evSKk9vSpHeBo4IO7g5acW60gjJB"

# 1. 获取 tenant_access_token
echo "📝 获取访问令牌..."
TOKEN_RESPONSE=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}")

TENANT_TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"tenant_access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TENANT_TOKEN" ]; then
    echo "❌ 获取 token 失败"
    exit 1
fi

echo "✅ Token 获取成功"

# 2. 读取文档块
echo "📖 读取文档块..."
BLOCKS_RESPONSE=$(curl -s -X GET "https://open.feishu.cn/open-apis/docx/v1/documents/$DOC_TOKEN/blocks" \
  -H "Authorization: Bearer $TENANT_TOKEN")

# 3. 提取媒体 token（图片和文件）
echo "🔍 提取附件信息..."
MEDIA_TOKENS=$(echo $BLOCKS_RESPONSE | grep -o '"token":"[A-Za-z0-9]*"' | cut -d'"' -f4)

# 4. 下载每个附件
echo "⬇️  开始下载..."
for TOKEN in $MEDIA_TOKENS; do
    echo "  下载：$TOKEN"
    curl -s -X GET "https://open.feishu.cn/open-apis/drive/v1/medias/$TOKEN/download" \
      -H "Authorization: Bearer $TENANT_TOKEN" \
      -o "$SAVE_DIR/feishu_$TOKEN"
done

echo "✅ 下载完成！文件保存在：$SAVE_DIR"
```

---

## API 端点说明

| API | 用途 | 方法 |
|-----|------|------|
| `/open-apis/auth/v3/tenant_access_token/internal` | 获取访问令牌 | POST |
| `/open-apis/docx/v1/documents/{doc_token}/blocks` | 读取文档块 | GET |
| `/open-apis/drive/v1/medias/{media_token}/download` | 下载附件 | GET |

---

## 注意事项

1. **Token 有效期**：`tenant_access_token` 有效期 2 小时，过期需重新获取
2. **权限要求**：飞书应用需要以下权限：
   - `docx:document` - 读取文档
   - `drive:file` - 下载文件
3. **下载限制**：单个文件最大 100MB
4. **速率限制**：API 调用频率限制 100 次/分钟

---

## 常见问题

### Q: 为什么下载返回 404？
A: 确保使用正确的 API 端点：
- ✅ `drive/v1/medias/{token}/download` - 文档附件
- ❌ `drive/v1/files/{token}/download` - 独立云盘文件

### Q: 为什么 token 无效？
A: 检查：
1. app_id 和 app_secret 是否正确
2. token 是否过期（有效期 2 小时）
3. 飞书应用是否有对应权限

### Q: 如何下载大文件？
A: 添加 `-L` 参数跟随重定向：
```bash
curl -L "https://..." -o file.zip
```

---

## 配置

在 `~/.openclaw/config.yaml` 中添加：

```yaml
channels:
  feishu:
    tools:
      doc: true
    app_id: "cli_xxx"
    app_secret: "xxx"
```

---

*最后更新：2026-03-11*
