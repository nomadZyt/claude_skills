---
name: 项目梳理分析器
description: 用于系统性分析项目结构、技术栈、数据流转、核心功能和业务特性的技能。支持全量分析和模块分析两种模式，适用于技术交接、代码审查、项目复盘等场景。
---

# 项目梳理分析器

## 使用场景

当用户需要以下操作时，使用此技能：
- 梳理整个项目结构
- 分析某个功能模块
- 了解项目技术栈
- 追踪数据流转链路
- 理解业务逻辑实现
- 生成项目分析文档

## 分析模式

### 模式1：全量分析
用户说类似以下的话时触发：
- "帮我梳理一下这个项目"
- "分析整个项目结构"
- "生成项目分析文档"
- "项目全量梳理"

### 模式2：模块分析
用户说类似以下的话时触发：
- "分析一下 xxx 功能"
- "梳理 xxx 模块"
- "xxx 是怎么实现的"
- "xxx 的数据流转是什么样的"

---

## 分析工作流程

### 第一步：信息收集

#### 1.1 识别项目类型
读取以下文件判断项目类型：
- `package.json` - Node.js/前端项目
- `requirements.txt` / `pyproject.toml` / `setup.py` - Python项目
- `pom.xml` / `build.gradle` - Java项目
- `go.mod` - Go项目
- `Cargo.toml` - Rust项目

#### 1.2 收集项目元信息
```
必读文件：
- package.json / 依赖管理文件 → 依赖版本、脚本命令
- README.md → 项目说明
- 配置文件（webpack.config.js, vite.config.js, tsconfig.json 等）→ 构建配置
- 前端项目的路由文件
```

#### 1.3 扫描目录结构
```
使用 LS 工具扫描根目录，识别：
- src/ → 源代码目录
- test/ → 测试目录
- config/ → 配置目录
- docs/ → 文档目录
- scripts/ → 脚本目录
```

### 第二步：七维度分析

#### 维度1：项目概览
**分析目标**：一句话说清楚项目是什么

**分析要点**：
- 项目名称和定位
- 核心业务场景
- 目标用户群体（B端/C端/内部系统）
- 项目价值和作用

**信息来源**：
- README.md
- package.json 的 description 字段
- 入口文件注释
- 路由配置（判断功能范围）

#### 维度2：技术栈识别
**分析目标**：列出项目使用的所有技术及版本

**分析要点**：
| 类别 | 识别方法 |
|------|---------|
| 框架 | package.json dependencies（Vue/React/Angular等）|
| 状态管理 | Vuex/Redux/Pinia/MobX/Zustand 等 |
| 路由 | vue-router/react-router 等 |
| UI组件库 | Element/Ant Design/Vant 等 |
| 构建工具 | Webpack/Vite/Rollup/umi 配置文件 |
| HTTP客户端 | Axios/Fetch 封装 |
| CSS预处理 | Sass/Less/Stylus |
| 代码规范 | ESLint/Prettier/Stylelint 配置 |

**输出格式**：
```markdown
| 类别 | 技术选型 | 版本 |
|------|---------|------|
| 框架 | Vue | 2.7.16 |
| ... | ... | ... |
```

#### 维度3：项目结构分析
**分析目标**：理清代码组织方式和模块职责

**分析要点**：
- 目录分层（router/pages/components/store/api/utils）
- 模块划分方式（按功能/按业务/按技术层）
- 关键文件职责
- 配置文件说明

**输出格式**：
```
src/
├── api/                  # API接口层
│   ├── http.js           # HTTP请求封装
│   └── xxx.js            # 具体业务API
├── components/           # 组件层
│   ├── common/           # 通用组件
│   └── business/         # 业务组件
├── pages/                # 页面层
├── router/               # 路由层
├── store/                # 状态管理层
├── utils/                # 工具函数层
└── main.js               # 入口文件
```

#### 维度4：数据流转分析
**分析目标**：追踪数据从路由进入到UI渲染的完整链路

**核心认知**：前端数据流的起点是**路由跳转**，完整链路为：
```
路由层 → API层 → 状态层 → 视图层
```

**分析步骤**：
1. **找到路由层**：搜索路由配置，分析页面入口和参数传递方式
2. **找到API层**：搜索 HTTP 请求封装和接口定义
3. **找到状态层**：搜索 Store/State 定义和 mutations/actions
4. **找到视图层**：搜索页面组件如何读取状态和渲染数据
5. **画出流转图**：Router → API → Store → Component → Template

**输出格式**：
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   路由层    │ ──► │   API层     │ ──► │   状态层    │ ──► │   视图层    │
│ router/xxx  │     │  api/xxx.js │     │ store/xxx.js│     │ pages/xxx   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │
      │ 路由参数          │ HTTP请求          │ state/getters     │ computed/methods
      │ query/params      │                   │                   │
      ▼                   ▼                   ▼                   ▼
  页面跳转入口        后端接口           Vuex/Pinia Store     Vue/React组件
```

**路由参数传递方式**：
| 方式 | 场景 | 示例 | 特点 |
|------|------|------|------|
| query参数 | 非敏感数据、可分享URL | `/detail?id=123` | URL可见、刷新保留 |
| params参数 | 动态路由 | `/detail/:id` | URL路径一部分 |
| state传递 | 敏感数据、复杂对象 | `router.push({ state: {...} })` | URL不可见、刷新丢失 |
| Store预存 | 跨页面共享状态 | 跳转前存store，跳转后读取 | 需处理刷新恢复 |

**关键代码追踪**：

> 以下为**语法参考手册**，展示不同框架的标准写法，用于识别项目中使用的模式。
> 分析项目时，根据识别到的框架类型，参考对应的语法去搜索和定位代码。

```javascript
// ==================== 语法参考：路由配置与跳转 ====================

