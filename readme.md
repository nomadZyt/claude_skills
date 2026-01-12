# Weekly Report Skill

一个用于自动生成项目周报的 Claude Skill，可以分析 Git 提交记录并生成结构化的周报文档。

## 前置要求

- 已安装 Claude Code（Claude Desktop 应用）

## 安装步骤

1. **创建工作目录**
   - 在任意位置新建一个文件夹作为工作目录

2. **初始化 Claude 配置**
   - 进入该目录，执行 `claude` 命令
   - 完成初始化后，会在当前目录生成 `.claude` 文件夹

3. **安装 Skill**
   - 在 `.claude` 目录下创建 `skills` 文件夹（如果不存在）
   - 将 `weekly-report-skill` 目录复制到 `.claude/skills/` 目录下

4. **加载 Skill**
   - 执行 `claude` 命令
   - 输入：`加载 weekly-report-skill`

## 使用方法

执行 `claude` 命令后，输入以下指令：

```
使用weekly-report-skill对[项目路径]生成周报
```

**参数说明：**
- `[项目路径]`：可以是项目的根目录路径，或包含 Git 仓库的文件夹路径
- 支持绝对路径和相对路径

**使用示例：**
```
使用weekly-report-skill对/Users/user/Projects/my-project生成周报
```

或

```
使用weekly-report-skill对./my-project生成周报
```

## 功能说明

该 Skill 会自动：
- 分析指定项目的 Git 提交记录
- 按时间范围分类提交内容
- 生成结构化的周报文档