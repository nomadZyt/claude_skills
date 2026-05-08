# zacc-requirement-spec Eval：需求文档生成引擎测试

## 背景

当前目录是一个模拟的前端项目（React + TypeScript 技术栈，含 Taro 小程序元素），你需要扮演 AI Agent，严格按照 `.claude/skills/zacc-requirement-spec/SKILL.md` 中定义的 **zacc-requirement-spec** 技能规范执行任务。

> ⚠️ **非交互模式豁免**：本 eval 在 `claude -p` 一次性非交互模式下运行，你无法使用 `AskUserQuestion` 真正阻塞等待用户、也无法通过 `ExitPlanMode` 真正获得用户批准。本测试的 DoD **只校验最终产物**，不校验 plan 模式流程。因此：
> - 允许你跳过 `EnterPlanMode` + `ExitPlanMode` 交互环节，直接按 SKILL [S5] 落盘
> - 允许将"本应通过 AskUserQuestion 追问的字段"写入文档「待补充信息 (TODO)」章节并标注 `unknown` 或 `TBD`
> - **不得**因为无法交互而**省略**任何机读区块（Meta / 上游产物摘要 / 六段式 / 全局约束 / 交付说明 / 待补充信息）

## 你的任务

### 阶段一：搭建模拟靶场（upstream artifacts）

在当前目录 `.test-workspace` 下创建最小化上游产物，结构如下：

```
.test-workspace/
├── CLAUDE.md                    # 模拟项目规范（技术栈 + 纠错记录章节）
├── .claude/
│   └── AI_RULES.md             # 模拟 AI 红线规则
├── wiki/
│   ├── index.md                # Wiki 拓扑索引
│   ├── index.json              # 机器索引（nodes[] + by_alias / by_path）
│   ├── glossary.md             # 术语表
│   └── nodes/
│       ├── page.voice-assistant.md   # 命中节点（用于追问降级）
│       └── component.bottom-sheet.md # 命中节点（含 Legacy Constraints）
└── docs/
    └── requirements/           # 产物输出目录（脚本创建或脚本内 mkdir -p）
```

**关键文件内容要求：**

1. `CLAUDE.md` 必须包含：
   - 技术栈表格（React 18 + TypeScript + Taro + Zustand）
   - 构建命令：`pnpm build`
   - `## 纠错记录` 章节（可为空）

2. `.claude/AI_RULES.md` 必须包含至少 3 条红线，其中至少 1 条与"样式 / 组件 / 网络请求"相关（供需求文档继承）

3. `wiki/index.json` 必须是合法 JSON，`nodes[]` 至少 2 个节点，且 `by_alias` 索引含 `bottom-sheet`、`voice-assistant` 关键词

4. `wiki/nodes/component.bottom-sheet.md` 必须包含 `## 历史包袱 (Legacy Constraints)` 章节，且**含有至少一条实际约束**（非"无"）

### 阶段二：执行 zacc-requirement-spec Skill

针对以下模拟用户描述生成需求文档：

#### 模拟用户描述

> 把 BottomSheet 的语音交互改造一下，当前弹出后默认就会开始听，用户反馈太突兀，希望可以改成用户点了话筒按钮才开始听；另外 BottomSheet 关闭时如果还在听要主动停止，不然后台会一直占麦。

**要求**：

- 产出文件路径：`docs/requirements/bottom-sheet-voice-revamp.md`
- 目录须通过 `mkdir -p docs/requirements` 确保存在
- 必须继承 `.claude/AI_RULES.md` 中的红线至「全局约束 → 来自 AI_RULES.md 的红线」
- 必须读取 `wiki/nodes/component.bottom-sheet.md` 的 Legacy Constraints 并引用到「本需求特有约束」
- `## 元数据 (Meta)` 表格 7 个字段齐全，`feature-name` 用反引号 kebab-case 格式（即 `` `bottom-sheet-voice-revamp` ``）
- 至少一个子需求的六段式（背景 / 现状问题 / 改造方案 / 验收标准 / 受影响文件 / 参考代码）齐全且非空
- 验收标准必须为可观察行为描述，禁止"体验更好"类模糊用语
- `## 待补充信息 (TODO)` 章节存在，即使无条目也显式写「无」

### 阶段三：自校验（可选但建议）

落盘后可运行：

```bash
bash .claude/skills/zacc-requirement-spec/scripts/verify-requirement.sh docs/requirements/bottom-sheet-voice-revamp.md
```

（该脚本在真实项目中存在；本 eval 断言脚本会另行重跑等价校验）

## Definition of Done

1. `.test-workspace/` 下上游产物骨架完整（CLAUDE.md / AI_RULES.md / wiki/ 四件套 / 两节点）
2. `.test-workspace/docs/requirements/bottom-sheet-voice-revamp.md` 已生成
3. 文档含完整 Meta 表（feature-name / 需求类型 / 估计粒度 / 主模块路径 / 关联 Wiki 节点 / 涉及新接口 / 涉及路由变更 / 涉及全局状态变更 8 行）
4. 文档含「上游产物摘要」表格（4 行，CLAUDE.md / AI_RULES.md / wiki/index.json / wiki/glossary.md 各一行）
5. 至少一个子需求六段齐全
6. 「全局约束」章节继承至少 1 条 AI_RULES 红线
7. 「全局约束 → 本需求特有约束」引用 Legacy Constraints
8. 无溢出产物：未在 `docs/tasks/` 或 `src/` 下创建任何文件
9. 无未替换的 `{...}` 占位符（允许 `unknown` / `TBD`）

执行完毕后直接退出，无需多言。
