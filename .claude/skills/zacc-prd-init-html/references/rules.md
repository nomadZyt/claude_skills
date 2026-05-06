# zacc-prd-init-html — HTML 原型规则

## 角色与边界

- 产出为**中间协议**：高信噪比、强结构化 HTML，供下游组件化与工程实现；非生产可上线页面。
- 核心原则：**重结构、重语义、重业务；轻视觉、轻装饰。**
- 除非用户明确要求，不生成：JS 实现、API 代码、React/Vue 组件、构建/路由/状态管理配置。交互仅用 `data-role` / `data-name` 与 HTML 注释表达。
- 当用户真正需要 React/Vue 页面、完整交互逻辑、视觉精修稿或生产级前端工程时，不应强行套用本规则，应明确当前输出是"结构化原型协议"。

## 适用场景

- 根据产品需求生成页面原型
- 根据 PRD、草图、线框描述生成 HTML 结构
- 为下游 AI 生成可解析的页面骨架
- 将业务页面拆成模块化 HTML 片段
- 输出便于组件化改造的页面结构协议
- 对现有 HTML 文件进行结构化改造

## 两种工作模式

- **生成模式**：根据自然语言需求从零生成模块化 HTML 原型。
- **改造模式**：对现有 HTML 文件按规则进行结构化改造，输出到源文件同级 `{filename}-prototype/` 文件夹，源文件不修改。

## 生成目录约定（重要）

- `prototype/` 仅作为原型根目录，不直接平铺某个业务 PRD 的页面文件。
- 每次根据 PRD 生成时，必须创建并使用独立子目录：`prototype/<prd-slug>/`。
- `prd-slug` 取 PRD 文件名（去扩展名、去 `PRD` 后缀）后转 kebab-case；无法稳定转换时使用 `prd-YYYYMMDD-<short-hash>`。
- 本次生成涉及的 `index.html` 与子模块文件均写入 `prototype/<prd-slug>/`。

## Structural Metadata

- 关键 DOM 节点须含 `data-role` 与 `data-name`；勿对普通节点滥标。
- `data-role` 枚举（优先严格使用）：`page`、`section`、`dialog`、`drawer`、`navbar`、`tabbar`、`action`、`form`、`field`、`list`、`item`。
- `data-name`：英文 kebab-case，表达业务语义，禁止 `box1`、`wrapper` 等无意义名。

`data-name` 正确示例：`order-summary`、`payment-method-list`、`submit-payment`

`data-name` 错误示例：`box1`、`blue-card`、`wrapper`

## Zero Visual Noise

- **禁止**：`<svg>` / `<path>`、base64 图片、`style="..."` 内联样式、装饰性插图、为好看而加的复杂动画/渐变/阴影/滤镜。
- **图标占位（推荐）**：在承载图标的元素上使用 `data-icon="描述"`（语义等价于历史上的 `[ICON: 描述]`，供下游映射图标组件）；**可见区域**仅用极简示意（符号、缩写、圆形容器+短字），避免把 `[ICON: …]` 与主文案并排作为主视觉。
- **图标占位（兼容）**：仍允许在正文中写 `[ICON: 描述]`（例如遗留片段或仅需文本 grep 的场景）。
- **图片占位**：仍使用 `[IMAGE: 描述]`（若需与图标一致的可解析性，可额外约定 `data-image`，非默认要求）。

示例（推荐）：
```html
<button type="button" data-role="action" data-name="back" data-icon="返回" class="inline-flex items-center gap-1.5 px-3 py-1.5 border rounded-full text-sm">
  <span aria-hidden="true">←</span>
  <span>返回列表</span>
</button>
<span data-icon="用户头像" class="inline-flex h-9 w-9 items-center justify-center rounded-full border bg-slate-100 text-sm font-medium" role="img" aria-label="用户头像">我</span>
<span class="inline-flex items-center gap-1.5 text-green-600" data-icon="通过">
  <span class="inline-flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-green-100 text-xs font-semibold text-green-800" aria-hidden="true">✓</span>
  <span>校验通过</span>
</span>
```