// 路由配置格式
{
  path: '/<资源>/<操作>/:<参数名>',    // 例：'/user/detail/:userId'、'/order/list'
  component: <组件名>,                 // 例：UserDetail、OrderList
  meta: { <元信息> }                   // 例：{ requiresAuth: true, title: '详情页' }
}

// ==================== 语法参考：跳转触发方式 ====================
// 分析时搜索项目中使用了哪些跳转方式

// ① 编程式导航 - push（添加历史记录）
router.push({ path: `/<路径>/${<变量>}`, query: { <参数>: <值> } });
// 例：router.push({ path: `/user/detail/${userId}`, query: { tab: 'profile' } });
router.push({ name: '<路由名>', params: { <参数> } });
// 例：router.push({ name: 'UserDetail', params: { userId: '123' } });

// ② 编程式导航 - replace（替换当前记录，无法后退）
router.replace('/<路径>');
// 例：router.replace('/login');

// ③ 历史记录导航
router.go(-1);   // 后退一步
router.back();   // 后退
router.forward(); // 前进

// ④ 声明式导航 - Vue
<router-link :to="{ path: '/<路径>', query: { <参数> } }">...</router-link>
// 例：<router-link :to="{ path: '/order/detail', query: { id: orderId } }">查看详情</router-link>

// ⑤ 声明式导航 - React
<Link to="/<路径>" state={{ <状态> }}>...</Link>
// 例：<Link to="/order/detail/123" state={{ from: 'list' }}>查看详情</Link>
<NavLink to="/<路径>" end>...</NavLink>

// ⑥ 路由重定向（路由配置中）
{ path: '/<旧路径>', redirect: '/<新路径>' }
// 例：{ path: '/home', redirect: '/dashboard' }
{ path: '/<旧路径>', redirect: to => ({ path: '/<新路径>', query: to.params }) }

// ⑦ 路由守卫中跳转
router.beforeEach((to, from, next) => {
  if (<条件判断>) next('/<重定向路径>');
  else next();
});
// 例：if (!isAuthenticated) next('/login');

// ⑧ 原生方式（会导致页面刷新，慎用）
window.location.href = '/<路径>';
// 例：window.location.href = '/external-page';

// ==================== 语法参考：获取路由参数 ====================
// 根据项目使用的框架，搜索对应的参数获取方式

// ===== Vue 2 Options API =====
mounted() {
  const { <参数名> } = this.$route.params;  // 动态路由参数，例：const { userId } = this.$route.params;
  const { <参数名> } = this.$route.query;   // URL查询参数，例：const { tab } = this.$route.query;
  this.<方法名>(<参数>);                     // 触发数据请求，例：this.fetchUserDetail(userId);
}

// ===== Vue 3 Composition API =====
import { useRoute } from 'vue-router';
const route = useRoute();
const <变量> = route.params.<参数名>;        // 例：const userId = route.params.userId;
const <变量> = route.query.<参数名>;         // 例：const tab = route.query.tab;

// ===== React Router v6 =====
import { useParams, useSearchParams, useLocation } from 'react-router-dom';
const { <参数名> } = useParams();            // 例：const { userId } = useParams();
const [searchParams] = useSearchParams();
const <变量> = searchParams.get('<参数名>'); // 例：const tab = searchParams.get('tab');
const location = useLocation();
const state = location.state;                // 例：const { from, formData } = location.state || {};

// ===== React Router v5 =====
import { useParams, useLocation } from 'react-router-dom';
const { <参数名> } = useParams();            // 例：const { orderId } = useParams();
const query = new URLSearchParams(useLocation().search);
const <变量> = query.get('<参数名>');        // 例：const status = query.get('status');
// 或通过 props（Class组件）
const { <参数名> } = this.props.match.params;

// ===== Next.js App Router =====
import { useParams, useSearchParams } from 'next/navigation';
const params = useParams();                  // 例：const { slug } = params;
const searchParams = useSearchParams();      // 例：const page = searchParams.get('page');

// ===== Next.js Pages Router =====
import { useRouter } from 'next/router';
const router = useRouter();
const { <参数名> } = router.query;           // 例：const { id, tab } = router.query;

// ==================== 语法参考：API定义 ====================
// 搜索项目中的 API 封装文件，识别接口定义方式

// 常见写法格式 → 示例
export const <方法名> = (<参数>) => http.get(`/api/<路径>/${<参数>}`);
// 例：export const getUserDetail = (userId) => http.get(`/api/user/${userId}`);

export const <方法名> = (<参数>) => http.post('/api/<路径>', <参数>);
// 例：export const createOrder = (orderData) => http.post('/api/order/create', orderData);

export const <方法名> = (<参数>) => request({ url: '/api/<路径>', method: 'GET', params: <参数> });
// 例：export const getOrderList = (params) => request({ url: '/api/order/list', method: 'GET', params });

// ==================== 语法参考：Store状态管理 ====================
// 根据项目使用的状态管理库，搜索对应的状态定义和更新方式

// ===== Vuex (Vue 2/3) =====
// 搜索关键词：createStore, mutations, actions, commit
export default {
  state: { <状态名>: <初始值> },              // 例：state: { userInfo: null, orderList: [] }
  mutations: {
    <MUTATION名>(state, data) { state.<状态名> = data; }
    // 例：SET_USER_INFO(state, data) { state.userInfo = data; }
  },
  actions: {
    async <action名>({ commit }, <参数>) {
      const data = await <API方法>(<参数>);
      commit('<MUTATION名>', data);
    }
    // 例：async fetchUserInfo({ commit }, userId) {
    //       const data = await getUserDetail(userId);
    //       commit('SET_USER_INFO', data);
    //     }
  }
}

// ===== Pinia (Vue 3) =====
// 搜索关键词：defineStore, storeToRefs
export const use<Store名> = defineStore('<store名>', {
  // 例：export const useUserStore = defineStore('user', {
  state: () => ({ <状态名>: <初始值> }),      // 例：state: () => ({ userInfo: null })
  actions: {
    async <方法名>(<参数>) {
      this.<状态名> = await <API方法>(<参数>);
    }
    // 例：async fetchUserInfo(userId) { this.userInfo = await getUserDetail(userId); }
  }
});

