# AI 红线规则

> 本文件由 `/fe-init` 自动生成，记录 AI 修改/添加代码时必须遵守的规则。
> 生成时间：{date}
> 最后更新：{date}

---

## 1. 技术栈红线

### 允许使用的依赖

> 以下依赖已在 package.json 中声明，可直接使用。

**dependencies**:
{dependenciesList}

**devDependencies**:
{devDependenciesList}

### 禁止操作

- 不得引入 dependencies/devDependencies 中不存在的新框架或库（如需引入必须先征得用户同意）
- 不得修改构建配置文件（{buildConfigPath}）
- 不得更换包管理器（当前使用：{packageManager}）
- 不得修改 TypeScript 配置的核心设置（strict / target / module / paths）

---

## 2. 架构模式红线

### 目录规范

新建文件必须放在对应目录：

| 文件类型 | 目标目录 |
|---------|---------|
| 页面文件 | `{pagesDir}` |
| 组件文件 | `{componentsDir}` |
| API 定义 | `{apiDir}` |
| 状态管理 | `{storeDir}` |
| 工具函数 | `{utilsDir}` |
| 自定义 Hooks | `{hooksDir}` |
| 类型定义 | `{typesDir}` |
| 样式文件 | `{stylesDir}` |

### 分层规范

- API 调用必须通过 `{requestFilePath}` 统一封装，不得直接使用 axios/fetch
- 状态管理必须使用 {stateManagementScheme}，不得引入其他状态管理方案
- 组件必须遵循 {componentOrganization} 的组织方式

### 数据流转

必须遵循项目已有的数据流转链路：

```
{dataFlowPattern}
```

<!-- 示例：路由参数 → 页面组件 useEffect → API 方法 → Store action → 组件 useSelector -->

---

## 3. 代码风格红线

### 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 文件命名 | {fileNamingRule} | {fileNamingExample} |
| 组件命名 | {componentNamingRule} | {componentNamingExample} |
| 变量/函数 | {variableNamingRule} | {variableNamingExample} |
| CSS 类名 | {cssNamingRule} | {cssNamingExample} |
| 常量 | {constantNamingRule} | {constantNamingExample} |

### 格式规范

| 项目 | 规则 |
|------|------|
| 缩进 | {indent} |
| 引号 | {quote} |
| 分号 | {semicolon} |
| 最大行宽 | {printWidth} |
| 尾逗号 | {trailingComma} |

### 样式规范

- 样式方案：{cssScheme}
- 新样式必须使用 {cssScheme}，与现有代码保持一致
{additionalCssRules}

---

## 4. 业务逻辑红线

### 页面流转

- 页面跳转必须使用 {routerScheme} 的标准方式（{routerMethod}）
- 路由参数传递必须与现有模式一致（主要使用：{paramPassingMode}）
- 不得修改已有页面的路由路径
- 新页面必须注册到路由配置中

### 请求/拦截器

- 不得绕过已有的请求拦截器（{requestInterceptorPath}）
- 不得绕过已有的响应拦截器（{responseInterceptorPath}）
- 不得绕过路由守卫（{routeGuardPath}）

### 模块边界

{moduleBoundaryRules}

<!-- 示例：
- 模块间通信必须通过 Store，不得直接 import 其他模块的内部文件
- 公共组件放在 src/components/common/，业务组件放在对应模块内
-->

---

## 5. 功能修改确认规则

以下操作在执行前**必须使用 AskUserQuestion 弹窗确认**：

| 操作 | 影响范围 |
|------|---------|
| 修改现有组件的 props / 接口定义 | 所有调用方 |
| 修改路由配置或页面跳转逻辑 | 页面导航 |
| 修改状态管理 Store 的结构（增删字段、修改 action） | 所有消费者 |
| 修改 API 请求/响应处理逻辑 | 数据获取 |
| 删除或重命名现有文件、函数、组件 | 所有引用方 |
| 修改公共工具函数的签名或行为 | 所有调用方 |

---

## 附录：项目特有规则

{projectSpecificRules}

<!-- 用户纠错后可能追加的规则会自动写入此处 -->
