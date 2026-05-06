---
name: zacc-prd-init-html
disable-model-invocation: true
description: HTML 原型项目初始化与生成技能：初始化项目环境（规则下沉、目录创建），并根据 PRD/md 文件生成结构化 HTML 原型。当用户提到"初始化原型项目""创建原型项目""规则下沉""根据 PRD 生成原型""根据需求生成页面"等请求时触发。
---

# zacc-prd-init-html — 项目初始化与原型生成技能

本技能具备两项核心能力：
1. **项目初始化** — 创建目录结构、将规则写入 CLAUDE.md 和 Cursor 规则文件、生成入口文件
2. **原型生成** — 读取指定的 md/PRD 文件，按规则生成结构化 HTML 原型

## 触发条件

当用户提到以下关键词时触发：
- "初始化原型项目""创建原型项目""新建 HTML 原型""规则下沉"
- "根据 PRD 生成原型""根据需求生成页面""把 PRD 转成 HTML"
- 直接指定一个 md 文件要求生成原型，如 `用 prd/xxx.md 生成原型`

## 使用方式

```
/zacc-prd-init-html                          → 仅执行项目初始化
/zacc-prd-init-html prd/某需求_PRD.md         → 初始化 + 根据该 PRD 生成原型
/zacc-prd-init-html prd/某需求_PRD.md --only  → 跳过初始化，仅根据 PRD 生成原型
```

---

## 能力一：项目初始化

### 第一步：检测当前状态

逐一检查以下内容，判断哪些步骤需要执行：

1. `CLAUDE.md` 是否存在，是否包含 `zacc-prd-init-html` 规则小节
2. `.cursor/rules/zacc-prd-init-html.mdc` 是否存在，内容是否与规则一致
3. `prototype/` 目录是否存在
4. `prototype/` 下是否已有按 PRD 拆分的子目录（如 `prototype/ai-claim-case-management/`）
5. `prototype/` 下（含子目录）是否已存在 `.html` 文件；若存在，在状态报告中列出路径，**不**自动按本技能规则对其进行改造（须见第五步）

输出当前状态报告，告知用户哪些需要创建/更新。

### 第二步：写入规则到 CLAUDE.md

如果 `CLAUDE.md` 中缺少 `zacc-prd-init-html` 规则小节：

1. 如果 `CLAUDE.md` 不存在，创建新文件
2. 如果 `CLAUDE.md` 已存在，在文件末尾追加
3. 写入的规则内容以本技能 `references/rules.md` 中的内容为准
4. 在规则小节顶部加入项目路径信息：
   ```markdown
   ## HTML 原型（zacc-prd-init-html）

   - 原型根目录：`prototype/`
   - 生成目录：`prototype/<prd-slug>/`
   - 入口文件：`prototype/<prd-slug>/index.html`
   ```

### 第三步：写入规则到 Cursor 规则文件

如果 `.cursor/rules/zacc-prd-init-html.mdc` 不存在或内容不一致：

1. 如果 `.cursor/rules/` 目录不存在，先创建
2. 写入 `.cursor/rules/zacc-prd-init-html.mdc`，包含以下 frontmatter：
   ```yaml
   ---
   description: HTML 产品原型（zacc-prd-init-html）— 结构化中间协议，非生产页面
   globs: prototype/**/*.html
   alwaysApply: false
   ---
   ```
3. 规则正文与 CLAUDE.md 中的内容保持一致，不得弱于 CLAUDE.md

### 第四步：创建原型目录结构

如果 `prototype/` 目录不存在：

1. 创建 `prototype/` 目录
2. （可选）创建 `prototype/index.html` 作为总览入口，仅用于跳转各 PRD 子目录
3. 实际业务原型文件必须生成在 `prototype/<prd-slug>/` 中，不直接平铺在 `prototype/`

### 第五步：已有 HTML 与规则对齐（须征求同意）

若在初始化流程中检测到 **`prototype/` 下已有 `.html` 文件**（含子目录）：

