# 项目术语表

> 从模块名、类名、核心方法名提取的领域术语。

| 术语 | 定义 | 对应代码实体 | 所属模块 |
|------|------|------------|---------|
| NF | New Feature，新功能文档，用于规范驱动开发 | `docs/features/NF-XXX-*.md` | NF System |
| Team | Claude Code 原生团队机制，用于多 Agent 协作 | `TeamCreate` | Task Scheduler |
| Task | 任务单元，支持依赖关系和状态管理 | `TaskCreate` | Task Scheduler |
| Agent | 独立执行任务的 AI 实体 | `Agent` | Task Scheduler |
| Legacy Constraints | 历史包袱约束，记录代码中的技术债务 | `.wiki/nodes/*.md` | zacc-wiki-fronted |
| Wiki Node | 知识图谱节点，描述一个模块的结构和依赖 | `.wiki/nodes/*.md` | zacc-wiki-fronted |
| Design Token | 设计令牌，颜色、字号、圆角等设计变量的统称 | `--color-brand-orange` | ZA Design System |
| Glassmorphism | 毛玻璃风格，使用 backdrop-filter 实现的视觉效果 | `backdrop-filter: blur()` | ZA Design System |
| 投保前链路 | 用户未购买保险前的流程，使用橙色主题 | `#FF5E13` | ZA Design System |
| 投保后链路 | 用户已购买保险后的流程，使用绿色主题 | `#0ED398` | ZA Design System |
| Frontmatter | Markdown 文件顶部的 YAML 元数据块 | `---\nname: xxx\n---` | 全局 |
| SKILL.md | 技能定义文件，包含技能的元数据和使用说明 | `.claude/skills/*/SKILL.md` | 全局 |
| Slash Command | 斜杠命令，通过 `/xxx` 触发的快捷入口 | `.claude/commands/*.md` | Slash Commands |
| 优先级队列 | 按优先级排序任务并调度的算法 | High>Medium>Low | Task Scheduler |
| 循环依赖 | 模块间相互依赖形成的环，需要避免 | - | zacc-wiki-fronted |
