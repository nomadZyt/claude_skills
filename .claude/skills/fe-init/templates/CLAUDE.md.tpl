# {项目名称}

## 项目概述

{一句话描述：什么项目，核心功能，目标用户}

## 技术栈

| 类别 | 技术选型 | 版本 |
|------|---------|------|
| 框架 | {framework} | {version} |
| 状态管理 | {stateManagement} | {version} |
| 路由 | {router} | {version} |
| UI 组件库 | {uiLib} | {version} |
| 构建工具 | {buildTool} | {version} |
| HTTP 客户端 | {httpClient} | {version} |
| CSS 方案 | {cssScheme} | — |
| 测试框架 | {testFramework} | {version} |
| 代码规范 | {lintTools} | — |
| 包管理器 | {packageManager} | — |
| TypeScript | {yes/no} | {version} |

## 项目结构

```
src/
├── {dir1}/          # {职责说明}
├── {dir2}/          # {职责说明}
├── {dir3}/          # {职责说明}
└── ...
```

## 开发命令

```bash
# 安装依赖
{installCommand}

# 启动开发服务器
{devCommand}

# 构建
{buildCommand}

# 运行测试
{testCommand}

# 代码检查
{lintCommand}

# 格式化
{formatCommand}
```

## 代码规范

- 文件命名：{fileNaming} （如 kebab-case / PascalCase）
- 组件命名：{componentNaming} （如 PascalCase）
- 变量/函数命名：{variableNaming} （如 camelCase）
- CSS 类名：{cssNaming} （如 BEM / CSS Modules / Tailwind）
- 缩进：{indent} （如 2 空格 / 4 空格 / Tab）
- 引号：{quote} （如 单引号 / 双引号）
- 分号：{semicolon} （如 使用 / 不使用）

## Commit 规范

{commitFormat}

<!-- 示例格式：
- Conventional Commits: `feat: 添加用户登录组件`
- 自定义格式: `NF-XXX: [动词] [描述]`
-->

## AI 红线规则

> 修改或添加代码时必须遵守的红线规则，详见：
> - [AI 红线规则](.claude/AI_RULES.md)

## 纠错记录

> AI 在本项目中犯过的错误和用户的纠正，避免重复犯错。
> 每次用户纠错时，自动追加一条记录到此章节。

<!-- 格式：- [YYYY-MM-DD] {错误描述} → {正确做法} -->

## 注意事项

{项目特有的约束和注意事项}

<!-- 例如：
- 环境变量前缀必须为 VITE_
- 接口地址通过 .env 文件配置
- 不要直接修改 public/ 目录下的文件
-->
