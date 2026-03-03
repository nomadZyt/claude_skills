# 📤 上传到 GitHub

## 方式 1：运行上传脚本（推荐）

```bash
cd ~/Desktop/nf-system
./upload-to-github.sh
```

会提示输入 GitHub 用户名和密码（或 Personal Access Token）。

## 方式 2：手动上传

```bash
cd ~/Desktop/nf-system

# 1. 初始化 Git（如果还没有）
git init

# 2. 添加所有文件
git add .

# 3. 提交
git commit -m "feat: NF System - New Feature 开发系统"

# 4. 设置分支名
git branch -M main

# 5. 添加远程仓库
git remote add origin https://github.com/nomadZyt/claude_skills.git

# 6. 推送
git push -u origin main
```

## 方式 3：使用 GitHub Desktop

1. 打开 GitHub Desktop
2. File → Add Local Repository → 选择 `~/Desktop/nf-system`
3. 点击 Publish repository
4. 选择 `nomadZyt/claude_skills` 仓库

---

## 🔑 使用 Personal Access Token

如果用 HTTPS 推送，建议使用 Personal Access Token 而不是密码：

1. 访问 https://github.com/settings/tokens
2. 生成新 token（选择 `repo` 权限）
3. 推送时用 token 代替密码

---

## ✅ 上传后

访问仓库查看：
https://github.com/nomadZyt/claude_skills
