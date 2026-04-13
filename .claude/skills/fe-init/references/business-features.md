# 业务特性识别

> 供 fe-init 步骤 4 使用，识别项目的业务特性和特殊逻辑。
> 来源：project-analyzer 维度6。

## 识别要点

### 1. 配置化能力

**搜索关键词**：`config`, `setting`, `feature-flag`, `toggle`, `switch`

**常见文件**：
- `src/config/` — 全局配置
- `src/constants/` — 常量定义
- `src/features/` — Feature flag 定义

**关注点**：
- 哪些功能通过配置控制开关
- 是否有 Feature Flag 系统（如 LaunchDarkly、自研）
- 环境相关的配置切换

### 2. 多环境支持

**搜索关键词**：`env`, `NODE_ENV`, `VITE_`, `NEXT_PUBLIC_`, `VUE_APP_`

**常见文件**：
- `.env` / `.env.development` / `.env.production` / `.env.test`
- `src/config/env.*`

**关注点**：
- 支持几套环境（dev/test/staging/production）
- 环境变量前缀（VITE_ / NEXT_PUBLIC_ / VUE_APP_）
- 接口地址如何按环境切换

### 3. 埋点上报

**搜索关键词**：`track`, `report`, `analytics`, `beacon`, `log`, `monitor`

**常见文件**：
- `src/utils/tracker.*` / `src/utils/analytics.*`
- `src/utils/monitor.*`

**关注点**：
- 页面浏览（PV）上报
- 按钮/事件点击上报
- 性能监控（Web Vitals）
- 错误上报

### 4. 错误处理

**搜索关键词**：`ErrorBoundary`, `error`, `catch`, `sentry`, `bugsnag`

**常见文件**：
- `src/components/ErrorBoundary.*`
- `src/utils/error.*`

**关注点**：
- 全局错误边界
- 请求错误统一处理（拦截器中）
- 错误上报服务（Sentry、自研）
- 用户友好的错误提示方式

### 5. 性能优化

**搜索关键词**：`lazy`, `Suspense`, `dynamic`, `loadable`, `prefetch`, `preload`

**关注点**：
- 路由懒加载
- 组件懒加载
- 图片懒加载
- 数据缓存策略
- 虚拟滚动
- 代码分割策略

### 6. 国际化

**搜索关键词**：`i18n`, `intl`, `locale`, `t(`, `$t(`

**常见依赖**：`i18next`, `react-intl`, `vue-i18n`

**关注点**：
- 支持的语言列表
- 翻译文件组织方式
- 语言切换机制

### 7. 主题/样式定制

**搜索关键词**：`theme`, `dark`, `light`, `css-var`, `custom-properties`

**关注点**：
- 是否支持暗黑模式
- 主题切换机制
- CSS 变量使用方式
- UI 库主题定制

## 输出格式

```markdown
| 特性 | 说明 | 相关代码 |
|------|------|---------|
| {特性名称} | {实现方式说明} | `{相关文件路径}` |
```

## 关键文件速查

| 功能 | 常见路径 |
|------|---------|
| 全局配置 | `src/config/`, `src/constants/` |
| 环境变量 | `.env*`, `src/config/env.*` |
| 埋点上报 | `src/utils/tracker.*`, `src/utils/analytics.*` |
| 错误处理 | `src/components/ErrorBoundary.*`, `src/utils/error.*` |
| 国际化 | `src/locales/`, `src/i18n/` |
| 主题 | `src/styles/theme.*`, `src/theme/` |
