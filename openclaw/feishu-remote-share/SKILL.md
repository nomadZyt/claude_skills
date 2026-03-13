---
name: feishu-remote-share
description: |
  远程通过飞书分享部署了 OpenClaw 的机器上的文件或截图。当用户说"截图"、"发送文件"、"获取文件"或提供文件路径时触发。
---

# 飞书远程分享技能

## 功能说明

远程分享 OpenClaw 部署机器上的内容到飞书，包括：
- 📸 截图（全屏、选区、窗口、延时）
- 📁 文件传输（所有文件类型）

## 使用方法

### 截图功能

**对话中使用：**
```
截图发给我
截屏发送
帮我截个图
```

**终端调用：**
```bash
# 全屏截图
~/.openclaw/workspace/skills/feishu-remote-share/scripts/screenshot.sh

# 选区截图
~/.openclaw/workspace/skills/feishu-remote-share/scripts/screenshot.sh --select

# 延时3秒截图
~/.openclaw/workspace/skills/feishu-remote-share/scripts/screenshot.sh --delay 3

# 快捷命令
alias ss="~/.openclaw/workspace/skills/feishu-remote-share/scripts/screenshot.sh"
ss
```

### 文件传输功能

**对话中使用：**
```
发送文件 /path/to/file
获取文件 /path/to/file
上传文件 /path/to/file
```

或直接发送文件路径：
```
/Users/zhaiyongtao/.openclaw/workspace/MEMORY.md
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

本技能包含多层安全检测：

#### 1. 路径安全检测
- ✅ 防止路径遍历攻击（`../`）
- ✅ 禁止访问系统关键目录（`/etc/passwd`, `/root`）
- ✅ 路径规范化处理

#### 2. 敏感文件检测
- ✅ 检测敏感文件扩展名（`.env`, `.pem`, `.key`）
- ✅ 检测敏感文件名（`id_rsa`, `credentials`）
- ✅ 高危文件需要用户确认

#### 3. 文件权限检查
- ✅ 检查文件是否可读
- ✅ 检查文件是否存在
- ✅ 遵循系统权限控制

#### 4. 文件大小限制
- ✅ 单文件最大 30MB（飞书限制）
- ✅ 超过限制自动拒绝

#### 5. 文件类型验证
- ✅ 自动识别文件类型
- ✅ 检测文件扩展名与实际内容是否匹配

### 敏感文件列表

以下文件需要额外确认：
- `.env`, `.pem`, `.key`, `.p12`, `.pfx` - 密钥文件
- `id_rsa`, `id_ed25519` - SSH 私钥
- `credentials`, `secrets` - 凭证文件
- `.htpasswd`, `shadow`, `passwd` - 密码文件

### 禁止访问的路径

以下路径禁止访问：
- `/etc/passwd`, `/etc/shadow` - 系统密码文件
- `/root/*` - Root 用户目录
- `*/.ssh/*` - SSH 密钥目录（除非明确指定）

## 配置要求

### ✅ 自动配置

本技能使用 OpenClaw 内置的飞书集成，无需额外配置！

### 🔧 前置条件

需要配置飞书权限：
- `im:file` - 获取与上传文件

配置方法：
1. 访问：https://open.feishu.cn/app/cli_a924503e27e19bc3
2. 权限管理 → 搜索 "file"
3. 添加 "获取与上传文件 (im:file)"
4. 发布新版本

详细配置文档：`docs/feishu-file-upload-guide.md`

## 支持的文件类型

- ✅ 文本文件
- ✅ 图片
- ✅ 视频（mp4, avi, mov...）
- ✅ 音频（mp3, wav...）
- ✅ 压缩包
- ✅ 文档
- ✅ 代码文件
- ✅ 其他所有类型

## 使用场景

### 场景1：远程获取日志文件
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

### 场景4：分享代码文件
```
上传文件 ~/projects/app.js
```

### 场景5：批量操作
```bash
# 批量发送日志
for file in *.log; do send "$file"; done
```

## 限制说明

- 单个文件最大 30MB（飞书限制）
- 需要网络连接
- 需要 OpenClaw 服务运行中
- 敏感文件需要确认

## 故障排查

### 问题：安全检测失败

**错误信息：** "⚠️ 安全警告：检测到敏感文件"

**解决：**
- 确认文件是否包含敏感信息
- 如果确认安全，使用 `--force` 参数

### 问题：文件不存在

**错误信息：** "❌ 文件不存在"

**解决：** 检查文件路径是否正确

### 问题：权限不足

**错误信息：** "❌ 权限不足"

**解决：** 检查文件权限，或使用 sudo

### 问题：路径被禁止

**错误信息：** "❌ 禁止访问的路径"

**解决：** 该路径包含敏感系统文件，禁止访问

## 高级用法

### 强制发送敏感文件

```bash
# 使用 --force 参数（需谨慎）
send --force ~/.ssh/id_rsa
```

### 发送目录

```bash
# 先打包目录
tar -czf /tmp/project.tar.gz ~/projects/myapp

# 再发送
send /tmp/project.tar.gz
```

### 批量发送

```bash
# 发送最近1小时内修改的文件
find ~/Documents -type f -mtime -1h | while read file; do
  send "$file"
done
```

## 技术实现

### 核心流程

```
接收请求
    ↓
安全检测（路径、文件类型、权限）
    ↓
执行操作（截图/读取文件）
    ↓
上传到飞书
    ↓
发送消息
    ↓
✅ 完成
```

### 安全检测流程

```
接收路径
    ↓
路径规范化
    ↓
路径安全检测（防止遍历）
    ↓
敏感文件检测
    ↓
权限检查
    ↓
文件大小检查
    ↓
✅ 通过 / ❌ 拒绝
```

## 安全说明

### 权限控制

- ✅ 只能访问用户有权限的文件
- ✅ 遵循系统文件权限
- ✅ 敏感文件需要用户确认

### 隐私保护

- ✅ 文件通过飞书加密传输
- ✅ 不保留文件副本
- ✅ 上传记录可追溯
- ✅ 安全审计日志

### 最佳实践

- 🔒 定期审查发送的文件
- 🔒 不要发送包含密码的文件
- 🔒 谨慎使用 `--force` 参数
- 🔒 定期检查访问日志

## 版本历史

- v1.0.0 (2026-03-12) - 初始版本
  - ✅ 合并截图和文件传输功能
  - ✅ 添加完整的安全检测
  - ✅ 敏感文件检测
  - ✅ 路径安全验证
  - ✅ 文件权限检查
  - ✅ 文件大小限制