// ===== Redux Toolkit (React) =====
// 搜索关键词：createSlice, createAsyncThunk, useSelector, useDispatch
const <slice名> = createSlice({
  // 例：const userSlice = createSlice({
  name: '<名称>',                             // 例：name: 'user'
  initialState: { <状态名>: <初始值> },       // 例：initialState: { userInfo: null }
  reducers: {
    <reducer名>: (state, action) => { state.<状态名> = action.payload; }
    // 例：setUserInfo: (state, action) => { state.userInfo = action.payload; }
  }
});
// 异步 thunk 例：
// export const fetchUserInfo = createAsyncThunk('user/fetchInfo', async (userId) => {
//   return await getUserDetail(userId);
// });

// ===== MobX (React) =====
// 搜索关键词：makeAutoObservable, observer, makeObservable
class <Store类名> {
  // 例：class UserStore {
  <状态名> = <初始值>;                        // 例：userInfo = null;
  constructor() { makeAutoObservable(this); }
  
  async <方法名>(<参数>) {
    this.<状态名> = await <API方法>(<参数>);
  }
  // 例：async fetchUserInfo(userId) { this.userInfo = await getUserDetail(userId); }
}
export const <store实例> = new <Store类名>(); // 例：export const userStore = new UserStore();

// ===== Zustand (React) =====
// 搜索关键词：create, set, get
export const use<Store名> = create((set, get) => ({
  // 例：export const useUserStore = create((set, get) => ({
  <状态名>: <初始值>,                         // 例：userInfo: null,
  <方法名>: async (<参数>) => {
    const data = await <API方法>(<参数>);
    set({ <状态名>: data });
  }
  // 例：fetchUserInfo: async (userId) => {
  //       const data = await getUserDetail(userId);
  //       set({ userInfo: data });
  //     }
}));

// ===== Jotai (React) =====
// 搜索关键词：atom, useAtom
export const <atom名> = atom(<初始值>);       // 例：export const userInfoAtom = atom(null);
// 派生 atom 例：
// export const fetchUserInfoAtom = atom(null, async (get, set, userId) => {
//   const data = await getUserDetail(userId);
//   set(userInfoAtom, data);
// });

// ==================== 语法参考：组件消费状态 ====================
// 根据项目使用的状态管理库，搜索对应的状态读取方式

// ===== Vuex =====
computed: { ...mapState('<模块名>', ['<状态名>']) }
// 例：computed: { ...mapState('user', ['userInfo', 'orderList']) }
const <变量> = computed(() => store.state.<模块名>.<状态名>);
// 例：const userInfo = computed(() => store.state.user.userInfo);

// ===== Pinia =====
const <store变量> = use<Store名>();
// 例：const userStore = useUserStore();
const { <状态名> } = storeToRefs(<store变量>);
// 例：const { userInfo, orderList } = storeToRefs(userStore);

// ===== Redux =====
const <变量> = useSelector((state) => state.<模块名>.<状态名>);
// 例：const userInfo = useSelector((state) => state.user.userInfo);
const dispatch = useDispatch();
dispatch(<action名>(<参数>));
// 例：dispatch(fetchUserInfo(userId));

// ===== MobX =====
const <组件名> = observer(() => {
  return <div>{<store实例>.<状态名>}</div>;
});
// 例：const UserProfile = observer(() => {
//       return <div>{userStore.userInfo?.name}</div>;
//     });

// ===== Zustand =====
const <变量> = use<Store名>((state) => state.<状态名>);
// 例：const userInfo = useUserStore((state) => state.userInfo);
const <方法> = use<Store名>((state) => state.<方法名>);
// 例：const fetchUserInfo = useUserStore((state) => state.fetchUserInfo);

// ===== Jotai =====
const [<变量>, <setter>] = useAtom(<atom名>);
// 例：const [userInfo, setUserInfo] = useAtom(userInfoAtom);
```

**路由守卫中的数据预加载**：
```javascript
// 语法参考：在路由守卫中预加载数据
router.beforeEach(async (to, from, next) => {
  if (to.meta.<预加载标记>) {
    await store.dispatch('<预加载action>', to.params);
  }
  next();
});
// 分析时搜索项目中的 beforeEach、beforeEnter 等守卫，识别预加载逻辑
```

**数据流转分析要点**：
1. **入口分析**：路由如何配置？参数如何传递？
2. **触发时机**：数据请求在哪里触发？(mounted/created/路由守卫/watch)
3. **状态管理**：数据存在哪里？局部state还是全局store？
4. **数据消费**：组件如何读取和展示数据？
5. **刷新恢复**：页面刷新后数据如何恢复？

#### 维度5：核心功能实现
**分析目标**：从路由入口出发，梳理完整的页面流程和数据传递链路

**分析步骤**：
1. **路由入口分析**：从路由配置识别功能入口和页面层级关系
2. **页面流程梳理**：画出页面跳转流程图，标注传递的参数
3. **页面状态控制**：识别影响页面流程走向的状态控制逻辑
4. **关键代码定位**：找到实现每一步的具体代码
5. **技术亮点提取**：识别有价值的技术实现

**流程分析要点**：
| 分析维度 | 关注内容 |
|---------|---------|
| 路由入口 | 从哪些路由/页面可以进入该功能？外部链接？首页入口？ |
| 参数传递 | 每次跳转携带什么参数？query/params/state？ |
| 流程分支 | 哪些条件会导致流程走向不同？成功/失败/中断？ |
| 页面状态控制 | 同一路由下，状态变化导致的页面内容切换（如：step状态控制多步骤表单）|
| 流程终点 | 流程的结束页面是什么？如何返回或重新开始？ |

**输出格式 - 流程图**：
```
┌─────────────────────────────────────────────────────────────────────────┐
│                    功能名称：<功能名称> 业务流程                           │
└─────────────────────────────────────────────────────────────────────────┘