示例（图片）：
```html
<div>[IMAGE: 商品封面图]</div>
```

## Modular Chunking

- 复杂页禁止单文件堆砌；满足多模块、弹窗/抽屉、预计 >300 行等须拆文件。
- 主文件用 `<!-- Module: xxx -->` 标明子模块插入位；不用框架 include、不发明模板语法。
- 拆分按**业务结构**进行，而非纯视觉区块。
- 每个生成页面必须显式包含 chunk 注释：至少 1 条 `<!-- Module: ... -->` 与 2 条 `<!-- Chunk: ... -->`。
- `Module` 用于页面级/容器级模块，`Chunk` 用于该模块下可独立理解的业务分块。

拆分建议：
- 页面骨架：`index.html`
- 顶部导航：`header.html`
- 独立业务模块：如 `order-summary.html`
- 表单模块：如 `payment-form.html`
- 覆盖层模块：如 `payment-dialog.html`

## Multi-File Navigation & Linkage

多个 HTML 文件必须联动，形成可导航的整体，禁止生成孤立文件。采用 **JS 动态加载** 方式驱动页面切换，模拟单页应用体验。

### 入口文件 `index.html` 职责

`index.html` 是整个原型的**导航中枢和 SPA 容器**：

1. **导航栏**：列出所有子模块，点击时切换视图
2. **内容容器** `<div id="app">`：所有子模块内容在此渲染
3. **路由脚本**：内联一段轻量 JS，负责 fetch 子模块 HTML 并注入到 `#app`
4. 页面标题设为业务名称

#### index.html 核心结构

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>业务名称 - 原型</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body data-role="page" data-name="prototype-home" class="min-h-screen flex flex-col">

  <header data-role="navbar" data-name="main-nav" class="flex items-center justify-between p-4 border-b">
    <a href="#" onclick="navigate('case-list')" class="font-medium">业务名称</a>
    <button type="button" data-icon="更多" class="inline-flex h-9 w-9 items-center justify-center rounded-lg border text-slate-600" aria-label="更多">⋯</button>
  </header>

  <!-- 模块导航：点击切换子模块 -->
  <nav data-role="tabbar" data-name="module-nav" class="flex gap-2 p-3 border-b bg-gray-50 text-sm">
    <button onclick="navigate('case-list')" class="px-3 py-1 rounded border">案件列表</button>
    <button onclick="navigate('case-detail')" class="px-3 py-1 rounded border">案件详情</button>
  </nav>

  <!-- SPA 内容区：子模块 HTML 在此动态渲染 -->
  <main id="app" class="flex-1 p-4"></main>

  <!-- 路由脚本：fetch 子模块 HTML 并注入 #app -->
  <script>
    async function navigate(module) {
      const resp = await fetch(module + '.html');
      const html = await resp.text();
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const body = doc.querySelector('body');
      document.getElementById('app').innerHTML = body ? body.innerHTML : html;
    }
    // 默认加载第一个模块
    navigate('case-list');
  </script>

</body>
</html>
```

### 子模块文件规范

1. **独立可运行**：含完整 `<!DOCTYPE html>`、`<head>`（含 Tailwind CDN）、`<body>`，可单独打开预览
2. **`<body>` 内容可被抽取**：`index.html` 的路由脚本会 fetch 子模块 HTML，解析出 `<body>` 内部内容注入 `#app`，因此子模块的业务内容必须放在 `<body>` 内
3. **跨模块跳转用 `navigate()`**：按钮/链接触发其他模块时，使用 `onclick="navigate('module-name')"` 而非 `<a href="xxx.html">`
4. **弹窗/抽屉场景**：弹窗仍生成独立 HTML，同时在 `index.html` 中作为隐藏层内联，通过 `navigate()` 切换显示

#### 子模块文件示例（case-list.html）

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>案件列表</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>
  <section data-role="section" data-name="case-list" class="space-y-3">
    <div data-role="list" data-name="cases">
      <!-- Action: 点击案件条目跳转至案件详情 -->
      <div data-role="item" data-name="case-item" class="p-3 border rounded" onclick="navigate('case-detail')">
        <div>案件编号：A20240001</div>
        <div>状态：待审核</div>
      </div>
    </div>
  </section>
