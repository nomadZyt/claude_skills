# zacc-prd-init-html 使用指南

## 概述

`zacc-prd-init-html` 具备两项核心能力：
1. **项目初始化** — 创建 HTML 原型项目的目录结构、将规则写入 CLAUDE.md 和 Cursor 规则文件
2. **原型生成** — 读取 PRD/md 文件，按规则生成结构化 HTML 原型

## 适用场景

- 需要新建 HTML 原型项目的开发环境
- 已有 PRD 文档，需要快速生成可交互的 HTML 原型
- 团队需要统一的 HTML 原型规范

## 触发关键词

- 「初始化原型项目」「创建原型项目」「规则下沉」
- 「根据 PRD 生成原型」「根据需求生成页面」「把 PRD 转成 HTML」
- 直接指定一个 md 文件要求生成原型

## 使用方式

```bash
/zacc-prd-init-html                          # 仅执行项目初始化
/zacc-prd-init-html prd/某需求_PRD.md         # 初始化 + 根据该 PRD 生成原型
/zacc-prd-init-html prd/某需求_PRD.md --only  # 跳过初始化，仅根据 PRD 生成原型
```

## 能力一：项目初始化

### 初始化流程

| 步骤 | 说明 |
|------|------|
| 第一步 | 检测当前状态：CLAUDE.md、Cursor 规则文件、prototype/ 目录是否已存在 |
| 第二步 | 写入规则到 CLAUDE.md（追加 `zacc-prd-init-html` 规则小节） |
| 第三步 | 写入规则到 `.cursor/rules/zacc-prd-init-html.mdc`（Cursor 规则文件） |
| 第四步 | 创建 `prototype/` 目录结构 |
| 第五步 | 已有 HTML 与规则对齐（需用户确认，不自动改写） |
| 第六步 | 输出初始化报告 |

### 初始化产出

| 文件 | 位置 | 说明 |
|------|------|------|
| CLAUDE.md（规则小节） | 项目根目录 | HTML 原型规则 |
| zacc-prd-init-html.mdc | `.cursor/rules/` | Cursor 规则文件 |
| prototype/ | 项目根目录 | 原型根目录 |

## 能力二：根据 PRD 生成原型

### 生成流程

| 步骤 | 说明 |
|------|------|
| 第一步 | 确保项目已初始化（未初始化则自动执行能力一） |
| 第二步 | 读取并解析 PRD 文件，提取页面类型、模块、交互等信息 |
| 第三步 | 确定输出目录 `prototype/<prd-slug>/` 并设计原型结构 |
| 第四步 | 生成 HTML 文件（遵守结构化中间协议） |
| 第五步 | 构建多文件联动（JS 动态加载，模拟 SPA 体验） |
| 第六步 | 输出生成报告 |

### 原型文件结构

```
prototype/<prd-slug>/
├── index.html          # SPA 容器（导航中枢）
├── module-a.html       # 子模块（独立可运行）
├── module-b.html       # 子模块（独立可运行）
└── dialog-a.html       # 弹窗/抽屉
```

### 原型规范（结构化中间协议）

| 规则 | 说明 |
|------|------|
| Structural Metadata | 关键节点带 `data-role` 和 `data-name` |
| Zero Visual Noise | 禁止 SVG/base64/内联样式；图标用 `data-icon` 或 `[ICON:]` |
| Modular Chunking | >300 行或多独立模块时必须拆分 |
| Chunk Annotation | 每个 HTML 至少 1 处 `<!-- Module: ... -->` + 2 处 `<!-- Chunk: ... -->` |
| Semantic HTML | 优先语义标签，样式仅用基础 Tailwind |
| Business Logic in Comments | 关键交互处写业务目的注释 |

### 多文件联动机制

- `index.html` 作为 SPA 容器，通过内联 JS 路由脚本动态加载子模块
- 子模块使用 `navigate('module-name')` 实现跨模块跳转
- 每个子模块 HTML 独立可运行（含完整 DOCTYPE/head/body）
- 选择 JS 动态加载而非 iframe/纯链接，确保单页体验和导航常驻

## 注意事项

- 已有 HTML 文件不会被自动改写（需用户明确同意后才按规则对齐）
- 初始化具备幂等性：多次执行不会覆盖已有内容
- Cursor .mdc 规则正文不得弱于 CLAUDE.md 中的内容
- 同名文件已存在时需用户确认是否覆盖（覆盖写入，不拼接追加）

## 常见问题

**Q: 必须先初始化才能生成原型吗？**
A: 带 `--only` 参数可跳过初始化。如果不带参数且项目未初始化，会自动先执行初始化。

**Q: 生成的原型可以直接用于生产吗？**
A: 不可以。生成的是结构化中间协议原型，用于需求沟通和技术评审，非生产页面。

**Q: PRD 信息不完整怎么办？**
A: 不中断，基于常见产品习惯做合理假设，在生成报告末尾列出关键假设。
