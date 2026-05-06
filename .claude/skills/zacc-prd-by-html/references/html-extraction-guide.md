# HTML 原型信息提取方法

> 供 zacc-prd-by-html 步骤 3 使用，定义从 HTML/CSS/JS 中提取产品信息的具体方法。

## 1. 产品概述提取

| 信息 | 提取来源 | 提取方法 |
|------|----------|----------|
| 产品名称 | `<title>`、`<h1>`、logo 图片 alt | Read 文件后正则匹配 |
| Slogan | hero 区域副标题、meta description | 搜索含 slogan/副标题 语义的文本 |
| 目标用户 | 页面文案中的用户称呼、角色标签 | Grep 搜索用户角色关键词 |
| 产品定位 | 整体页面功能组合推断 | 综合所有模块的职责归纳 |

## 2. 用户流程提取

**从导航和链接提取页面关系**：

```
Grep 匹配模式：
- <a href="..."> → 页面跳转
- <router-link to="..."> → SPA 路由
- window.location / router.push → JS 跳转
- <form action="..."> → 表单提交目标
```

**从按钮和操作提取交互节点**：

```
Grep 匹配模式：
- <button / @click / onclick → 操作触发点
- <form / @submit → 表单提交
- <input type="submit"> → 提交操作
```

**从步骤组件提取决策路径**：

```
特征识别：
- .step / .wizard / .progress → 步骤导航
- tab/accordion → 并行选择
- modal/drawer → 临时交互
```

## 3. 信息架构提取

**从 DOM 层级提取模块结构**：

- 顶级 `<section>` / `<div class="module-*">` → 一级模块
- 嵌套的卡片/列表/表格 → 二级模块
- 导航栏 `<nav>` → 导航体系

**从 CSS class 命名推断模块语义**：

```
常见模式：
- .header / .footer / .sidebar → 布局模块
- .card-* / .item-* → 内容单元
- .form-* / .input-* → 表单模块
- .list-* / .table-* → 数据展示
- .modal-* / .dialog-* → 弹窗
```

**从标题层级提取内容组织**：

- `<h1>` → 页面主标题
- `<h2>` → 模块标题
- `<h3>` → 子模块标题

## 4. 功能需求提取

**从表单提取输入/输出**：

```
Grep 匹配：
- <input / <select / <textarea → 输入字段
- name / placeholder / label → 字段语义
- required / pattern / maxlength → 校验规则
- type="email" / type="tel" → 格式约束
```

**从按钮和操作提取功能点**：

```
每个操作按钮 → 一个功能需求：
- 按钮文本 → 功能名称
- 所在表单 → 功能上下文
- @click / action → 触发逻辑
```

**从列表和表格提取数据需求**：

```
<table> / <li> / .list-item → 数据结构：
- 表头 → 字段名称
- 行数据 → 数据样本
- 分页组件 → 分页需求
- 筛选/搜索 → 查询条件
```

## 5. 交互设计规范提取

**从 CSS 提取设计规范**：

```
色彩系统：
- 搜索 CSS 变量：--color-* / --primary / --bg-* / --text-*
- 搜索 color 属性值：hex / rgb / hsl
- 统计高频色值 → 主色/辅助色/语义色

字体规范：
- 搜索 font-family / font-size / font-weight
- 统计字号层级 → 字号阶梯

圆角与阴影：
- 搜索 border-radius / box-shadow
- 统计取值 → 圆角/阴影系统

间距系统：
- 搜索 margin / padding / gap
- 统计取值 → 间距阶梯
```

**从 JS 提取动画和交互**：

```
Grep 匹配：
- transition / animation / @keyframes → 动画效果
- transform / opacity → 过渡效果
- setTimeout / setInterval → 定时交互
- addEventListener → 事件绑定
```

## 6. 数据需求提取

**从表单和 API 调用推断数据结构**：

```
Grep 匹配：
- fetch / axios / $.ajax → API 调用
- .then / await → 响应处理
- localStorage / sessionStorage → 本地存储
- data-* 属性 → 数据绑定
```

**从列表渲染推断数据模型**：

```
Grep 匹配：
- v-for / map( / .forEach → 列表渲染
- :key / key= → 数据标识
- item.*. → 数据字段
```

## 提取结果格式

每个维度的提取结果统一输出为：

```markdown
### [维度名称]

**提取来源**：[文件路径:行号范围]

**提取结果**：

| 原型元素 | 提取信息 | 置信度 |
|----------|----------|--------|
| ... | ... | 高/中/低 |

**待确认项**：[置信度为中/低的、原型中未体现的内容]
```
