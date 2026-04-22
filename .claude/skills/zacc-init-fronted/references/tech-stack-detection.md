# 技术栈识别方法

> 供 zacc-init-fronted 步骤 1 使用，从 package.json 和配置文件识别前端项目技术栈。

## 识别流程

1. 读取 `package.json` 的 `dependencies` 和 `devDependencies`
2. 按下表匹配关键词，记录技术选型和版本号
3. 读取对应配置文件补充信息

## 框架识别

| 依赖关键词 | 技术选型 | 配置文件 |
|-----------|---------|---------|
| `react`, `react-dom` | React | — |
| `next` | Next.js | `next.config.*` |
| `vue` | Vue | — |
| `nuxt` | Nuxt | `nuxt.config.*` |
| `@angular/core` | Angular | `angular.json` |
| `svelte` | Svelte | `svelte.config.*` |
| `solid-js` | Solid | — |

**Vue 版本区分**：
- `vue` 版本 `^2.*` → Vue 2
- `vue` 版本 `^3.*` → Vue 3

**React 框架区分**：
- 有 `next` → Next.js（检查 App Router vs Pages Router：`app/` 目录存在 → App Router）
- 有 `umi` → Umi
- 有 `remix` → Remix
- 都没有 → 纯 React（CRA / Vite React）

## 状态管理识别

| 依赖关键词 | 技术选型 | 适用框架 |
|-----------|---------|---------|
| `vuex` | Vuex | Vue |
| `pinia` | Pinia | Vue 3 |
| `@reduxjs/toolkit`, `redux` | Redux Toolkit | React |
| `mobx`, `mobx-react` | MobX | React |
| `zustand` | Zustand | React |
| `jotai` | Jotai | React |
| `recoil` | Recoil | React |
| `valtio` | Valtio | React |

## 路由识别

| 依赖关键词 | 技术选型 |
|-----------|---------|
| `vue-router` | Vue Router |
| `react-router-dom` | React Router |
| `@tanstack/react-router` | TanStack Router |
| Next.js 内置 | Next.js File Router |
| Nuxt 内置 | Nuxt File Router |

## UI 组件库识别

| 依赖关键词 | 技术选型 | 适用场景 |
|-----------|---------|---------|
| `antd`, `@ant-design/pro-components` | Ant Design | React PC |
| `@arco-design/web-react` | Arco Design | React PC |
| `@mui/material` | MUI (Material UI) | React PC |
| `element-ui` | Element UI | Vue 2 PC |
| `element-plus` | Element Plus | Vue 3 PC |
| `vant` | Vant | Vue 移动端 |
| `@nutui/nutui` | NutUI | Vue 移动端 |
| `antd-mobile` | Ant Design Mobile | React 移动端 |
| `@chakra-ui/react` | Chakra UI | React |
| `@headlessui/react` | Headless UI | React |
| `shadcn` (检查 `components/ui/`) | shadcn/ui | React |

## 构建工具识别

| 依赖关键词 / 配置文件 | 技术选型 |
|---------------------|---------|
| `vite`, `vite.config.*` | Vite |
| `webpack`, `webpack.config.*` | Webpack |
| `@rspack/core`, `rspack.config.*` | Rspack |
| `turbopack` | Turbopack |
| `rollup`, `rollup.config.*` | Rollup |
| `esbuild` | esbuild |
| `parcel` | Parcel |

## CSS 方案识别

| 依赖关键词 / 配置 | 技术选型 |
|------------------|---------|
| `sass`, `node-sass` | Sass/SCSS |
| `less` | Less |
| `stylus` | Stylus |
| `tailwindcss`, `tailwind.config.*` | Tailwind CSS |
| `styled-components` | styled-components |
| `@emotion/react`, `@emotion/styled` | Emotion |
| `.module.css` / `.module.less` 文件 | CSS Modules |
| `postcss`, `postcss.config.*` | PostCSS |

**多方案共存**：项目可能同时使用多种 CSS 方案（如 CSS Modules + Less），全部记录。

## HTTP 客户端识别

| 依赖关键词 | 技术选型 |
|-----------|---------|
| `axios` | Axios |
| `umi-request` | umi-request |
| `@tanstack/react-query` | TanStack Query |
| `swr` | SWR |
| `got` | Got |
| 无以上依赖 | 原生 Fetch |

**封装层识别**：搜索 `src/utils/request.*` 或 `src/api/http.*` 等文件，识别是否有统一封装。

## 测试框架识别

| 依赖关键词 | 技术选型 | 类型 |
|-----------|---------|------|
| `jest` | Jest | 单元测试 |
| `vitest` | Vitest | 单元测试 |
| `@testing-library/react` | React Testing Library | 组件测试 |
| `@testing-library/vue` | Vue Testing Library | 组件测试 |
| `cypress` | Cypress | E2E 测试 |
| `playwright`, `@playwright/test` | Playwright | E2E 测试 |

## 代码规范工具识别

| 依赖关键词 / 配置文件 | 技术选型 |
|---------------------|---------|
| `eslint`, `.eslintrc.*`, `eslint.config.*` | ESLint |
| `prettier`, `.prettierrc.*` | Prettier |
| `stylelint`, `.stylelintrc.*` | Stylelint |
| `husky`, `.husky/` | Husky (Git Hooks) |
| `lint-staged` | lint-staged |
| `commitlint`, `commitlint.config.*` | Commitlint |

## 包管理器判断

| lock 文件 | 包管理器 |
|----------|---------|
| `package-lock.json` | npm |
| `yarn.lock` | yarn |
| `pnpm-lock.yaml` | pnpm |
| `bun.lockb` | bun |

## 输出格式

```markdown
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
```
