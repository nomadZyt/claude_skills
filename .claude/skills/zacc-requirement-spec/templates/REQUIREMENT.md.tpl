# 需求：{feature-title}

> 由 **zacc-requirement-spec** 技能生成
> Feature: `{feature-name}`
> 生成时间：{date}
> 下游 Skill：`zacc-task-spec`（读取本文件产出 `docs/tasks/{feature-name}/IMPLEMENTATION_PLAN.md`）

---

## 元数据 (Meta)

> ⚠️ 机读区块，供 zacc-task-spec 自动填充 IMPLEMENTATION_PLAN.md 的 Meta / 上游产物依赖 / UI 拓扑头字段。字段不可省略，未知填 `unknown`。

| 字段 | 值 |
|------|----|
| feature-name | `{kebab-case-name}` |
| 需求类型 | {新功能 / 改造 / Bug 修复 / 重构} |
| 估计粒度 | {S / M / L}（L 级 task-spec 强制拆分） |
| 主模块路径 | `{如 src/pages/subpackages/carGroupAgent；通用项目则为入口目录}` |
| 关联 Wiki 节点 | `{node-id，如 subpackage.car-group-agent；未检出填 unknown}` |
| 涉及新接口 | {是 / 否} |
| 涉及路由变更 | {是 / 否} |
| 涉及全局状态变更 | {是 / 否} |

## 上游产物摘要

> zacc-requirement-spec 探测上游 init 产物后填入。task-spec 可跳过再次探测。

| 产物 | 状态 | 摘要 |
|------|------|------|
| CLAUDE.md | {已加载 / 未找到} | {技术栈一行摘要，如 React 18 + TypeScript 5 + Vite} |
| .claude/AI_RULES.md | {已加载 / 未找到} | {命中的红线条目数 + 类别，如 2 条架构红线} |
| wiki/index.json | {已加载 / 未找到} | {命中的节点数 + 主节点 ID} |
| wiki/glossary.md | {已加载 / 未找到} | {命中的术语数} |

---

## 一、{子需求标题 1}

### 背景

- 目标文件：`{路径}`
- 当前实现：{1-3 句，含关键变量 / 常量 / 函数名}
- 参照实现（如有）：`{参考文件}` 的 `{方法 / 组件名}`

### 现状问题

> 编号列出，每条一句话说清"哪里不好 / 为什么"。task-spec 据此拆 Task。

1. {问题 1}
2. {问题 2}

### 改造方案

> 具体到文件 / 函数 / 保留与删除。可用 #### 子标题分点。

#### 1. {子方案点}

- {做法}
- {约束}

```ts
// 可选：接口 / 状态草稿，为 task-spec Step 1「契约优先」提供种子
interface XxxProps {
  // ...
}
```

### 验收标准

> 可测试、可观察。禁止"体验更好"这种非量化描述。

1. {可验证行为 1}
2. {可验证行为 2}

### 受影响文件

- `{path}`（新增 / 修改 / 删除）

### 参考代码

- `{path}`：{为什么参考}

---

## 二、{子需求标题 2}（如需）

> 复用上方六段式：背景 / 现状问题 / 改造方案 / 验收标准 / 受影响文件 / 参考代码

---

## 全局约束

> 跨所有子需求的硬约束，task-spec 会映射为里程碑级约束。

### 来自 AI_RULES.md 的红线（自动继承）

- {自动填充 AI_RULES.md 中命中的红线，如：禁止直接使用 wx.request / axios，必须经 @dm/dm-taro-tool 的 post / get}
- {若 AI_RULES.md 不存在则写：未检出项目红线，建议先执行 zacc-init-fronted}

### 本需求特有约束

- {如：卡片宽度 520rpx 不得变更，与分页吸附强耦合}

---

## 交付说明

- commit 切分：{一子需求一 commit / 合并}
- commit 前缀建议：`{feat(scope) / fix(scope) / style(scope)}`
- 兼容性验证：{如：iOS + Android 微信小程序真机各验一次；或 Chrome / Safari 各验一次}

---

## 待补充信息 (TODO)

> 生成 skill 追问后仍未确认的字段。由用户二次补充或留给 task-spec 在 Phase A 探测。

- [ ] {待补充 1}
