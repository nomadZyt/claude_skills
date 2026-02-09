---
name: utility-style-localizer
description: 将粘贴进项目的 Vue/HTML 模板中的工具类（如 cm-*、flex-*、clr-*、relative 等）迁移为就地样式（组件/页面自己的 scss/css），保持视觉不变且不修改业务逻辑。若项目使用 rem，则优先使用项目已有的 px→rem 换算函数（如 pxToRem）；若找不到换算函数则基于项目 root font-size 规则手动换算并在代码里备注计算依据。适用于用户提出“去掉工具类/重新定义 class/样式本地化/把工具类写进标签类名/复制粘贴的样式改成项目写法”等需求。
---

# Utility Style Localizer（工具类样式本地化）

## 适用场景（触发词）

- 用户说：**使用 utility-style-localizer“去掉工具类 / 不要 cm-_ / 不要 flex-_ / 重新定义 class / 保持样式不变”**

## 硬性约束

- **不修改业务逻辑**：不动 `methods/computed/watch` 等 JS 逻辑；仅改 `template/class` 与对应样式文件。
- **最小改动**：只改用户指定的片段/文件，不做全局替换，不重构无关结构。
- **视觉不变**：布局、间距、字体、定位、交互态保持一致。
- **单位体系必须先确认**：先确认项目使用 rem 还是 px（不要默认）。

## 必须先确认的“真实来源”（跨项目通用）

### 1) 项目是用 rem 还是 px

- **判断信号（满足其一即可）**：
  - 样式里大量出现 `rem`（而不是清一色 `px`）
  - 存在 px→rem 换算函数（如 `pxToRem` / `px2rem` / `pxtorem` / `px-to-rem`）
  - 存在 root font-size 适配逻辑（CSS 媒体查询设置 `html{font-size:...}` 或 JS flexible 方案）
- **如果判断为 px 项目**：
  - 本 Skill 仍可用，但**不要强制转换为 rem**；仅做“去工具类 + 样式搬家本地化”。

### 2) 项目真实工具类/通用样式定义在哪

- 不要假设固定路径。先探测项目里的通用样式文件（常见目录/文件名见 [reference.md](reference.md)）。
- 以项目内真实定义为准；用户粘贴的工具类实现只作为对照，不可直接假设已生效。

### 3) px→rem 换算口径（仅当项目确认使用 rem 时）

- **优先使用项目已有函数**（例如 `pxToRem($px)`）。
- 如果当前样式文件无法直接使用该函数：
  - 先确认项目是否有“全局注入 scss 资源”的构建配置（例如 `sass-resources-loader`）
  - 若没有，才在当前样式文件顶部显式引入对应变量/函数文件（以项目真实路径为准）
- **如果项目里找不到任何换算函数**：
  - 根据项目 root font-size 规则手动换算（\(rem = px / rootFontSize\)）
  - 对手动换算的结果在代码里加备注，说明 rootFontSize 的取值依据与换算过程（见示例文件）

### 4) 样式“方法/函数”（如 `xxx(...)`）的匹配与替换规则

> 目标：避免把“其他项目/粘贴代码”里的样式函数原封不动带进来，导致本项目不生效或口径不一致。

- **先区分类型**
  - **标准 CSS 函数**（如 `calc()` / `rgba()` / `url()` / `var()` / `linear-gradient()` 等）：通常不需要处理。
  - **预处理器/项目自定义函数**（常见形态：`px-to-rem()`、`px2rem()`、`pxtorem()`、`rem()` 等）：必须按本规则处理。
- **处理流程（最小改动范围内执行）**
  1. **识别函数名**：从样式中提取 `xxx(...)` 的 `xxx`，记录出现位置（仅限本次改动文件/片段）。
  2. **在项目里查“同能力”实现**：
     - 搜索 `@function xxx`（SCSS）或项目统一注入的 scss 资源文件（如 `sass-resources-loader` 的 resources）。
     - 若存在“同能力但不同名”的函数（例如本项目统一为 `pxToRem()`），以项目真实定义为准。
  3. **匹配到则替换为项目标准写法**：
     - 示例：`px-to-rem(4)` → `pxToRem(4)`（前提：项目存在 `pxToRem` 且可用）。
  4. **匹配不到则必须备注说明**（不要默默保留/默默假设）：
     - 在就近处加注释（`// NOTE:` 或 `/* NOTE: ... */`），说明：
       - “未在项目内找到该函数/插件的定义，当前写法可能无效或口径不一致”
       - 推荐替代方案（按项目规范）：改用项目已有函数（若有），否则按 root font-size 手动换算并注明依据
     - 备注示例（SCSS）：
       - `// NOTE: 未在项目内找到 px-to-rem() 定义；请改用 pxToRem() 或按 root font-size 手动换算。`