【入口分析】
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   入口A      │     │   入口B       │     │   入口C      │
│  <路由路径>   │     │  <路由路径>   │     │  <外部链接>   │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │
       │ <触发动作>          │ <触发动作>          │ <触发动作>
       │ <参数类型>: {...}   │ <参数类型>: {...}   │ <参数类型>: {...}
       └────────────────────┼────────────────────┘
                            ▼
【核心流程】          ┌──────────────┐
                    │  <页面名称>   │
                    │  <路由路径>   │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │ <条件A>    │ <条件B>     │ <条件C>
              ▼            ▼            ▼
       ┌──────────┐  ┌──────────┐  ┌──────────┐
       │ <分支A>  │  │ <分支B>  │  │ <分支C>  │
       └────┬─────┘  └────┬─────┘  └────┬─────┘
            │             │             │
            └─────────────┼─────────────┘
                          ▼
【页面内状态控制】   ┌──────────────────────────────────────┐
（同一路由下）      │       <页面名称> <路由路径>            │
                   │  ┌─────────────────────────────────┐ │
                   │  │ <状态>=1: <步骤1说明>            │ │
                   │  │   ↓ [<操作>]                    │ │
                   │  │ <状态>=2: <步骤2说明>            │ │
                   │  │   ↓ [<操作>]                    │ │
                   │  │ <状态>=N: <步骤N说明>            │ │
                   │  └─────────────────────────────────┘ │
                   └──────────────┬───────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │ <结果A>           │ <结果B>            │ <结果C>
              ▼                   ▼                   ▼
       ┌──────────┐        ┌──────────┐        ┌──────────┐
       │ <结果页A> │        │ <结果页B> │        │ <结果页C> │
       │ <路由>   │        │ <路由>   │        │ <路由>   │
       │ <参数>   │        │ <参数>   │        │          │
       └──────────┘        └──────────┘        └──────────┘

【参数传递汇总】
| 跳转路径 | 参数类型 | 参数内容 | 用途 |
|---------|---------|---------|------|
| <起点>→<终点> | params/query/state | <参数字段> | <用途说明> |
| ... | ... | ... | ... |

示例：
| 跳转路径 | 参数类型 | 参数内容 | 用途 |
|---------|---------|---------|------|
| 首页→详情页 | params | id | 查询详情数据 |
| 列表→详情页 | query | id, from | 查询详情+返回标记 |
| 详情页→确认页 | state | formData, productInfo | 传递表单数据(不暴露在URL) |
| 确认页→成功页 | query | orderId | 展示订单信息 |

说明：
- <xxx> 为占位符，分析时替换为实际项目中的内容
- 参数类型：params(路由参数)、query(URL查询参数)、state(路由状态传参)
- 如果项目流程较简单，可省略部分结构；如果更复杂，可扩展分支
```

**页面状态控制识别要点**：
```
需要关注的状态类型（影响页面流程走向）：
┌────────────────┬────────────────────────────────────────┐
│ ✅ 需要关注     │ 说明                                   │
├────────────────┼────────────────────────────────────────┤
│ 步骤控制状态    │ 如 step/currentStep，控制多步骤表单流程   │
│ 流程模式状态    │ 如 mode (create/edit/view)，影响操作逻辑 │
│ 用户分流状态    │ 如 userType，新老用户/不同角色走不同流程  │
│ 业务阶段状态    │ 如 status/phase，订单状态决定展示内容    │
└────────────────┴────────────────────────────────────────┘

┌────────────────┬────────────────────────────────────────┐
│ ❌ 不需要关注   │ 说明                                   │
├────────────────┼────────────────────────────────────────┤
│ 弹窗显隐状态    │ modal/drawer 的 visible                │
│ 加载状态       │ loading/submitting                     │
│ 展开收起状态    │ expanded/collapsed                     │
│ 表单校验状态    │ errors/touched                         │
│ UI交互状态     │ hover/focus/active                     │
└────────────────┴────────────────────────────────────────┘

识别方法：搜索项目中的状态定义，筛选出影响主体内容渲染的状态
- 搜索关键词：step, phase, mode, type, status, stage 等
- 判断标准：该状态变化是否导致页面主体内容/流程走向发生变化
```

**关键代码定位**：
```
| 流程节点 | 文件路径 | 关键方法/组件 |
|---------|---------|--------------|
| 入口页面 | `<入口页面路径>` | <触发跳转的方法> |
| 数据获取 | `<页面路径>` | <数据请求的方法/hook> |
| 流程分支 | `<页面路径>` | <条件判断的方法/变量> |
| 状态控制 | `<页面路径>` | <控制流程的状态变量> |
| 结果页面 | `<结果页路径>` | <结果展示逻辑> |

示例：
| 流程节点 | 文件路径 | 关键方法/组件 |
|---------|---------|--------------|
| 入口页面 | `src/pages/home/index.tsx` | handleCardClick() |
| 数据获取 | `src/pages/order/detail.tsx` | useEffect + fetchOrderDetail() |
| 流程分支 | `src/pages/order/detail.tsx` | orderStatus 条件判断 |
| 状态控制 | `src/pages/order/confirm.tsx` | currentStep state |
| 结果页面 | `src/pages/order/success.tsx` | OrderSuccess 组件 |

说明：分析时根据实际项目代码填写具体的文件路径和方法名
```

#### 维度6：业务特性
**分析目标**：识别项目的业务规则和特殊逻辑

**分析要点**：
- **配置化能力**：哪些功能通过配置控制
- **多环境支持**：环境变量、接口地址配置
- **权限控制**：B端/C端区分、角色权限
- **特殊业务规则**：地区差异、时间限制等
- **错误处理**：统一错误处理、重试机制
- **性能优化**：懒加载、缓存策略

**输出格式**：
```markdown
### 业务特性清单

