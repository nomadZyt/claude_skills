# 众安车险周报生成器 (Weekly Report Generator)

## Description
根据用户提供的周报数据（对话输入或文件），自动生成符合众安车险品牌风格的 HTML 周报页面。基于固定 HTML 模板，填充实际数据后输出到 `output/` 目录。

## Trigger
- 命令: `/weekly-report`
- 自然语言触发: 当用户说"生成周报"、"帮我生成一个周报"、"根据上面内容生成周报"、"做一个周报"、"出周报"等包含"周报"关键词的请求时触发
- 当用户提供了一组周报相关数据并要求生成 HTML 时触发

---

## 工作流程

### Step 1: 获取数据

从以下来源之一获取周报数据：

**方式 A — 对话输入：** 用户在对话中直接提供数据（文字、表格、截图等）
**方式 B — 文件读取：** 用户指定文件路径（支持 Markdown / JSON / TXT / CSV）

**关键信息缺失处理：** 如果用户提供的数据中缺少以下必要字段，**必须主动询问用户补充**，不要自行猜测或使用默认值：

#### 必须字段（缺失时必须询问）
- `date_range` — 周报日期范围（如 "4.3-4.9"）
- `core_metrics` — 至少一个核心数据指标（如留资用户数、签单保费）

#### 建议字段（缺失时提醒用户是否需要补充）
- 品牌曝光数据（小红书/抖音等平台数据）
- 投放转化数据
- 下周计划

#### 可选字段（缺失时静默跳过）
- 累计数据
- 投放素材分类
- 达人筛选等自定义模块
- 页脚文字（默认: "众安车险品牌组 · 每周更新"）
- 报告标题（默认: "众安车险·本周数据战报"）

### Step 2: 解析数据

从用户输入中提取以下字段：

```yaml
# 基础信息
report_title: "众安车险·本周数据战报"     # 标题，可自定义
date_range: "2026.03.27 - 04.02"          # [必须] 日期范围
footer_text: "众安车险品牌组 · 每周更新"    # 页脚文字

# 核心数据卡片 [必须至少1个]
core_metrics:
  - label: "留资/加V用户"
    value: "3,096"
    style: "highlight"     # highlight=蓝色 | accent=绿色 | warn=橙色
  - label: "签单保费"
    value: "25.8万"
    style: "accent"

# 累计数据（可选）
cumulative:
  text: "3月累计 · 留资 13,898 人 · 保费 65.2万"

# 品牌曝光模块（建议提供）
brand_exposure:
  - platform: "小红书"
    icon: "📕"
    details:
      - "发布 20篇 · 阅读 21,948 · 互动 193"
  - platform: "抖音"
    icon: "🎬"
    details:
      - "投放曝光 154.2万 · CPM 44元"
      - "直播间165.5万 · 账号内容4.39万"

# 投放素材模块（可选）
materials:
  total: 16
  categories:
    - { label: "实拍", count: 4 }
    - { label: "高光", count: 2 }
    - { label: "数字人", count: 5 }
    - { label: "制作", count: 5 }
  note: "车英俊AI视频初有成效"

# 投放转化模块（建议提供）
conversion:
  - platform: "小红书"
    icon: "📕"
    metrics:
      - { label: "点击率", value: "7%", style: "highlight" }
      - { label: "种草人群", value: "8,461", style: "highlight" }
  - platform: "抖音"
    icon: "🎬"
    metrics:
      - { label: "+V", value: "3,392", style: "highlight" }
      - { label: "ROI", value: "3.08", style: "accent" }

# 自定义卡片（可选，支持多个）
custom_sections:
  - title: "📌 达人筛选"
    title_style: "highlight"  # 标题颜色: highlight | accent | warn | default
    items:
      - "✓ 剧情类/真实车主/人设类"
      - "✓ 上海/浙江地域"

# 下周计划（建议提供）
next_week:
  - "继续自然流开播"
  - "增加直播预算投放"
  - "筛选特斯拉/理想等家用车真实车主达人"
```

### Step 3: 生成 HTML

1. 读取模板文件 `templates/weekly-report-template.html`
2. 根据解析到的数据，**动态生成各个模块的 HTML 内容**
3. 遵循以下规则：
   - 保持模板的整体结构和视觉风格（Tailwind CSS + 内联样式）
   - 颜色标记：`highlight` = `#3b82f6`（蓝色），`accent` = `#10b981`（绿色），`warn` = `#f97316`（橙色）
   - 如果某个模块数据缺失且为可选，则跳过该模块不生成对应卡片
   - 如果用户提供了模板中没有的额外模块，使用 `custom_sections` 格式生成新卡片
   - 核心数据卡片支持 2-4 个指标，自动调整 grid 布局

### Step 4: 输出文件

1. 文件名格式：`weekly-report-{YYYY-MM-DD}.html`，日期取报告日期范围的结束日期
2. 输出路径：项目根目录下的 `output/` 目录
3. 输出完成后告知用户文件路径
4. 在浏览器中打开预览（如果有 Chrome DevTools MCP 可用）

---

## 模板说明

模板位于 `templates/weekly-report-template.html`，是一个完整的参考 HTML 文件。

**生成规则：**
- 不是简单的字符串替换，而是根据数据**动态构建 HTML 结构**
- 每个卡片（card）是一个独立模块，根据数据有无决定是否生成
- 保持 Tailwind CSS 类名和内联样式与模板一致
- `<title>` 标签内容根据 `report_title` 和 `date_range` 动态生成

**样式映射：**
```
.highlight → color: #3b82f6  （蓝色，用于关键数据）
.accent    → color: #10b981  （绿色，用于正向指标如保费、ROI）
.warn      → color: #f97316  （橙色，用于需关注的指标如成本）
```

---

## 示例

### 输入示例
```
帮我生成本周周报：
- 日期：4.3-4.9
- 留资用户 3500，签单保费 30万
- 3月累计留资 17000，保费 95万
- 小红书：发布25篇，阅读3万，互动250
- 抖音：投放曝光200万，CPM 40元，+V 4000，ROI 3.5
- 下周计划：加大抖音投放、优化小红书内容、测试新素材类型
```

### 输出
生成文件 `output/weekly-report-2026-04-09.html`，包含完整的 HTML 周报页面。