## 工作流（通用步骤）

### Step 0：锁定改动范围 + 单位体系

- 明确“只改哪些标签/哪些行/哪个组件”，避免误改其他页面。
- 明确“该项目用 rem 还是 px”，避免错误换算。

### Step 1：列出要移除的工具类清单

从目标模板片段（Vue template / HTML）中整理所有工具类，例如：

- **排版/间距**：`cm-fs-*`、`cm-lh-*`、`cm-fw-*`、`cm-pd-*`、`cm-mg-*`
- **布局**：`flex-*`、`cm-flex-*`、`space-between`、`justify-*`、`align-*`
- **颜色**：`clr-*`、`cm-clr-*`、`bgc-*`、`cm-bgc-*`
- **定位/溢出**：`relative`、`absolute`、`cm-ofw-h`、`cm-ofw-x-h`

### Step 2：对每个工具类做“等价 CSS 映射”

原则：

- **先查项目真实定义**（全局样式文件），拿到最终 CSS 属性集合
- 再把属性集合迁移到“本地业务类 / 新增极少量 BEM 类”

常见映射提示：

- `relative` 往往是 **伪元素/绝对定位参照物**，移除后会导致 `::after`、`position:absolute` 错位
- `z-index` 若要生效，通常需要配合 `position`（relative/absolute/fixed）
- `flex` 等分常见是 `flex: 1; width: 0;`（移除会导致格子宽度不等/溢出）

### Step 3：修改模板（只动 class，不动结构/逻辑）

- 删除工具类，保留业务类（如 `.plateno-content/.item`）
- 如果业务类不足以承载样式：新增**极少量**语义类（BEM 推荐），例如 `component__title`

### Step 4：把工具类样式“搬家”到本地样式文件

写法要求：

- **若项目使用 rem 且存在换算函数**：优先写成 `pxToRem(数字)`（或项目约定的函数名）。
  - 示例：`padding-top: pxToRem(24);`、`font-size: pxToRem(22);`
- **若从旧代码/粘贴代码里出现非本项目的样式函数**（如 `px-to-rem()` / `px2rem()`）：优先按“4) 样式方法/函数”的规则匹配并替换为项目标准函数；匹配不到必须加备注。
- **若项目使用 rem 但没有换算函数**：直接写换算后的 rem，并对关键换算加备注说明依据（不要默算）。
  - 示例：`padding-top: 1.5rem; // 24px / 16 = 1.5rem（rootFontSize=16，依据：xxx）`
- 不要引导使用不存在于目标项目的函数名（例如把 `pxToRem` 写死到所有项目）。
- 尽量把新增样式放在组件根类下面，避免全局污染

### Step 5：轻量自检

- 只对改动文件跑 lint（或用 IDE 的诊断）
- 如项目在运行，确认样式编译无报错

## 常见坑位清单（必须过一遍）

- **定位依赖**：移除 `relative` 后，`::after`/绝对定位元素是否还以正确容器为参照？
- **等分布局**：移除 `flex-*` 后，是否补回了 `display:flex`、`justify-content`、`align-items`、`flex:1;width:0`？
- **溢出裁切**：移除 `cm-ofw-h` 后，是否补回 `overflow: hidden`？
- **字体与行高**：`cm-fs-* / cm-lh-* / cm-fw-*` 是否等价迁移？
- **颜色**：`clr-*` 是否等价迁移（注意项目里 `clr-*` 可能并不存在，优先用 `color: #333` 等直写或变量）？

## 例子与参考

- 常见改造示例见 [examples.md](examples.md)
- 常见工具类类别与排查要点见 [reference.md](reference.md)
