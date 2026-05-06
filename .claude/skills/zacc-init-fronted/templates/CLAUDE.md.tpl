# {项目名称}

<!-- 占位符填充规则：
  - 所有 {xxx} 占位符必须替换为实际检测值
  - 未检测到的项：填「未检测到」或「无」，不得留空占位符
  - 不适用的行：整行删除（如非 TypeScript 项目删除 TypeScript 行）
  - 生成完成后运行 verify-init.sh 确认无残留占位符
  - 生成完成后删除本注释块
-->

## 项目概述

{一句话描述：什么项目，核心功能，目标用户}

## 技术栈

<!-- 填充规则：
  - 每行的「技术选型」和「版本」从 package.json 或配置文件提取
  - 版本号写具体数字（如 18.2.0），不写 ^ 或 ~
  - 未使用的行整行删除（如无测试框架则删除「测试框架」行）
  - 「CSS 方案」「代码规范」「包管理器」版本列可填 —
-->

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

<!-- 填充规则：
  - 深度 2-3 层，仅列出 src/ 下的一级和重要二级目录
  - 每个目录必须有 # 职责说明
  - 若项目无 src/ 目录（如 Next.js app/），按实际根目录调整
  - 重要子目录可缩进展示（如 src/store/modules/）
-->

```
src/
├── {dir1}/          # {职责说明}
├── {dir2}/          # {职责说明}
├── {dir3}/          # {职责说明}
└── ...
```

## 开发命令

<!-- 填充规则：
  - 从 package.json scripts 字段提取
  - 未定义的命令整段删除（如无 test 脚本则删除「运行测试」段）
  - 有额外常用命令（如 preview / storybook / analyze）可追加
-->

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

<!-- 填充规则：
  - 从 ESLint / Prettier / Biome 配置文件和代码采样推断
  - 未检测到的项写「未检测到，建议遵循 {默认约定}」
  - 括号内示例在填写后删除
-->

- 文件命名：{fileNaming} （如 kebab-case / PascalCase）
- 组件命名：{componentNaming} （如 PascalCase）
- 变量/函数命名：{variableNaming} （如 camelCase）
- CSS 类名：{cssNaming} （如 BEM / CSS Modules / Tailwind）
- 缩进：{indent} （如 2 空格 / 4 空格 / Tab）
- 引号：{quote} （如 单引号 / 双引号）
- 分号：{semicolon} （如 使用 / 不使用）

## 业务特性

<!-- 填充规则：
  - 从步骤 4 的 business-features 分析结果填入
  - 未检测到任何特性时写「未检测到显著业务特性」
  - 每行的「相关代码」指向具体文件路径
-->

| 特性 | 说明 | 相关代码 |
|------|------|---------|

## Commit 规范

{commitFormat}

<!-- 填充规则：
  - 从 git log --oneline -20 和 commitlint 配置推断
  - 未检测到规范时写「未检测到统一的 Commit 规范」
  - 示例格式填写后删除本注释：
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

<!-- 填充规则：
  - 写 3-5 条项目特有约束（如环境变量前缀、代理配置、特殊部署要求）
  - 无特殊约束时写「暂无」
  - 例如：
    - 环境变量前缀必须为 VITE_
    - 接口地址通过 .env 文件配置
    - 不要直接修改 public/ 目录下的文件
-->

## 初始化日志

> 由 zacc-init-fronted 技能自动维护，记录每次初始化/更新的元信息。

| 时间 | 技能版本 | 模式 | 变更摘要 |
|------|---------|------|---------|
