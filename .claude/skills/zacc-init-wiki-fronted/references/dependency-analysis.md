# 依赖关系分析

> SOP-1 步骤 3 使用此文档。目标：构建多层次的模块关系图，区分静态 import、路由跳转、动态引用三类边，避免入度指标失真。

## 关系分类（三层边模型）

| 边类型 | 标记 | 说明 | 对入度的影响 |
|--------|------|------|------------|
| `import` | 静态引用 | ES import / CommonJS require | 计入代码耦合入度 |
| `route` | 路由跳转 | router.push / navigate / Link | 计入使用频率入度（独立统计） |
| `dynamic` | 动态加载 | import() 懒加载 / require(var) | 计入弱耦合入度 |

**为什么要分开**：`components/Button` 可能被 50 个页面 import（import 入度高），而 `pages/Checkout` 只被 3 个页面 router.push 跳转（route 入度低但业务重要）。混合计算会掩盖这两种不同维度的"重要性"。

---

## 第一层：静态 Import 扫描

### JavaScript / TypeScript

**Grep 模式**（在模块目录内搜索）：

```
# ES Module import
pattern: "import\s+.*from\s+['\"]"

# CommonJS require
pattern: "require\(['\"]"
```

**内部依赖判定**：
- 路径以 `.` 开头（`./`、`../`）→ 同模块内部，忽略
- 路径以 `@{project}/` 开头 → 内部依赖（Monorepo alias）
- 路径以 `src/` 或配置的 alias 开头 → 内部依赖
- 其余（`lodash`、`react` 等）→ 第三方，忽略

**路径到模块映射**：
- `from '../user-service'` → 解析为 `src/user-service` → 匹配对应节点
- `from '@app/auth'` → 解析 tsconfig paths 后匹配
- 如果 `tsconfig.json` 有 `paths` 配置，先读取路径别名

### Java

**Grep 模式**：

```
pattern: "^import\s+(static\s+)?{project_group_id}"
```

### Go

```
pattern: "\"({module_path}/[^\"]+)\""
```

其中 `{module_path}` 从 `go.mod` 的 `module` 声明获取（如 `github.com/user/project`）。

### Python

```
# from ... import
pattern: "^from\s+(\S+)\s+import"

# import ...
pattern: "^import\s+(\S+)"
```

### Rust

```
# crate 内部引用
pattern: "^use\s+crate::"

# 模块声明
pattern: "^(pub\s+)?mod\s+\w+"
```

---

## 第二层：路由跳转扫描（前端专属）

> 仅对 JavaScript / TypeScript 项目执行。跳转关系体现"页面被使用的频率"，与 import 入度独立计算。

### 跳转模式 Grep

**命令式跳转**：

```
# React Router / Next.js router
pattern: "router\.(push|replace|navigate)\s*\(\s*['\"`]"

# Vue Router
pattern: "\$router\.(push|replace)\s*\(\s*\{?\s*(?:path|name)\s*:"

# Next.js App Router
pattern: "redirect\s*\(\s*['\"`]"

# React Navigation (RN)
pattern: "navigation\.(navigate|push|replace)\s*\(\s*['\"`]"

# Taro 小程序路由跳转
pattern: "Taro\.(navigateTo|redirectTo|switchTab|reLaunch|navigateBack)\s*\("
# Taro 路由参数中的 url 字段
pattern: "url\s*:\s*['\"`]/pages/"

# 原生 window.location — 常见于外链降级、老代码、非 SPA 跳转
pattern: "(?:window\.)?location\.(href|replace|assign)\s*[=(]"

# history API — 手动操控历史栈，绕过框架路由
pattern: "history\.(pushState|replaceState)\s*\("

# window.open — 新窗口跳转（标记为 external，弱关联）
pattern: "window\.open\s*\(\s*['\"`]"
```

**声明式跳转**（JSX/TSX/Vue template）：

```
# React Router Link / NavLink
pattern: "<(?:Link|NavLink)\s[^>]*to\s*=\s*[{'\"`]"

# Vue router-link
pattern: "<router-link\s[^>]*to\s*=\s*[{'\"`]"

# Next.js Link
pattern: "<Link\s[^>]*href\s*=\s*[{'\"`]"

