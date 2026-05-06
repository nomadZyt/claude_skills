# 代码规范提取方法

> 供 zacc-init-fronted 步骤 3 使用，从配置文件和代码采样中提取项目的编码规范。
> 分析结果用于步骤 5 提取代码风格红线和步骤 6 填充 CLAUDE.md 代码规范章节。

## 配置文件读取

### 1. ESLint 配置

**按优先级搜索**（找到一个即停止）：

| 优先级 | 文件 | 说明 |
|--------|------|------|
| 1 | `eslint.config.*` (js/mjs/cjs/ts) | Flat Config（ESLint 9+） |
| 2 | `.eslintrc.*` (js/cjs/json/yaml/yml) | Legacy Config |
| 3 | `package.json` → `eslintConfig` 字段 | 内联配置 |

**提取要点**：
- 继承的预设（extends）：如 `@typescript-eslint/recommended`、`plugin:react/recommended`
- 关键规则覆盖（rules）：分号、引号、缩进、命名规范
- 忽略模式（ignorePatterns）

### 2. Prettier 配置

**按优先级搜索**：

| 优先级 | 文件 |
|--------|------|
| 1 | `.prettierrc` (json/yaml) |
| 2 | `.prettierrc.*` (js/cjs/mjs/toml) |
| 3 | `prettier.config.*` (js/cjs/mjs) |
| 4 | `package.json` → `prettier` 字段 |

**提取要点**：
- `tabWidth` → 缩进宽度
- `useTabs` → Tab / 空格
- `singleQuote` → 引号风格
- `semi` → 分号
- `trailingComma` → 尾逗号
- `printWidth` → 最大行宽

### 3. Biome 配置

**搜索文件**：`biome.json` / `biome.jsonc`

**提取要点**：
- `formatter.indentStyle` / `formatter.indentWidth`
- `javascript.formatter.quoteStyle` / `javascript.formatter.semicolons`
- `linter.rules` 中启用/禁用的规则

### 4. TypeScript 配置

**搜索文件**：`tsconfig.json`（及其引用的 `tsconfig.*.json`）

**提取要点**：
- `compilerOptions.strict` → 是否严格模式
- `compilerOptions.target` → 编译目标
- `compilerOptions.paths` → 路径别名（如 `@/*`）
- `compilerOptions.baseUrl` → 基础路径

### 5. Stylelint 配置（如有）

**搜索文件**：`.stylelintrc.*` / `stylelint.config.*`

**提取要点**：
- CSS 命名规范（如 BEM 插件）
- 属性排序规则
- 禁用的 CSS 特性

### 6. EditorConfig（如有）

**搜索文件**：`.editorconfig`

**提取要点**：
- `indent_style` / `indent_size`
- `end_of_line`
- `charset`

## 命名风格推断（代码采样）

当配置文件不足以确定命名规范时，从代码采样推断。

### 采样策略

1. 用 Glob 找 3-5 个**不同类型**的典型文件：
   - 1 个页面组件（`src/pages/` 下）
   - 1 个通用组件（`src/components/` 下）
   - 1 个 Hook 或工具函数（`src/hooks/` 或 `src/utils/` 下）
   - 1 个 API 定义文件（`src/api/` 下）
   - 1 个 Store 文件（`src/store/` 下，如有）

2. 对每个文件，Read 前 50 行，记录：
   - **文件名**本身的命名风格
   - **导出的函数/组件名**的命名风格
   - **局部变量名**的命名风格
   - **常量名**的命名风格（如有 `const XXX_YYY =`）

### 判定规则

| 命名类型 | 检测方法 | 常见风格 |
|---------|---------|---------|
| **文件名** | 直接观察文件名 | `kebab-case` / `PascalCase` / `camelCase` |
| **组件名** | `export default function XXX` 或 `const XXX =` | 几乎全部 `PascalCase` |
| **变量/函数** | 函数体内的 `const xxx =` / `function xxx()` | `camelCase`（最常见）/ `snake_case` |
| **CSS 类名** | JSX 中的 `className` 或模板中的 `class` | `kebab-case` / `camelCase`（CSS Modules）/ Tailwind |
| **常量** | 模块顶部的 `const XXX =` | `UPPER_SNAKE_CASE` / `camelCase` |

### 冲突处理

- 同一类型出现两种以上风格：以**出现频率最高**的为准，备注少数例外
- 配置文件规则与代码实际不一致：以**配置文件**为准（代码是应被修正的）

## Commit 规范推断

### 检测步骤

1. **检查配置**：搜索 `commitlint.config.*` / `.commitlintrc.*` / `package.json` 的 `commitlint` 字段
2. **检查 hooks**：搜索 `.husky/commit-msg` / `.git/hooks/commit-msg`，确认是否有 commit 校验
3. **采样 git log**：`git log --oneline -20`，分析最近 20 条 commit 的格式

### 判定规则

| 特征 | 判定 |
|------|------|
| 有 `@commitlint/config-conventional` + commit 格式为 `type(scope): subject` | Conventional Commits |
| commit 中出现 `JIRA-XXX:` 或 `#123` 前缀 | Issue ID 前缀格式 |
| commit 格式不一致，无 commitlint 配置 | 未检测到统一规范 |

## 输出格式

分析完成后，将结果整理为以下格式（仅供步骤 5/6 消费，不独立输出文档）：

```markdown
### 格式化工具

- 主工具：{ESLint / Prettier / Biome / 未检测到}
- 辅助工具：{Stylelint / EditorConfig / 无}

### 核心格式规则

| 项目 | 规则 | 来源 |
|------|------|------|
| 缩进 | {2 空格 / 4 空格 / Tab} | {配置文件名} |
| 引号 | {单引号 / 双引号} | {配置文件名} |
| 分号 | {使用 / 不使用} | {配置文件名} |
| 最大行宽 | {80 / 100 / 120} | {配置文件名} |
| 尾逗号 | {all / es5 / none} | {配置文件名} |

### 命名规范

| 类型 | 风格 | 示例 | 来源 |
|------|------|------|------|
| 文件名 | {kebab-case} | {user-profile.tsx} | {代码采样} |
| 组件名 | {PascalCase} | {UserProfile} | {代码采样} |
| 变量/函数 | {camelCase} | {getUserInfo} | {代码采样} |
| CSS 类名 | {CSS Modules camelCase} | {styles.userName} | {代码采样} |
| 常量 | {UPPER_SNAKE_CASE} | {MAX_RETRY_COUNT} | {代码采样} |

### Commit 规范

- 格式：{Conventional Commits / 自定义 / 未检测到}
- 校验工具：{commitlint / husky / 无}
- 示例：`{实际 commit 示例}`
```

## 注意事项

- 未检测到某项配置时，写「未检测到」，不要猜测或使用默认值
- 配置冲突时（如 ESLint 和 Prettier 对引号设置不同），以 Prettier 为准（Prettier 覆盖 ESLint 格式规则）
- Biome 项目通常不与 ESLint/Prettier 共存，但需确认