</body>
</html>
```

### 联动流程示例

```text
用户在 index.html 看到导航：[案件列表] [案件详情]
  → 默认加载 case-list.html → #app 渲染案件列表
  → 点击某条案件 → navigate('case-detail') → #app 渲染 case-detail.html
  → 点击导航栏「案件列表」→ navigate('case-list') → #app 切换回列表
  → 子模块也可单独打开 case-list.html 独立预览
```

### 为什么用 JS 而非 iframe/纯链接

- **iframe**：体验割裂、高度自适应差、跨域受限
- **纯链接**：每次跳转整页刷新，丢失导航上下文
- **JS 动态加载**：单页体验、导航常驻、切换流畅、子模块仍可独立预览

## Semantic HTML & Minimal Styling

- 优先语义标签：`header`、`main`、`section`、`nav`、`article`、`form`、`footer` 等。
- 样式仅用**基础 Tailwind**：布局/间距/字号/简单边框；避免复杂渐变、动画、细碎视觉微调。

推荐方向：`flex`、`grid`、`p-4`、`mt-3`、`text-sm`、`border-b`

避免方向：复杂渐变、复杂动画、大量阴影、极端细碎的视觉微调

## Business Logic in Comments

- 关键交互（提交、开关弹窗、状态/标签切换、筛选、支付/保存等）须在相邻处用 HTML 注释写**业务目的**（非「这是一个按钮」）。

必须标注的场景：表单提交、弹窗打开/关闭、状态切换、标签切换、筛选排序、删除/确认/支付/保存等关键动作、会触发后端请求或页面状态变化的节点。

示例：
```html
<!-- Action: submit selected payment method and create payment order -->
<button data-role="action" data-name="submit-payment">确认支付</button>
```

## 改造模式规则

- 对现有 HTML 改造时，输出到源文件同级 `{filename}-prototype/` 文件夹，不修改源文件。
- 改造内容：补充 `data-role`/`data-name`、移除 SVG/base64/内联样式、替换语义标签、添加业务注释、必要时拆分模块。
- 改造完成后输出简要改造报告。

## 输出习惯（生成阶段）

- 先输出目录树，再逐文件；每文件以 `<!-- File: path -->` 标注。
- 信息不全时不中断：合理假设，文末列关键假设。
- 写入前先检查目标文件是否已存在；存在时必须先确认覆盖，确认后执行覆盖写入，禁止拼接追加。

## 缺失信息

- 不强行追问；中性占位；文末列假设。

## 默认执行步骤

1. 提炼页面目标、关键模块、关键交互
2. 判断是否需要拆分多个 HTML 文件
3. 设计目录结构树
4. 先写主页面骨架，再写子模块片段
5. 为关键结构节点补充 `data-role` 与 `data-name`
6. 为关键交互补充业务注释
7. 清理视觉噪音，确认没有 SVG、base64、内联样式和无效装饰
8. 输出结果，并在必要时补充简短假设说明

## 输出前自检

- 是否先输出了目录结构树
- 是否所有关键模块都带有 `data-role` 和 `data-name`
- 是否避免了 SVG、base64、内联样式
- 图标占位是否优先使用 `data-icon`（或兼容 `[ICON: …]`），且可见示意保持简洁
- 是否使用了语义化 HTML
- 是否在关键交互处添加了业务注释
- 是否在复杂页面场景下进行了文件拆分
- 是否每个页面都包含 `Module/Chunk` 注释（至少 1 Module + 2 Chunk）
- 是否保持高信噪比，避免无意义视觉细节
- index.html 是否包含模块导航和 SPA 容器（#app + navigate 脚本）
- 子模块是否独立可运行且 `<body>` 内容可被抽取
- 跨模块交互是否通过 navigate() 函数联动
- 是否执行了同名文件覆盖确认，并采用覆盖写入（非拼接）
