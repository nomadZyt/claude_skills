## 项目内关键参考

本 Skill **不只服务于当前项目**。以下路径仅作为“常见示例”，使用时必须先在目标项目中探测真实位置。

### 先探测：项目有哪些通用样式定义文件
- 常见目录：
  - `src/styles/`、`src/stylesheets/`、`src/assets/styles/`、`src/assets/scss/`、`src/css/`
  - `styles/`、`assets/styles/`
- 常见文件名：
  - `common.scss` / `common.css`
  - `reset.scss` / `reset.css`
  - `variables.scss` / `var.scss`
  - `mixins.scss`
  - `utils.scss` / `utility.scss` / `helpers.scss`

### 示例（本仓库）
- **工具类来源之一**：`src/stylesheets/common.scss`
  - 常见：`cm-fs-*`、`cm-lh-*`、`cm-fw-*`、`cm-pd-*`、`cm-mg-*`、`cm-txt-*`、`flex-center`、`cm-ofw-h` 等
- **rem 换算函数示例**：`src/stylesheets/variables.scss`
  - `pxToRem($px)` 是该仓库的统一换算口径（其他项目不一定叫这个名）

## 常见工具类类别 → 迁移策略

### 1) 字体/排版
- `cm-fs-N` → `font-size: pxToRem(N)`
- `cm-lh-N` → `line-height: pxToRem(N)`
- `cm-fw-600` → `font-weight: 600`
- `cm-txt-c` → `text-align: center`

说明：
- 这里的 **N 是数字（Number）**，通常表示“像素值/设计稿尺寸”，不是 “Normal”。

### 2) 间距（padding/margin）
- `cm-pd-t-N` → `padding-top: pxToRem(N)`
- `cm-pd-lr-N` → `padding-left/right: pxToRem(N)`
- `cm-pd-tb-N` → `padding-top/bottom: pxToRem(N)`
- `cm-mg-b-N` → `margin-bottom: pxToRem(N)`

### 3) Flex 布局
- `flex-center` 通常等价：`display:flex; justify-content:center; align-items:center`
- “等分格子”常见写法（替代 `flex-width-auto` 之类）：
  - `flex: 1; width: 0;`（必要时加 `min-width: 0;` 防止溢出）

### 4) 定位/伪元素依赖
强制检查：
- 如果某元素有 `::after` 且内部用 `position: absolute`，它的父容器通常需要 `position: relative`
- `z-index` 若发现不生效，优先补 `position: relative`

### 5) 溢出/省略/裁切
- `cm-ofw-h` → `overflow: hidden`
- `cm-txt-eps`（如存在）→ `overflow:hidden; white-space:nowrap; text-overflow:ellipsis`

### 6) 颜色类（clr-*）
- 先确认项目是否真的存在 `.clr-xxx`（有些项目仅有 `.cm-clr-*`）
- 若不存在，建议直接写 `color: #333` 或使用项目变量（若有）

## 用户粘贴的工具类片段（可选输入）
有些场景用户会在对话里粘贴一段“工具类枚举/实现”（例如你之前粘贴的 reset + spacing + flex + colors 的部分）。此时：
- 先把它当作 **对照清单**（帮助列出有哪些工具类与预期效果）
- 再回到目标项目里确认“最终生效的真实定义”（避免函数名/换算口径不一致）
- 如果目标项目不存在对应定义：才在本地样式中自行实现等价效果

### 可复制粘贴模板（把你的工具类/枚举贴到这里）
把下面区块复制到对话里（或贴到临时文档），然后把你项目/设计稿里出现的工具类逐段补齐。Agent 会以此作为“对照清单”，并结合目标项目真实定义完成样式本地化。

```scss
/* ==============================
 * UtilityStyles_SnippetTemplate
 * 用途：粘贴/枚举工具类与预期效果（对照清单）
 * 注意：最终以目标项目真实定义为准
 * ============================== */

/* [A] 单位体系（先确认项目用 rem 还是 px）
 *
 * - 若 rem：补充 root font-size 口径（CSS 媒体查询 / flexible / 固定 16px 等）
 * - 若 px：直接写 px，不要强制换 rem
 */
// unitSystem: rem | px
// rootFontSizePx: 16 // 示例：若 rem 且 rootFontSize=16px，则 1rem=16px

/* [B] px→rem 换算（若项目没有函数名，这里说明换算口径）
 *
 * - 若项目已有函数：写出函数名与所在文件路径（如果你知道）
 * - 若没有：写清楚换算公式 rem = px / rootFontSizePx
 */
// pxToRemFnName: pxToRem
// pxToRemFnFile: src/stylesheets/variables.scss
// manualFormula: rem = px / rootFontSizePx

/* [C] 字体/行高/字重/对齐
 * 例：
 * - cm-fs-20: font-size: 20px
 * - cm-lh-28: line-height: 28px
 * - cm-fw-600: font-weight: 600
 * - cm-txt-c: text-align: center
 */
// typographyUtilities:
//   - class: cm-fs-20
//     css: font-size: 20px
//   - class: cm-lh-28
//     css: line-height: 28px

/* [D] 颜色（注意：有些项目是 clr-333，有些是 cm-clr-black 等）
 * 例：
 * - clr-333: color: #333
 * - cm-bgc-white: background-color: #fff
 */
// colorUtilities:
//   - class: clr-333
//     css: color: #333

/* [E] 盒模型（padding/margin/width/height/border/radius）
 * 例：
 * - cm-pd-t-24: padding-top: 24px
 * - cm-pd-lr-10: padding-left/right: 10px
 * - cm-mg-b-20: margin-bottom: 20px
 */
// spacingUtilities:
//   - class: cm-pd-t-24
//     css: padding-top: 24px

/* [F] 布局（flex/居中/等分）
 * 例：
 * - flex-center: display:flex; justify-content:center; align-items:center
 * - flex-width-auto: flex:1; width:0
 */
// layoutUtilities:
//   - class: flex-center
//     css: display:flex; justify-content:center; align-items:center

/* [G] 定位/层级/溢出（position/z-index/overflow）
 * 例：
 * - relative: position: relative
 * - absolute: position: absolute
 * - cm-ofw-h: overflow:hidden
 */
// miscUtilities:
//   - class: relative
//     css: position: relative

/* [H] 目标片段（可选）
 * 把你要改的 template/html 片段贴在这里，便于快速建立“工具类→本地类名”映射
 */
// targetSnippet:
// <div class="cm-pd-t-24 flex-center">
//   <div class="cm-fs-20 cm-fw-600 clr-333">标题</div>
// </div>
```

## 建议的操作顺序（避免返工）
1. 先把模板里的工具类**列清单**（不要直接删）
2. 在项目里找到每个工具类的真实定义，确认最终 CSS
3. 再删模板工具类，同时把等价样式写到本地类名里
4. 最后只做轻量自检（lint/编译），不要大范围全局替换