**含义说明**：此处的「改造 / 对齐」指按 `references/rules.md` 与本技能约定，对存量 HTML 做**结构化规范化**（例如补齐 `data-role` / `data-name`、Module/Chunk 注释、去 SVG/base64/内联样式、图标语义位、业务注释、`navigate()` 联动约定等），使文件符合原型中间协议。**不是**指 Prettier、编辑器「格式化文档」等**纯排版/缩进**工具。

1. **禁止**在未征得用户同意的情况下，擅自按上述规则改写、重排或大面积替换这些文件内容
2. **必须**列出检测到的文件路径，并询问用户是否要对这些 HTML **按技能规则做改造**（可约定范围：全部 / 指定子目录 / 指定文件）
3. **仅当用户明确同意**（如「全部按规则改」「只改 xxx.html」等）后，再对约定范围内的文件执行规则对齐式改造；用户拒绝或未回复时，跳过改造，继续或结束初始化

未检测到已有 HTML 时，本小节不适用；由本技能**新生成**的 HTML 仍应在写入时直接符合 `references/rules.md`，无需再走本步。

### 第六步：输出初始化报告

完成所有步骤后，输出简要报告：

```text
✅ HTML 原型项目初始化完成

已创建/更新：
  - [CLAUDE.md] 规则已写入
  - [.cursor/rules/zacc-prd-init-html.mdc] Cursor 规则已写入
  - [prototype/] 原型根目录已创建

下一步：
  - 将 PRD 文件放入 prd/ 目录
  - 使用 /zacc-prd-init-html prd/xxx.md 生成原型
```

如果所有内容均已存在且一致，输出：

```text
✅ HTML 原型项目已就位，无需重复初始化
```

---

## 能力二：根据 PRD/md 文件生成原型

当用户指定一个 md 文件时，按以下流程执行。

### 第一步：确保项目已初始化

快速检测 `CLAUDE.md` 和 `prototype/` 是否就位。如果未初始化，先自动执行"能力一"的初始化流程，再继续。

### 第二步：读取并解析 PRD 文件

1. 读取用户指定的 md 文件
2. 从中提取以下信息：
   - 页面类型或业务场景
   - 主要业务目标
   - 关键模块及其边界
   - 关键交互（表单提交、弹窗、状态切换、筛选等）
   - 是否存在弹窗、抽屉、表单、列表、导航、标签栏
3. 如果 PRD 信息不完整，不中断，基于常见产品习惯做合理假设，在末尾列出关键假设

### 第三步：确定输出目录并设计原型结构

1. 根据 PRD 文件名生成目录名 `prd-slug`（英文 kebab-case）：
   - 去掉扩展名 `.md`
   - 去掉常见后缀（如 `_PRD`、`-PRD`、`PRD`）
   - 中文可转拼音或语义英文；无法稳定转换时使用 `prd-YYYYMMDD-<short-hash>` 兜底
2. 本次输出目录固定为：`prototype/<prd-slug>/`
3. 所有生成文件（含 `index.html`）都写入该目录，不得写到 `prototype/` 根目录
4. 判断需要生成哪些 HTML 文件（是否需要拆分）
5. 输出目录结构树，例如：
   ```text
   prototype/ai-claim-case-management/
   ├── index.html
   ├── case-header.html
   ├── case-list.html
   └── case-detail-dialog.html
   ```
6. 等待用户确认结构，或直接继续（如果用户已在命令中明确要求）

### 第四步：生成 HTML 文件

生成前先执行覆盖检查：
- 扫描 `prototype/<prd-slug>/` 目标文件是否已存在
- 若存在同名文件，必须先询问用户是否覆盖；未确认前不得写入
- 获得确认后执行覆盖写入，禁止在同一文件中做拼接追加

按 `references/rules.md` 中定义的规则生成所有 HTML 文件。必须严格遵守：

- **Structural Metadata**：关键节点带 `data-role` 和 `data-name`
- **Zero Visual Noise**：禁止 SVG/base64/内联样式；图标优先 `data-icon="描述"` + 极简可见示意，兼容正文 `[ICON: 描述]`
- **Modular Chunking**：预计 >300 行或有多个独立模块时必须拆分
- **Chunk Annotation**：每个页面需显式标注模块注释，至少包含 `<!-- Module: ... -->` 1 处与 `<!-- Chunk: ... -->` 2 处
- **Semantic HTML**：优先语义标签，样式仅用基础 Tailwind
- **Business Logic in Comments**：关键交互处写业务目的注释