| 特性 | 说明 | 相关代码 |
|------|------|---------|
| <特性名称> | <实现方式说明> | `<相关文件路径>` |
| ... | ... | ... |

示例：
| 特性 | 说明 | 相关代码 |
|------|------|---------|
| B端/C端适配 | 通过URL参数channel判断，控制功能可见性 | `src/utils/channel.ts` |
| 多环境配置 | 支持dev/test/pre/prd四套环境 | `src/config/env.ts` |
| 权限控制 | 基于角色的路由和按钮权限 | `src/router/permission.ts` |
| 埋点上报 | 页面浏览和按钮点击事件上报 | `src/utils/tracker.ts` |

常见业务特性参考：
- B端/C端适配：通过URL/用户类型判断，控制功能可见性
- 多环境配置：支持多套环境切换
- 权限控制：角色/菜单/按钮级别权限
- 国际化：多语言支持
- 主题切换：明暗主题/自定义主题
- 埋点上报：行为数据采集
```

#### 维度7：登录与权限分析
**分析目标**：梳理项目的登录流程、身份认证机制和权限控制体系

**分析步骤**：
1. **登录方式识别**：找出项目支持的登录方式
2. **登录流程追踪**：梳理完整的登录数据流
3. **登录状态管理**：Token/Session 存储和使用方式
4. **登录状态检查**：路由守卫和接口拦截中的登录校验
5. **权限模型分析**：角色、菜单、按钮级别的权限控制
6. **权限控制实现**：路由权限、组件权限、接口权限的实现方式

**登录方式识别**：
```
常见登录方式（搜索关键词）：
┌────────────────┬────────────────────────────────────────┐
│ 登录方式       │ 搜索关键词                               │
├────────────────┼────────────────────────────────────────┤
│ 账号密码登录    │ login, password, username, account     │
│ 手机验证码登录  │ sms, captcha, verifyCode, mobile       │
│ 第三方登录     │ oauth, wechat, alipay, sso, openid     │
│ 扫码登录       │ qrcode, scan                           │
│ 免密登录       │ token, autoLogin, silent               │
│ SSO单点登录    │ sso, cas, saml, ticket                 │
└────────────────┴────────────────────────────────────────┘
```

**登录流程输出格式**：
```
┌─────────────────────────────────────────────────────────────────────────┐
│                           登录流程分析                                    │
└─────────────────────────────────────────────────────────────────────────┘

【登录入口】
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  登录页入口   │     │  第三方入口   │     │  免密入口    │
│  /login      │     │  /oauth/xxx  │     │  ?token=xxx  │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │
       ▼                    ▼                    ▼
【认证流程】
┌──────────────────────────────────────────────────────────┐
│  1. 用户输入凭证 / 第三方授权 / URL携带Token               │
│  2. 调用登录接口 → POST /api/login                       │
│  3. 后端校验 → 返回 Token + 用户信息                      │
│  4. 前端存储 Token → localStorage/sessionStorage/Cookie  │
│  5. 存储用户信息 → Store                                 │
│  6. 跳转目标页面 → 首页 / 原访问页面                       │
└──────────────────────────────────────────────────────────┘

【Token管理】
┌──────────────┬────────────────────────────────────────────┐
│ 存储位置      │ <localStorage / sessionStorage / Cookie>  │
│ 存储Key       │ <token / accessToken / Authorization>     │
│ 过期处理      │ <刷新Token / 跳转登录页>                    │
│ 请求携带方式   │ <Header: Authorization / Cookie自动携带>  │
└──────────────┴────────────────────────────────────────────┘

示例：
| 项目 | 值 |
|------|------|
| 存储位置 | localStorage |
| 存储Key | accessToken |
| 过期处理 | 401时尝试refreshToken，失败跳转登录页 |
| 请求携带方式 | Header: Authorization: Bearer ${token} |
```

**登录状态检查**：
```
// ==================== 语法参考：登录状态检查位置 ====================
// 搜索项目中的登录状态检查逻辑，通常在以下位置：

// 1. 路由守卫（页面级登录检查）
// ===== Vue Router =====
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('<tokenKey>');
  // 例：const token = localStorage.getItem('accessToken');
  if (to.meta.<需要登录标记> && !token) {
    next({ path: '/<登录页路径>', query: { redirect: to.fullPath } });
    // 例：next({ path: '/login', query: { redirect: to.fullPath } });
  } else {
    next();
  }
});

// ===== React Router（通常封装为高阶组件或自定义Hook）=====
const PrivateRoute = ({ children }) => {
  const token = localStorage.getItem('<tokenKey>');
  if (!token) {
    return <Navigate to="/<登录页路径>" state={{ from: location }} />;
    // 例：return <Navigate to="/login" state={{ from: location }} />;
  }
  return children;
};

// 2. 请求拦截器（接口级登录检查）
axios.interceptors.request.use(config => {
  const token = localStorage.getItem('<tokenKey>');
  if (token) {
    config.headers['<HeaderKey>'] = `<前缀> ${token}`;
    // 例：config.headers['Authorization'] = `Bearer ${token}`;
  }
  return config;
});

// 3. 响应拦截器（Token过期处理）
axios.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      // Token过期处理
      // 方式1：直接跳转登录页
      router.push('/<登录页路径>');
      // 方式2：尝试刷新Token
      return refreshToken().then(() => axios(error.config));
    }
    return Promise.reject(error);
  }
);
```

**权限模型分析**：
```
常见权限模型：
┌────────────────┬────────────────────────────────────────────────────────┐
│ 权限模型       │ 说明                                                   │
├────────────────┼────────────────────────────────────────────────────────┤
│ RBAC          │ 基于角色的权限控制，用户→角色→权限                        │
│ ABAC          │ 基于属性的权限控制，根据用户/资源/环境属性动态判断          │
│ ACL           │ 访问控制列表，直接定义用户对资源的权限                     │
│ 简单角色模式   │ 用户直接关联角色，角色决定功能可见性                       │
└────────────────┴────────────────────────────────────────────────────────┘

