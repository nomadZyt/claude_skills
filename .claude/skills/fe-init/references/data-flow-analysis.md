# 数据流转分析方法

> 供 fe-init 步骤 4 使用，追踪项目的数据流转链路。
> 来源：project-analyzer 维度4。分析结果不落地为文档，仅用于提取红线规则。

## 核心模型

前端数据流的起点是**路由跳转**，完整链路为：

```
路由层 → API层 → 状态层 → 视图层
```

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   路由层    │ ──► │   API层     │ ──► │   状态层    │ ──► │   视图层    │
│ router/xxx  │     │  api/xxx.js │     │ store/xxx   │     │ pages/xxx   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │
      │ 路由参数          │ HTTP请求          │ state/getters     │ computed/props
      │ query/params      │                   │                   │
```

## 分析步骤

### 1. 找到路由层

搜索路由配置文件：
- `src/router/index.*` — Vue 项目
- `src/routes.*` / `src/App.tsx` — React 项目
- `app/` 目录 — Next.js App Router
- `pages/` 目录 — Next.js Pages Router / Nuxt

记录：
- 所有路由路径和对应组件
- 路由参数定义（动态路由 `:id`）
- 路由守卫/中间件

### 2. 找到 API 层

搜索 API 封装和接口定义：
- `src/api/` / `src/services/` — 接口定义目录
- `src/utils/request.*` / `src/api/http.*` — HTTP 封装文件

记录：
- HTTP 封装方式（axios 实例 / fetch 封装 / umi-request）
- 请求拦截器（Token 注入、签名等）
- 响应拦截器（错误码处理、Token 刷新等）
- 接口定义方式

### 3. 找到状态层

搜索状态管理文件：
- `src/store/` / `src/stores/` — 状态管理目录

记录：
- 使用的状态管理方案
- Store 模块划分方式
- 异步 action 模式

### 4. 找到视图层

记录：
- 组件如何读取状态（useSelector / storeToRefs / useAtom 等）
- 数据请求触发时机（mounted / useEffect / 路由守卫）

## 路由参数传递方式

分析时识别项目使用了哪些传递方式：

| 方式 | 场景 | 特点 |
|------|------|------|
| query 参数 | `/detail?id=123` | URL 可见、刷新保留 |
| params 参数 | `/detail/:id` | URL 路径一部分 |
| state 传递 | `router.push({ state })` | URL 不可见、刷新丢失 |
| Store 预存 | 跳转前存 store | 需处理刷新恢复 |

## 框架语法参考

> 以下为不同框架的标准写法，用于识别项目中使用的具体模式。

### 路由配置与跳转

```javascript
// 路由配置格式
{
  path: '/<资源>/<操作>/:<参数名>',
  component: <组件名>,
  meta: { <元信息> }
}

// 编程式导航
router.push({ path: `/<路径>/${<变量>}`, query: { <参数>: <值> } });
router.push({ name: '<路由名>', params: { <参数> } });
router.replace('/<路径>');

// 声明式导航 - Vue
<router-link :to="{ path: '/<路径>', query: { <参数> } }">...</router-link>

// 声明式导航 - React
<Link to="/<路径>" state={{ <状态> }}>...</Link>
```

### 获取路由参数

```javascript
// Vue 2 Options API
const { <参数名> } = this.$route.params;
const { <参数名> } = this.$route.query;

// Vue 3 Composition API
import { useRoute } from 'vue-router';
const route = useRoute();
const <变量> = route.params.<参数名>;

// React Router v6
import { useParams, useSearchParams, useLocation } from 'react-router-dom';
const { <参数名> } = useParams();
const [searchParams] = useSearchParams();
const location = useLocation();

// Next.js App Router
import { useParams, useSearchParams } from 'next/navigation';

// Next.js Pages Router
import { useRouter } from 'next/router';
const { <参数名> } = router.query;
```

### API 定义

```javascript
// 常见封装方式
export const <方法名> = (<参数>) => http.get(`/api/<路径>/${<参数>}`);
export const <方法名> = (<参数>) => http.post('/api/<路径>', <参数>);
export const <方法名> = (<参数>) => request({ url: '/api/<路径>', method: 'GET', params: <参数> });
```

### 状态管理

```javascript
// Vuex
export default {
  state: { <状态名>: <初始值> },
  mutations: { <MUTATION名>(state, data) { state.<状态名> = data; } },
  actions: { async <action名>({ commit }, <参数>) { ... } }
}

// Pinia
export const use<Store名> = defineStore('<名称>', {
  state: () => ({ <状态名>: <初始值> }),
  actions: { async <方法名>(<参数>) { this.<状态名> = await <API>(<参数>); } }
});

// Redux Toolkit
const <slice名> = createSlice({
  name: '<名称>',
  initialState: { <状态名>: <初始值> },
  reducers: { <reducer名>: (state, action) => { state.<状态名> = action.payload; } }
});

// Zustand
export const use<Store名> = create((set) => ({
  <状态名>: <初始值>,
  <方法名>: async (<参数>) => { set({ <状态名>: await <API>(<参数>) }); }
}));

// MobX
class <Store类名> {
  <状态名> = <初始值>;
  constructor() { makeAutoObservable(this); }
  async <方法名>(<参数>) { this.<状态名> = await <API>(<参数>); }
}

// Jotai
export const <atom名> = atom(<初始值>);
```

### 组件消费状态

```javascript
// Vuex
computed: { ...mapState('<模块名>', ['<状态名>']) }

// Pinia
const { <状态名> } = storeToRefs(use<Store名>());

// Redux
const <变量> = useSelector((state) => state.<模块名>.<状态名>);

// Zustand
const <变量> = use<Store名>((state) => state.<状态名>);

// MobX
const <组件名> = observer(() => { ... });

// Jotai
const [<变量>] = useAtom(<atom名>);
```

## 分析要点

1. **入口分析**：路由如何配置？参数如何传递？
2. **触发时机**：数据请求在哪里触发？(mounted/useEffect/路由守卫/watch)
3. **状态管理**：数据存在哪里？局部 state 还是全局 store？
4. **数据消费**：组件如何读取和展示数据？
5. **刷新恢复**：页面刷新后数据如何恢复？