# 原生 <a href> — SPA 中偶尔出现，指向内部路径时记录
pattern: "<a\s[^>]*href\s*=\s*['\"](?!//)(?!http)"
```

### 路由目标解析规则

提取跳转目标后，先分类再匹配节点：

| 跳转写法 | route_type | 解析策略 |
|---------|-----------|---------|
| `router.push('/user/profile')` | `internal` | 取路径字符串，与路由配置表比对 |
| `router.push({ name: 'UserProfile' })` | `internal` | 取 `name` 值，路由配置中查找组件 |
| `navigate('/checkout')` | `internal` | 直接取路径字符串 |
| `<Link to="/cart">` | `internal` | 取 `to` 属性值 |
| `location.href = '/login'` | `internal` | 取赋值右侧路径字符串 |
| `location.replace('/404')` | `internal` | 取参数路径字符串 |
| `history.pushState(null, '', '/step2')` | `internal` | 取第三个参数路径字符串 |
| `window.open('/report')` | `external` | 记录为弱关联，不计入 route_in |
| `<a href="/about">` | `internal` | 取 `href` 值（已过滤 `//` 和 `http` 开头） |
| 动态路径 `push('/user/' + id)` | `internal-dynamic` | 记录为 `/user/*`（模糊匹配，不计入 route_in） |
| `location.href = 'https://...'` | `external` | 外部链接，忽略 |
| `Taro.navigateTo({ url: '/pages/detail/index' })` | `internal` | 取 `url` 值，去掉前导 `/`，与 `app.config.ts` 的 `pages[]` 比对 |
| `Taro.redirectTo({ url: '/pages/login/index' })` | `internal` | 同 navigateTo，但标记为 redirect（替换当前页） |
| `Taro.switchTab({ url: '/pages/home/index' })` | `internal` | Tab 切换，目标页为 tabBar 页面 |
| `Taro.reLaunch({ url: '/pages/index/index' })` | `internal` | 重启到目标页，关闭所有页面 |
| `Taro.navigateBack()` | `internal-dynamic` | 返回上一页，目标不确定，记录但不计入 route_in |

**route_type 说明**：
- `internal` — 计入 `route_in`，参与热力矩阵统计
- `internal-dynamic` — 路径含变量，无法精确解析，记录到节点备注但不计入 `route_in`
- `external` — 外部跳转，不建立节点关系

**路由配置读取**：
1. Glob 查找 `src/router/index.{ts,js}` 或 `src/routes.{ts,js}` 或 `app/router.ts`
2. 读取路由配置，建立 `path → component` 映射表
3. `internal` 类型的目标 path 通过映射表解析为节点 ID

**Taro 小程序路由配置读取**：
1. 读取 `src/app.config.ts`（或 `src/app.config.js`）
2. 提取 `pages[]` → 主包路由映射（`pages/index/index` → `src/pages/index/`）
3. 提取 `subPackages[].root` + `subPackages[].pages[]` → 分包路由映射
4. 提取 `tabBar.list[].pagePath` → Tab 页面标记
5. Taro 路由目标解析：`/pages/detail/index?id=123` → 取 `/pages/detail/index` 部分（去掉查询参数），与 `pages[]` 比对

### 写入节点

路由跳转关系用 `route_to` / `route_from` 字段记录，与 `dependencies` / `dependents` 分开。注释中附跳转类型：

```yaml
dependencies:
  - "[[20260413-143053]]"    # import: auth-module
route_to:
  - "[[20260413-140007]]"    # route: pages/checkout (router.push, internal)
  - "[[20260413-140008]]"    # route: pages/orderResult (Link, internal)
  # window.open 的 external 跳转不建立节点关系，仅在 ## 设计决策 中备注
route_from:
  - "[[20260413-140005]]"    # route: pages/cart → 跳转到本页 (location.href, internal)
```

---

## 第三层：动态加载扫描

```
# Dynamic import (懒加载)
pattern: "import\s*\(\s*['\"]"
```

仅扫描字符串路径的动态 import（变量路径无法静态分析，跳过）。

动态加载关系用 `lazy_deps` 字段记录：

```yaml
lazy_deps:
  - "[[20260413-143060]]"    # dynamic: heavy-chart-module
```

---

## 入度指标计算（修正版）

节点的入度分两个维度独立统计，**不合并**：

| 指标 | 计算方式 | 含义 |
|------|---------|------|
| `import_in` | 有多少节点的 `dependencies` 包含本节点 | 代码耦合程度（被多少模块引用） |
| `route_in` | 有多少节点的 `route_to` 包含本节点 | 业务使用频率（被多少页面跳转到） |

**热力矩阵中的展示**：

```
| 模块 | import入度 | route入度 | 总出度 |
|------|:---------:|:--------:|:-----:|
| pages/Checkout | 0 | 8 | 3 |  ← import入度0但route入度8，是高频页面
| components/Button | 42 | — | 2 |  ← 高复用基础组件
| utils/request | 31 | — | 0 |  ← 核心基础模块
```