权限控制层级：
┌────────────────┬────────────────────────────────────────────────────────┐
│ 层级           │ 实现方式                                                │
├────────────────┼────────────────────────────────────────────────────────┤
│ 路由权限       │ 路由守卫中检查用户角色/权限，无权限跳转403或隐藏菜单        │
│ 菜单权限       │ 根据权限动态生成菜单，或过滤菜单配置                       │
│ 按钮/操作权限  │ 组件中根据权限控制按钮显隐或禁用                          │
│ 数据权限       │ 接口层面控制，前端一般只做展示过滤                         │
└────────────────┴────────────────────────────────────────────────────────┘
```

**权限控制实现**：
```javascript
// ==================== 语法参考：权限控制实现方式 ====================

// 1. 路由权限控制
// ===== 方式1：路由元信息 + 守卫 =====
// 路由配置
{
  path: '/<路径>',
  meta: { 
    roles: ['<角色1>', '<角色2>'],           // 例：roles: ['admin', 'editor']
    permissions: ['<权限码1>', '<权限码2>']   // 例：permissions: ['user:edit', 'user:delete']
  }
}
// 路由守卫
router.beforeEach((to, from, next) => {
  const userRoles = store.getters.roles;     // 获取用户角色
  if (to.meta.roles && !to.meta.roles.some(role => userRoles.includes(role))) {
    next('/403');  // 无权限
  } else {
    next();
  }
});

// ===== 方式2：动态路由（根据权限生成路由表）=====
// 登录后根据用户权限过滤路由
const accessRoutes = filterRoutes(asyncRoutes, userPermissions);
// 例：const accessRoutes = asyncRoutes.filter(route => 
//       !route.meta?.permissions || 
//       route.meta.permissions.some(p => userPermissions.includes(p))
//     );
router.addRoute(accessRoutes);

// 2. 菜单权限控制
// 根据权限过滤菜单
const filteredMenus = menus.filter(menu => {
  return !menu.<权限字段> || userPermissions.includes(menu.<权限字段>);
  // 例：return !menu.permission || userPermissions.includes(menu.permission);
});

// 3. 按钮/操作权限控制
// ===== Vue 指令方式 =====
// 自定义指令 v-permission
Vue.directive('permission', {
  inserted(el, binding) {
    const permissions = store.getters.permissions;
    if (!permissions.includes(binding.value)) {
      el.parentNode?.removeChild(el);
    }
  }
});
// 使用：<button v-permission="'user:delete'">删除</button>

// ===== React Hook/组件方式 =====
const usePermission = (permission: string) => {
  const permissions = useUserStore(state => state.permissions);
  return permissions.includes(permission);
};
// 使用：
const canDelete = usePermission('user:delete');
{canDelete && <Button>删除</Button>}

// 或封装为组件
const Authorized = ({ permission, children }) => {
  const hasPermission = usePermission(permission);
  return hasPermission ? children : null;
};
// 使用：<Authorized permission="user:delete"><Button>删除</Button></Authorized>
```

**输出格式 - 登录与权限分析**：
```markdown
### 登录与权限分析

#### 1. 登录方式
| 登录方式 | 入口路径 | 相关文件 |
|---------|---------|---------|
| <登录方式> | <路由/URL> | `<文件路径>` |

示例：
| 登录方式 | 入口路径 | 相关文件 |
|---------|---------|---------|
| 账号密码登录 | /login | `src/pages/login/index.tsx` |
| 微信授权登录 | /oauth/wechat | `src/pages/oauth/wechat.tsx` |
| URL Token免密 | ?token=xxx | `src/utils/autoLogin.ts` |

#### 2. Token管理
| 项目 | 实现方式 | 相关代码 |
|------|---------|---------|
| 存储位置 | <位置> | `<文件路径>` |
| 请求携带 | <方式> | `<文件路径>` |
| 过期处理 | <策略> | `<文件路径>` |

#### 3. 登录状态检查
| 检查位置 | 检查逻辑 | 相关代码 |
|---------|---------|---------|
| 路由守卫 | <逻辑说明> | `<文件路径>` |
| 请求拦截 | <逻辑说明> | `<文件路径>` |
| 响应拦截 | <逻辑说明> | `<文件路径>` |

#### 4. 权限控制
| 权限层级 | 实现方式 | 相关代码 |
|---------|---------|---------|
| 路由权限 | <实现方式> | `<文件路径>` |
| 菜单权限 | <实现方式> | `<文件路径>` |
| 按钮权限 | <实现方式> | `<文件路径>` |
```

**关键文件定位**：
```
登录与权限相关的关键文件（常见路径）：
┌────────────────┬────────────────────────────────────────┐
│ 功能           │ 常见文件路径                            │
├────────────────┼────────────────────────────────────────┤
│ 登录页面       │ src/pages/login/                       │
│ 路由守卫       │ src/router/permission.ts               │
│               │ src/router/guard.ts                    │
│ 请求封装       │ src/utils/request.ts                   │
│               │ src/api/http.ts                        │
│ 用户状态       │ src/store/user.ts                      │
│               │ src/stores/userStore.ts                │
│ 权限指令       │ src/directives/permission.ts           │
│ 权限组件       │ src/components/Authorized/             │
│ 权限工具       │ src/utils/permission.ts                │
│               │ src/utils/auth.ts                      │
└────────────────┴────────────────────────────────────────┘

搜索关键词：
- 登录相关：login, logout, auth, token, session, cookie
- 权限相关：permission, role, authorize, access, guard, private
- 拦截器：interceptor, beforeEach, middleware
```

---

## 模块分析模式

当用户要求分析特定模块时，聚焦以下内容：

### 模块分析模板

```markdown
# [模块名称] 模块分析

## 1. 模块概述
- 功能定位：
- 使用场景：
- 核心能力：