每个文件以 `<!-- File: path -->` 标注文件路径（路径应为 `prototype/<prd-slug>/...`）。

### 第五步：构建多文件联动

多个 HTML 文件不能是孤立的，必须让它们形成一个可导航、可联动的整体。采用 **JS 动态加载** 方式驱动页面切换，模拟单页应用体验。

#### 联动架构：index.html 作为 SPA 容器

`index.html` 是整个原型的**导航中枢和 SPA 容器**，结构如下：

1. **导航栏**：列出所有子模块，点击时切换视图
2. **内容容器** `<div id="app">`：所有子模块内容在此渲染
3. **路由脚本**：内联一段轻量 JS，负责 fetch 子模块 HTML 并注入到 `#app`

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

  <!-- 导航栏 -->
  <header data-role="navbar" data-name="main-nav" class="flex items-center justify-between p-4 border-b">
    <a href="#" onclick="navigate('case-list')" class="font-medium">业务名称</a>
    <button type="button" data-icon="更多" class="inline-flex h-9 w-9 items-center justify-center rounded-lg border text-gray-600" aria-label="更多">⋯</button>
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

#### 子模块 HTML 文件规范

每个子模块 HTML 文件必须：

1. **独立可运行**：包含完整的 `<!DOCTYPE html>`、`<head>`（含 Tailwind CDN）、`<body>`，可单独打开预览
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

#### 联动流程示例

```text
用户在 index.html 看到导航：[案件列表] [案件详情]
  → 默认加载 case-list.html → #app 渲染案件列表
  → 点击某条案件 → navigate('case-detail') → #app 渲染 case-detail.html
  → 点击导航栏「案件列表」→ navigate('case-list') → #app 切换回列表
  → 子模块也可单独打开 case-list.html 独立预览
```

#### 为什么用 JS 而非 iframe/纯链接

- **iframe**：体验割裂、高度自适应差、跨域受限
- **纯链接**：每次跳转整页刷新，丢失导航上下文
- **JS 动态加载**：单页体验、导航常驻、切换流畅、子模块仍可独立预览

### 第六步：输出生成报告

```text
✅ 原型已生成

PRD 来源：prd/某需求_PRD.md
生成文件：
  - prototype/<prd-slug>/index.html（页面骨架）
  - prototype/<prd-slug>/xxx.html（模块说明）
  - prototype/<prd-slug>/yyy.html（模块说明）

关键假设：
  - 假设1
  - 假设2

自检结果：
  ✅ 目录结构树已输出
  ✅ data-role/data-name 已标注
  ✅ 无 SVG/base64/内联样式
  ✅ 图标位已用 data-icon（或兼容 [ICON:]）表达语义
  ✅ 语义化 HTML
  ✅ 业务注释已添加
  ✅ 文件已按业务结构拆分
  ✅ index.html 包含模块导航
  ✅ 子模块独立可运行且含回导航
  ✅ 跨模块交互已通过 navigate() 联动
  ✅ 覆盖检查已执行（如有同名文件已先确认）
  ✅ Module/Chunk 注释已完整标注
```

---

## 注意事项

- **已有 HTML 与规则对齐**：初始化时若 `prototype/` 下已有 `.html` 文件，必须先询问用户是否**按本技能规则改造**，**不得**默认直接改写；此条指结构化规则对齐，**不是** Prettier 等排版工具
- 幂等性：多次执行初始化不会覆盖已有内容，仅补充缺失部分
- Cursor .mdc 规则正文不得弱于 CLAUDE.md 中的内容
- 不修改用户其他配置文件的内容
- 如果项目已有 `prototype/` 目录且包含文件，初始化时不覆盖已有文件
- 生成原型时，仅覆盖当前 `prototype/<prd-slug>/` 内文件；同名文件已存在需提示用户确认是否覆盖
- 写入策略必须是覆盖写入，不得将新旧 HTML 拼接在同一文件中
- 生成规则以 `references/rules.md` 为准，确保与写入 CLAUDE.md / .mdc 的规则一致