**页面类模块（`type: page`）**：通常 import 入度接近 0（路由懒加载），主要看 route 入度。
**组件/工具类模块**：主要看 import 入度。

---

## 依赖图构建（完整步骤）

### 数据结构

```
graph = {
  "module_a": {
    "import_deps": ["module_b"],      // A 静态 import B
    "import_by": ["module_d"],        // D 静态 import A
    "route_to": ["module_c"],         // A 路由跳转到 C
    "route_from": ["module_e"],       // E 路由跳转到 A
    "lazy_deps": ["module_f"]         // A 动态加载 F
  }
}
```

### 构建步骤

1. 对每个模块扫描静态 import → 填充 `import_deps` / `import_by`
2. 读取路由配置文件建立 path→node 映射表
3. 扫描所有模块的路由跳转语句 → 填充 `route_to` / `route_from`
4. 扫描动态 import → 填充 `lazy_deps`
5. 计算每个节点的 `import_in`（import 入度）和 `route_in`（route 入度）

### 写入节点 frontmatter

```yaml
dependencies:
  - "[[20260413-143053]]"    # import: auth-module
dependents:
  - "[[20260413-143058]]"    # import: api-controller
route_to:
  - "[[20260413-140007]]"    # route → pages/checkout
route_from:
  - "[[20260413-140005]]"    # route ← pages/cart
lazy_deps:
  - "[[20260413-143060]]"    # dynamic: heavy-chart
import_in: 0
route_in: 8
```

---

## 循环依赖检测

仅对 `import_deps` 关系执行 DFS 检测环（路由跳转产生环是正常的，不标注）。

如果 A → B → C → A 形成 import 环，在所有环内节点的 `## 设计决策` 章节标注：

```markdown
> ⚠️ 循环依赖：{module_a} ↔ {module_b} ↔ {module_c}
> 建议在未来重构时打破此环。
```

---

## 跨 Monorepo 子包依赖

对于 Monorepo 项目：
- 子包之间的依赖通过 `package.json` 的 `dependencies` / `peerDependencies` 中引用 workspace 包识别
- 跨包依赖记录为 `type: "cross-package"` 级别的依赖
- 在 index.md 中单独列出跨包依赖关系

---

## 前端项目特殊处理

### 路径别名解析

前端项目广泛使用路径别名（如 `@/components/Button`），需在依赖分析前建立别名映射：

1. 读取 `tsconfig.json` 的 `compilerOptions.paths` 配置
2. 读取 `vite.config.ts` / `webpack.config.js` / `umi.config.ts` 的 `resolve.alias` 配置
3. 将别名路径转换为实际路径后匹配节点

**常见别名映射示例：**
```
@/components/Button  →  src/components/Button/index.tsx
@/utils/request      →  src/utils/request.ts
@/store/useStore     →  src/store/useStore.ts
```

**Grep 补充模式（匹配别名引用）：**
```
pattern: "from\s+['\"]@/"
pattern: "import\s+.*from\s+['\"]@/"
```

### Store 隐式依赖

全局 store 可能被间接引用（通过 hook 而非直接 import store 文件）：
```typescript
const store = useStore();  // 不直接 import store 文件
```

对 `src/store/` 下的模块，额外扫描以下调用点建立隐式依赖关系：
```
pattern: "useStore\s*\(\s*\)"
pattern: "useSelector\s*\("
pattern: "use\w+Store\s*\(\s*\)"  # 如 useUserStore, useCartStore
```

### Context 隐式依赖

React Context 通过 Provider/Consumer 模式使用，Grep 模式补充：
```
pattern: "useContext\s*\(\s*\w+Context\s*\)"
pattern: "<\w+Context\.Provider"
pattern: "<\w+Context\.Consumer"
```

### Empty/Minimal 模块处理

对 `src/pages/notification/` 这类空目录或仅含 1 个文件的模块：
- 创建轻量节点，标记 `confidence: low`
- 在 `## 设计决策` 中备注："目录结构存在但内容为空，可能为占位或已废弃"
- 不纳入依赖图，但保留在索引中

---

## 性能优化

- 静态 import：每个模块只 Grep 入口文件 + 直接子文件（深度 1）
- 路由跳转：集中扫描页面目录（`pages/`、`views/`、`screens/`），不扫描 components；Taro 项目额外扫描 `subpackages/` 目录
- 路由配置：只读一次，建立映射表复用；Taro 项目从 `app.config.ts` 读取
- 如模块文件 > 50 个，只 Grep 入口文件 + 按文件名排序前 10 个

