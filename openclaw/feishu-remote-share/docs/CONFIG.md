# 飞书远程分享技能 - 配置说明

## 🔧 配置方法

### 方式1：自动配对（推荐）

运行 OpenClaw 配对命令：

```bash
openclaw pair
```

这会自动创建配对文件，技能会自动读取你的飞书用户ID。

---

### 方式2：环境变量配置

如果自动配对失败，可以设置环境变量：

```bash
# 添加到 ~/.zshrc 或 ~/.bashrc
export FEISHU_OPEN_ID="ou_你的用户ID"

# 重新加载
source ~/.zshrc
```

---

### 方式3：手动配置（高级）

如果以上方法都失败，可以手动修改 `config.sh`：

```bash
# 编辑配置文件
nano ~/.openclaw/workspace/skills/feishu-remote-share/scripts/config.sh

# 找到这一行（约第30行）：
# OPEN_ID="${FEISHU_OPEN_ID:-}"

# 改成：
# OPEN_ID="${FEISHU_OPEN_ID:-ou_你的用户ID}"
```

---

## 🔍 如何获取你的飞书用户ID

### 方法1：通过飞书开放平台

1. 访问：https://open.feishu.cn/api-explorer/cli/user/info
2. 点击"获取用户信息"
3. 在响应中找到 `open_id`

### 方法2：通过配对文件

如果已经配对过：

```bash
cat ~/.openclaw/credentials/feishu-pairing.json | grep '"id"'
```

---

## ✅ 验证配置

运行测试脚本：

```bash
~/.openclaw/workspace/skills/feishu-remote-share/scripts/test.sh
```

如果看到 "✅ 配置读取成功"，说明配置正确！

---

## 🐛 常见问题

### 问题1：配置文件不存在

**错误信息：** `Error: OpenClaw config not found`

**解决：** 确保 OpenClaw 已正确安装并配置

### 问题2：飞书用户ID为空

**错误信息：** `Warning: Feishu OPEN_ID not found`

**解决：** 按照上面的三种配置方法之一进行配置

### 问题3：权限不足

**错误信息：** `Error: Failed to get access token`

**解决：** 检查飞书应用权限配置

---

## 📝 配置优先级

1. 配对文件（`~/.openclaw/credentials/feishu-pairing.json`）
2. 环境变量（`FEISHU_OPEN_ID`）
3. 手动配置（修改 `config.sh`）

---

## 💡 最佳实践

- ✅ 使用自动配对（`openclaw pair`）
- ✅ 如果失败，使用环境变量
- ✅ 避免硬编码用户ID
- ✅ 定期检查配置是否有效
