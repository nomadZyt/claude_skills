# 飞书远程分享技能

远程通过飞书分享部署了 OpenClaw 的机器上的文件或截图。

## ✨ 特性

- 📸 **截图功能** - 全屏、选区、窗口、延时截图
- 📁 **文件传输** - 支持所有文件类型
- 🔒 **安全检测** - 多层安全检查，防止敏感信息泄露
- 🎯 **智能识别** - 自动识别文件类型
- 💻 **双模式** - 支持对话触发和终端调用

## 🚀 快速开始

### 截图功能

**对话中使用：**
```
截图发给我
```

**终端调用：**
```bash
# 全屏截图
~/.openclaw/workspace/skills/feishu-remote-share/scripts/screenshot.sh

# 选区截图
~/.openclaw/workspace/skills/feishu-remote-share/scripts/screenshot.sh --select

# 快捷命令
alias ss="~/.openclaw/workspace/skills/feishu-remote-share/scripts/screenshot.sh"
ss
```

### 文件传输功能

**对话中使用：**
```
发送文件 /path/to/file
```

**终端调用：**
```bash
# 发送文件
~/.openclaw/workspace/skills/feishu-remote-share/scripts/send-file.sh /path/to/file

# 快捷命令
alias send="~/.openclaw/workspace/skills/feishu-remote-share/scripts/send-file.sh"
send ~/Documents/report.pdf
```

## 🔒 安全检测

### 自动安全检查

#### 1. 路径安全检测
- ✅ 防止路径遍历攻击（`../`）
- ✅ 禁止访问系统关键目录

#### 2. 敏感文件检测
- ✅ 检测敏感文件扩展名（`.env`, `.pem`, `.key`）
- ✅ 检测敏感文件名（`id_rsa`, `credentials`）
- ✅ 高危文件需要用户确认

#### 3. 文件权限检查
- ✅ 检查文件是否可读
- ✅ 遵循系统权限控制

#### 4. 文件大小限制
- ✅ 单文件最大 30MB

### 敏感文件列表

以下文件需要额外确认：
- `.env`, `.pem`, `.key` - 密钥文件
- `id_rsa`, `id_ed25519` - SSH 私钥
- `credentials`, `secrets` - 凭证文件

### 强制发送敏感文件

```bash
# 使用 --force 参数（需谨慎）
send --force ~/.ssh/id_rsa
```

## 📖 使用场景

### 场景1：远程获取日志
```
发送文件 /var/log/system.log
```

### 场景2：快速截图分享
```
截图发给我
```

### 场景3：获取配置文件
```
获取文件 ~/.openclaw/openclaw.json
```

### 场景4：批量发送
```bash
for file in *.log; do send "$file"; done
```

## 📦 支持的文件类型

- ✅ 文本文件
- ✅ 图片（jpg, png, gif...）
- ✅ 视频（mp4, avi...）
- ✅ 音频（mp3, wav...）
- ✅ 压缩包（zip, tar.gz...）
- ✅ 文档（pdf, doc...）
- ✅ 代码文件
- ✅ 其他所有类型

## 📋 前置条件

需要配置飞书权限：

1. 访问：https://open.feishu.cn/app/cli_a924503e27e19bc3
2. 权限管理 → 搜索 "file"
3. 添加 "获取与上传文件 (im:file)"
4. 发布新版本

## 🐛 故障排查

### 问题：安全检测失败

**错误：** "⚠️ 安全警告：检测到敏感文件"

**解决：** 确认文件安全后使用 `--force` 参数

### 问题：文件不存在

**解决：** 检查文件路径是否正确

### 问题：权限不足

**解决：** 检查文件权限

## 📝 版本历史

### v1.0.0 (2026-03-12)
- ✅ 合并截图和文件传输功能
- ✅ 添加完整的安全检测
- ✅ 敏感文件检测
- ✅ 路径安全验证

---

**Made with ❤️ by Vector**
