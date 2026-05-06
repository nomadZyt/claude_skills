# 项目结构分析方法

> 供 zacc-init-fronted 步骤 2 使用，系统性扫描并归纳项目的目录组织模式。
> 分析结果用于步骤 5 提取架构模式红线和步骤 6 填充 CLAUDE.md 项目结构章节。

## 扫描策略

### 1. 确定源码根目录

按优先级检测：

| 检测条件 | 源码根 |
|---------|--------|
| 存在 `src/` 目录 | `src/` |
| Next.js App Router（存在 `app/` 且无 `src/`） | `app/` |
| Nuxt（存在 `pages/` + `nuxt.config.*`） | 项目根 |
| Monorepo（存在 `packages/`） | 各子包的 `src/` |
| 以上均不匹配 | 项目根 |

### 2. 扫描深度控制

- **一级目录**：全部列出（`Glob("src/*/")`）
- **二级目录**：仅对重要一级目录展开（pages / features / modules / components）
- **三级目录**：仅在二级目录数量 > 10 时按模式采样（如 `pages/xxx/components/`）
- **终止条件**：单次 Glob 结果超过 50 项时停止深入，改为统计总数

### 3. 忽略目录

扫描时跳过以下目录：

```
node_modules/ dist/ build/ .next/ .nuxt/ .output/
coverage/ __tests__/ __mocks__/ .cache/ .turbo/
```

## 组织模式识别

### 特征匹配表

| 模式 | 特征信号 | 典型目录结构 |
|------|---------|-------------|
| **按功能（feature-based）** | `src/features/xxx/` 或 `src/modules/xxx/` 下同时含 components + api + store | `src/features/order/{components,api,store,types}` |
| **按类型（type-based）** | `src/` 下直接分 components / pages / api / store / utils 等 | `src/{components,pages,api,store,utils,hooks}` |
| **按模块（module-based）** | 类似 feature 但粒度更大，一个模块对应一个业务域 | `src/modules/{user,product,order}` |
| **按路由（route-based）** | 目录结构与 URL 路径一一对应（Next.js / Nuxt 约定式路由） | `app/dashboard/settings/page.tsx` |
| **混合模式** | 顶层按类型，pages/ 内部按功能 | `src/{components,pages/{order/{components,hooks}},api}` |

### 判定规则

1. 用 Glob 扫描 `src/*/` 一级目录名
2. 若出现 `features/` 或 `modules/`（含子目录带 components/api/store）→ **按功能**
3. 若一级目录全是类型名（components / pages / api / store / hooks / utils / styles / assets）→ **按类型**
4. 若目录结构与路由路径对应（如 `app/xxx/page.tsx`）→ **按路由**
5. 若以上均不满足或存在混合特征 → **混合模式**，描述清楚混合方式

## 关键目录标注

对每个一级目录，标注其职责分类：

| 分类 | 常见目录名 | 职责 |
|------|-----------|------|
| 页面 | `pages/` `views/` `screens/` `app/` | 路由对应的页面组件 |
| 组件 | `components/` `ui/` | 可复用的 UI 组件 |
| API | `api/` `services/` `requests/` | 接口定义与请求封装 |
| 状态 | `store/` `stores/` `state/` `models/` | 全局状态管理 |
| 工具 | `utils/` `helpers/` `lib/` `tools/` | 通用工具函数 |
| Hooks | `hooks/` `composables/` | 自定义 hooks / composables |
| 样式 | `styles/` `css/` `themes/` | 全局样式和主题 |
| 资源 | `assets/` `images/` `icons/` `fonts/` | 静态资源 |
| 类型 | `types/` `typings/` `interfaces/` | TypeScript 类型定义 |
| 路由 | `router/` `routes/` | 路由配置 |
| 配置 | `config/` `constants/` `settings/` | 应用配置和常量 |
| 布局 | `layouts/` | 页面布局组件 |
| 中间件 | `middleware/` `interceptors/` | 路由中间件 / 请求拦截 |

## 输出格式

```markdown
### 组织模式

{按功能 / 按类型 / 按路由 / 混合}

### 目录结构

src/
├── {dir1}/          # {分类}：{职责说明}
│   ├── {subdir1}/   # {说明}
│   └── {subdir2}/   # {说明}
├── {dir2}/          # {分类}：{职责说明}
└── ...

### 关键发现

- {发现1：如「pages/ 内部按业务域再分子目录，每个子目录含独立 hooks/」}
- {发现2：如「api/ 按业务域拆分为独立文件，每个文件导出该域的全部接口」}
```

## 注意事项

- 扫描结果仅用于分析，不输出为独立文档
- 对大型项目（一级目录 > 15 个），仅展开最重要的 5 个目录
- Monorepo 需注明是哪个子包的结构