## 2. 路由入口分析
```
【入口方式】
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   入口A      │     │   入口B       │     │   入口C      │
│  <路由路径>   │     │  <路由路径>   │     │  <外部链接>   │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │ <参数>             │ <参数>             │ <参数>
       └────────────────────┼────────────────────┘
                            ▼
                    ┌──────────────┐
                    │  模块入口页面  │
                    └──────────────┘

入口参数说明：
| 入口来源 | 参数类型 | 参数内容 | 用途 |
|---------|---------|---------|------|
| ... | ... | ... | ... |
```

## 3. 页面流程图
```
┌─────────────────────────────────────────────────────────────┐
│                    [模块名称] 页面流程                        │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐
│  步骤1页面    │
│  <路由路径>   │
└──────┬───────┘
       │ <传递参数>
       ▼
┌──────────────┐     <条件分支>
│  步骤2页面    │ ──────────────┐
│  <路由路径>   │               │
└──────┬───────┘               ▼
       │                ┌──────────────┐
       │                │  分支页面     │
       │                └──────────────┘
       ▼
┌──────────────┐
│  结果页面     │
│  <路由路径>   │
└──────────────┘

【页面内状态控制】（如有）
同一路由下的状态切换：
- <状态名>=<值1>: <展示内容1>
- <状态名>=<值2>: <展示内容2>
```

## 4. 数据流转图
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   路由层    │ ──► │   API层     │ ──► │   状态层    │ ──► │   视图层    │
│  <路由文件>  │     │  <API文件>  │     │ <Store文件> │     │  <页面文件>  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘

关键数据流：
| 数据项 | 来源 | 流向 | 相关文件 |
|-------|------|------|---------|
| ... | ... | ... | ... |
```

## 5. 文件结构
```
模块目录/
├── index.tsx           # 入口页面
├── [step]/             # 步骤页面（如有）
├── components/         # 子组件
├── hooks/              # 自定义hooks
├── services/           # API调用
├── store/              # 状态管理
├── types/              # 类型定义
└── utils/              # 工具函数
```

## 6. 关键代码定位
| 功能点 | 文件路径 | 关键方法/组件 |
|-------|---------|--------------|
| 路由配置 | `...` | ... |
| 页面入口 | `...` | ... |
| 数据获取 | `...` | ... |
| 状态管理 | `...` | ... |
| 核心逻辑 | `...` | ... |

## 7. 依赖关系
- 依赖的组件：
- 依赖的API：
- 依赖的Store：
- 依赖的工具函数：

## 8. 注意事项
- 边界情况：
- 已知问题：
- 优化建议：
```

---

## 输出文档模板

### 全量分析文档结构

```markdown
# [项目名称] 项目结构梳理

> 用于技术交接和工作复盘的项目分析文档
> 生成时间：YYYY-MM-DD

---

## 1. 项目一句话总结
**xxx项目**，[核心功能]，[业务场景]，[目标用户]。

---

## 2. 技术栈与整体架构说明

### 2.1 核心技术栈
| 类别 | 技术选型 | 版本 |
|------|---------|------|
| 框架 | ... | ... |
| 状态管理 | ... | ... |
| 路由 | ... | ... |
| UI组件库 | ... | ... |
| HTTP客户端 | ... | ... |

### 2.2 项目整体流程图
（从用户入口到核心功能的完整流转）
```
┌─────────────────────────────────────────────────────────────┐
│                      项目整体流程                            │
└─────────────────────────────────────────────────────────────┘

【用户入口】
┌──────────────┐     ┌──────────────┐
│   入口A      │     │   入口B       │
│  <说明>      │     │  <说明>       │
└──────┬───────┘     └──────┬───────┘
       │                    │
       └────────┬───────────┘
                ▼
【登录/鉴权】
┌──────────────────────────────────────┐
│  登录检查 → 未登录跳转登录页           │
│  权限检查 → 无权限跳转403             │
└──────────────┬───────────────────────┘
               ▼
【核心功能模块】
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   模块A      │ ──► │   模块B      │ ──► │   模块C      │
│  <说明>      │     │  <说明>      │     │  <说明>      │
└──────────────┘     └──────────────┘     └──────────────┘
       │ <跳转条件>         │ <跳转条件>
       ▼                   ▼
      ...                 ...
```

### 2.3 多环境配置
| 环境 | 域名 | 配置文件 |
|------|------|---------|
| 开发 | ... | ... |
| 测试 | ... | ... |
| 生产 | ... | ... |

---

## 3. 登录与权限体系

### 3.1 登录流程图
```
【登录流程】
用户访问 → 登录检查 → 未登录 → 登录页 → 认证成功 → 存储Token → 跳转目标页
                    → 已登录 → 直接访问
```

### 3.2 登录方式
| 登录方式 | 入口 | 相关文件 |
|---------|------|---------|
| ... | ... | ... |

### 3.3 权限控制
| 权限层级 | 实现方式 | 相关文件 |
|---------|---------|---------|
| 路由权限 | ... | ... |
| 菜单权限 | ... | ... |
| 按钮权限 | ... | ... |

---

## 4. 核心模块清单

### 4.1 [模块1名称]
**功能说明**：...

**路由入口**：
| 路由路径 | 入口来源 | 携带参数 |
|---------|---------|---------|
| ... | ... | ... |

**页面流程图**：
```
[页面A] ──参数──► [页面B] ──条件──► [页面C]
                         └──条件──► [页面D]
