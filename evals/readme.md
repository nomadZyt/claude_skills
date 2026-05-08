# 🤖 AI Agent Skill Evaluation Framework (AI 技能评估框架)

一个轻量级、可扩展的命令行评估框架，专为 Claude Code 等 AI Agent 设计。
用于将基于 Prompt 的“玄学调优”转化为**可量化、可测试、防退化**的工程实践。

## ✨ 核心特性

- **🚀 独立沙盒执行**：每次运行前自动清理靶场空间，确保测试环境纯粹无污染。
- **🛡️ 双层评估体系**：
  - **客观断言 (Deterministic Checks)**：通过 Node.js 脚本物理校验文件生成、构建编译等硬指标。
  - **主观裁判 (LLM-as-a-Judge)**：调用 Claude 根据专属规则进行 Code Review，输出结构化打分。
- **🧩 强扩展性架构**：指令、断言脚本、打分规则按技能（Skill）完全解耦，新增技能无需修改核心流转逻辑。
- **📊 结构化数据输出**：利用 JSON Schema 强制规范裁判模型的输出，轻松接入 CI/CD 或生成可视化报告。

## 📁 目录结构

```text
your-project/
├── evals/
│   ├── skills/                       # 技能配置存放区
│   │   ├── setup-demo-app.md         # [必选] Agent 执行的具体 Prompt
│   │   ├── setup-demo-app.judge.txt  # [必选] 裁判模型打分的专属标准
│   │   └── setup-demo-app.assert.js  # [可选] 客观断言脚本 (Node.js)
│   ├── schemas/
│   │   └── style-rubric.json         # 通用的裁判打分 JSON Schema 骨架
│   ├── artifacts/                    # 测试运行结果存放区 (自动生成)
│   │   └── *_score.json              # 最终的评审成绩单
│   └── run-eval.sh                   # 测试运行器核心脚本
```

## 🛠️ 前置依赖
Node.js: 用于执行客观断言脚本（建议 v18+）。

Claude Code CLI: 确保你已在全局环境中配置好了 claude 命令行工具并完成鉴权。

## 🚀 快速开始
### 1. 赋予执行权限
首次克隆仓库后，确保运行脚本具有可执行权限：

```Bash
chmod +x ./evals/run-eval.sh
```
### 2. 运行单项测试
指定要测试的技能名称（不需要带文件后缀），框架会自动拼装环境并运行闭环：

```Bash
./evals/run-eval.sh setup-demo-app
运行结束后，你可以在终端看到测试日志，或前往 evals/artifacts/setup-demo-app_score.json 查看详细的评审成绩单。
```

## ✍️ 如何接入一个新的 Skill？
假设你要为一个新的技能 refactor-vue 添加自动化评估，只需完成以下 3 步：

### Step 1: 编写核心 Prompt
在 evals/skills/ 目录下创建 refactor-vue.md，写清楚任务背景、要求和 完成标准 (Definition of Done)。

### Step 2: 编写专属裁判规则
创建 refactor-vue.judge.txt，用清晰的语言告诉裁判需要重点检查什么。例如：

```Plaintext
请根据以下标准评估：
1. vue_composition_api: 是否将 Options API 完美重构为了 Setup 语法糖？
2. css_vars: 是否移除了硬编码的颜色，替换为了系统统一的 CSS 变量？
```

### Step 3: (可选) 编写客观断言
创建 refactor-vue.assert.js，写一点 Node.js 代码来确保基础功能没挂。

```JavaScript
// evals/skills/refactor-vue.assert.js
const fs = require('fs');
if (!fs.existsSync('./.test-workspace/src/App.vue')) {
    console.error("❌ 核心组件未生成");
    process.exit(1);
}
```
完成以上步骤后，运行 ./evals/run-eval.sh refactor-vue 即可开始你的自动化评估闭环！

## 💡 设计哲学 (The Philosophy)
"You can't improve what you don't measure." (无法度量，就无法改进)

在 AI 辅助开发时代，Prompt 极易发生“按下葫芦起了瓢”的退化。本框架旨在通过固化的评审量表（Rubric）和严格的 JSON 模式（Schema），将每一次 Prompt 优化具象化为分数的提升，为 AI 开发流程引入现代软件工程的严谨性。

Generated for the AI-Assisted Development Workflow.
