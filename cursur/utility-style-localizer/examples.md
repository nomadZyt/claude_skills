## 示例 1：Vue 组件模板去工具类（以车牌输入为例）

### 输入（带工具类的 template 片段）
- 现象：`cm-*`（间距/字号/对齐）+ `flex-center`（flex 居中）+ `relative/flex-width-auto`（定位/等分）+ `cm-ofw-h`（overflow hidden）

### 处理
- **模板侧**：只删工具类，保留业务类；必要时新增 1 个标题类承接原工具类样式
- **样式侧**：
  - 先确认项目是否使用 rem（如果是 px 项目则不要强制 rem）
  - 若项目使用 rem 且有换算函数：确保 `pxToRem()` 可用（必要时引入对应变量文件；路径以项目为准）
  - 把以下能力迁移到业务类：
    - `display:flex; justify-content:center; align-items:center`
    - `padding-left/right: pxToRem(10)`、`margin-bottom: pxToRem(20)`、`font-size: pxToRem(22)`…
    - `.item { position: relative; flex: 1; width: 0; }`
    - `.val { position: relative; z-index: 2; }`
    - `.new { overflow: hidden; }`

### 关键检查点
- `::after` 光标闪烁伪元素是否仍以 `.item` 为参照（需要 `.item { position: relative; }`）
- 等分格子是否仍然成立（需要 `flex: 1; width: 0;`）

## 示例 2：纯 HTML 片段本地化工具类

### 输入
```html
<div class="cm-pd-t-24 cm-pd-lr-10 flex-center">
  <div class="cm-fs-20 cm-fw-600 clr-333">标题</div>
</div>
```

### 输出（示意）
```html
<div class="pageHeader">
  <div class="pageHeader__title">标题</div>
</div>
```

### 输出样式（示意）
```scss
// 若项目使用 rem 且存在换算函数，优先使用函数（路径以项目为准）
@import '@/stylesheets/variables.scss';

.pageHeader {
  padding-top: pxToRem(24);
  padding-left: pxToRem(10);
  padding-right: pxToRem(10);
  display: flex;
  justify-content: center;
  align-items: center;
}

.pageHeader__title {
  font-size: pxToRem(20);
  font-weight: 600;
  color: #333;
}
```

## 示例 2b：项目使用 rem，但找不到 px→rem 换算函数（手动换算 + 备注）

```scss
/* 假设 rootFontSize=16px（依据：项目中 html/body 的 font-size 规则），则 rem = px / 16 */

.pageHeader {
  padding-top: 1.5rem; // 24px / 16 = 1.5rem
  padding-left: 0.625rem; // 10px / 16 = 0.625rem
  padding-right: 0.625rem; // 10px / 16 = 0.625rem
  display: flex;
  justify-content: center;
  align-items: center;
}
```

## 示例 2c：项目使用 px（不做 rem 转换）

```css
.pageHeader {
  padding-top: 24px;
  padding-left: 10px;
  padding-right: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
}
```

## 示例 3：位置/层级依赖（position + z-index）

### 输入
```html
<div class="relative">
  <i class="relative val">A</i>
  <i class="absolute badge">hot</i>
</div>
```

### 要点
- 如果移除 `relative`，必须把 `position: relative` 写到承载容器上，否则 `.badge` 的绝对定位参照会变成更外层元素（错位）。
- `z-index` 要生效，通常需要 `position`（例如 `.val { position: relative; z-index: 2; }`）。