```

**关键文件**：
| 文件 | 职责 |
|------|------|
| ... | ... |

### 4.2 [模块2名称]
...

---

## 5. 关键业务流程梳理

### 5.1 [流程1名称]
**流程图**：
```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  步骤1   │ ──► │  步骤2   │ ──► │  步骤3   │
│ <页面>   │     │ <页面>   │     │ <页面>   │
│ <参数>   │     │ <参数>   │     │ <参数>   │
└──────────┘     └──────────┘     └──────────┘
```

**数据流转**：
| 节点 | 数据来源 | 数据流向 | 说明 |
|------|---------|---------|------|
| ... | ... | ... | ... |

**关键代码**：
| 功能点 | 文件路径 | 方法/组件 |
|-------|---------|----------|
| ... | ... | ... |

### 5.2 [流程2名称]
...

---

## 6. 数据流转总览

### 6.1 整体数据流架构
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   路由层    │ ──► │   API层     │ ──► │   状态层    │ ──► │   视图层    │
│             │     │             │     │             │     │             │
│ 路由配置    │     │ 接口封装    │     │ Store定义   │     │ 页面组件    │
│ 参数传递    │     │ 请求/响应   │     │ 状态管理    │     │ 数据消费    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### 6.2 关键数据实体
| 数据实体 | 用途 | 定义位置 | 使用位置 |
|---------|------|---------|---------|
| ... | ... | ... | ... |

---

## 7. 前端工程价值与亮点抽象

### 7.1 [亮点1]
[说明和代码示例]

### 7.2 [亮点2]
...

---

## 8. 目录结构速览
```
项目根目录/
├── src/
│   ├── api/            # API层
│   ├── components/     # 组件层
│   ├── pages/          # 页面层
│   ├── router/         # 路由层
│   ├── store/          # 状态层
│   ├── utils/          # 工具层
│   └── ...
└── ...
```

---

## 9. 总结
[项目特点总结]

---

## 附录

### A. 关键API接口清单
| 接口路径 | 方法 | 用途 | 调用页面 |
|---------|------|------|---------|
| ... | ... | ... | ... |

### B. 路由清单
| 路由路径 | 页面 | 权限要求 | 入口来源 |
|---------|------|---------|---------|
| ... | ... | ... | ... |
```
#### 文档输出路径
- 项目分析：输出MD文档到当前项目的根目录
- 功能模块分析：输出MD文到当前模块的目录下
---

## 分析技巧

### 分析顺序（推荐）
```
┌─────────────────────────────────────────────────────────────────────────┐
│                         项目分析推荐顺序                                  │
└─────────────────────────────────────────────────────────────────────────┘

1. 【项目元信息】
   package.json → 技术栈和依赖
   README.md → 项目说明
   
2. 【路由配置】（核心！决定了项目的页面结构和流转）
   router/index.js → 所有页面入口、路由参数、路由守卫
   
3. 【登录与权限】
   登录页面 → 登录流程
   路由守卫/拦截器 → 登录检查、权限控制
   
4. 【核心业务流程】
   从路由入口 → 追踪页面跳转 → 绘制流程图
   
5. 【数据流转】
   路由参数 → API调用 → Store管理 → 组件消费
   
6. 【状态管理】
   store/ → 全局状态结构
```

### 快速定位关键文件
```
| 功能 | 常见路径 | 分析要点 |
|------|---------|---------|
| 入口文件 | main.js / index.js / App.vue | 全局配置、插件注册 |
| 路由配置 | router/index.js | 页面结构、路由守卫、权限配置 |
| 登录相关 | pages/login/ | 登录方式、认证流程 |
| 权限控制 | router/permission.ts | 路由权限、登录检查 |
| 请求封装 | utils/request.ts / api/http.ts | Token处理、拦截器 |
| 状态管理 | store/ / stores/ | 全局状态、用户信息 |
| 公共配置 | config/ / constants/ | 环境配置、常量定义 |
```

### 追踪代码链路（流转优先）
```
【页面流转追踪】
路由配置 → 找到页面入口
    ↓
页面组件 → 找到跳转触发点（router.push / Link）
    ↓
跳转参数 → 追踪参数来源和用途
    ↓
目标页面 → 追踪参数如何使用
    ↓
绘制流程图 → 标注路由、参数、条件

【数据流转追踪】
路由参数（query/params/state）
    ↓
API调用 → 找到接口定义
    ↓
Store存储 → 找到状态管理
    ↓
组件消费 → 找到数据展示
    ↓
绘制数据流图 → 标注数据来源和流向
```

### 识别代码模式
```
| 模式类别 | 识别关键词 | 常见实现 |
|---------|-----------|---------|
| 路由跳转 | router.push, navigate, Link | 页面间流转 |
| 参数传递 | params, query, state, props | 数据传递 |
| 登录检查 | beforeEach, PrivateRoute, token | 权限守卫 |
| 权限控制 | permission, role, v-permission | 功能控制 |
| 状态管理 | store, dispatch, commit, set | 数据管理 |
| API调用 | axios, fetch, request, api | 接口请求 |
| 条件分支 | if/switch + 路由跳转 | 流程分支 |
| 步骤控制 | step, currentStep, phase | 多步骤流程 |
```

---

## 注意事项

### 分析原则
1. **路由优先**：从路由配置开始分析，路由决定了页面结构和流转关系
2. **流程为主**：重点关注页面如何流转、数据如何传递
3. **先读后写**：分析前必须先读取关键文件，不要凭猜测
4. **追根溯源**：遇到函数调用要追踪到定义处
5. **关注注释**：代码注释往往包含重要业务信息

### 输出要求
1. **流程图必须**：涉及页面跳转、数据流转的内容必须用流程图展示
2. **参数标注**：流程图中要标注路由参数、跳转条件
3. **关联代码**：关键节点要标注对应的文件路径和方法名
4. **状态说明**：页面内状态控制要单独说明（区分于UI状态）

### 流程图规范
```
【页面流转图】必须包含：
- 路由路径
- 跳转触发条件
- 传递的参数（params/query/state）
- 分支条件

【数据流转图】必须包含：
- 数据来源（路由参数/API/Store）
- 数据流向
- 关键文件位置

【页面状态控制】只关注：
- 影响主体内容的状态（step/mode/phase）
- 不关注UI状态（loading/visible/expanded）
```
