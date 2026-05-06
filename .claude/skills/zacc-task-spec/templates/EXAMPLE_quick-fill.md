# IMPLEMENTATION_PLAN.md — v2.2 示例

> 由 **zacc-task-spec** 技能自动生成
> Feature: `quick-fill`
> 生成时间：2026-04-29
> 当前状态：**completed**

---

## 需求概述

在智能录单（新建，无 `itemNo`）场景下，用户输入**车牌号 + 车架号**后，系统自动调用 `queryVehicleInsuranceInfo` 接口查询历史投保数据并回填至表单，减少手动录入，提升录单效率。接口返回结构与 `/insuranceItem/detail` 一致，缺失字段保持空白，不做 mock 数据兜底。编辑/抽屉场景下不触发。

## 上游产物依赖

> 记录本规划依赖的上游 Skill 产物状态，供跨 Session 恢复时快速校验。

| 产物 | 路径 | 状态 | 备注 |
|------|------|------|------|
| CLAUDE.md | `CLAUDE.md` | 已加载 | React 19 + TS + Umi Max + Zustand + Ant Design 5 |
| AI_RULES.md | `.claude/AI_RULES.md` | 未找到 | 无红线文件，以 CLAUDE.md 为准 |
| Wiki 索引 | `.wiki/index.json` | 已加载 | 58 个节点 |
| 术语表 | `.wiki/glossary.md` | 已加载 | 35+ 术语 |

---

## 1. UI 拓扑图 (UI Topology)

### 组件树

```
SingleEntryContent
├── useQueryBaseInfo (已有 hook — 负责初始 baseInfo 加载)
├── useHandleForm (已有 hook — 管理表单初始值与 onValuesChange)
├── useQuickFill ← 【新增 hook】
│   └── 监听车牌号 + 车架号 → 调用 queryVehicleInsuranceInfo → 增量回填
├── VehicleInfo (已有组件 — 含 plateNumber / vehicleVin 表单字段)
├── VehicleOwnerInfo (已有组件 — 回填车主信息)
├── ApplicantInfo (已有组件 — 回填投保人信息)
├── InsurantInfo (已有组件 — 回填被保人信息)
├── InsureCoverageListV2 (已有组件 — 回填险种信息)
└── NonCarList (已有组件 — 回填非车险信息)
```

### 组件分类

| 组件/模块 | 类型 | 来源 | 备注 |
|------|------|------|------|
| `SingleEntryContent` | 业务专用 | 已有 | [[page.single-entry]] 核心页面 |
| `useQuickFill` | 业务专用 | **新增** | 快速填单 hook |
| `queryVehicleInsuranceInfo` | API 函数 | **新增** | `src/api/quote/index.ts` 新增 |
| `useHandleForm` | 业务专用 | 已有 | 需改造 — 暴露 transformBaseInfoToFormValues |
| `useQueryBaseInfo` | 业务专用 | 已有 | 需改造 — 暴露 setBaseInfo |

---

## 2. 状态流动图 (State Flow)

### 数据来源

| 数据 | API 接口 | 请求方式 | 约束 |
|------|---------|---------|------|
| 历史投保信息 | `POST /api/v0/vehicleInfo/queryVehicleInsuranceInfo` | `{ plateNumber, vehicleVin, insurePlaceCode? }` | 仅新建场景（无 itemNo）时调用 |

### 状态边界

| 状态 | 类型 | 归属 | 说明 |
|------|------|------|------|
| `baseInfo` | 局部 State | `useQueryBaseInfo` | 快速填单不直接修改，改为 form.setFieldsValue 增量合并 |
| `quickFillLoading` | 局部 State | `useQuickFill` | 请求进行中状态 |
| `displayCoverageList` | 全局 Store | `useSingleEntryStore` | 仅接口有返回时才写入 |
| `nonAutoInfo` | 全局 Store | `useSingleEntryStore` | 仅接口有返回时才写入 |

### 数据流图

```
用户输入车牌号 + 车架号（表单 onValuesChange 监听）
       ↓  触发条件：无 itemNo && 非抽屉模式 && 两字段均有值
  useQuickFill hook（debounce 300ms）
       ↓  调用 queryVehicleInsuranceInfo API
  接口返回 bizValue
       ↓  transformBaseInfoToFormValues 转换为表单格式
       ↓  buildIncrementalValues 过滤 null + 跳过用户已修改字段
  form.setFieldsValue(增量合并)
       ↓  同时
  setState({ baseInfoCoverageSeed, nonAutoInfo })（仅有值时）
       ↓  触发 useComposeDisplayFromBaseInfo
  险种表格 / 非车列表回显
```

---

## 3. 阶段里程碑 (Milestones)

### M1: API 接口封装 + 数据契约

> 知识来源：需求文档 §5 接口定义 + `.wiki/nodes/api.quote` 节点 API 封装模式

- [x] **T1** (S): 在 `src/api/quote/index.ts` 新增 `queryVehicleInsuranceInfo` 函数和 `IQuickFillParams` 类型 — 涉及文件：`src/api/quote/index.ts`

  <details>
  <summary>执行详情</summary>

  **契约：** `queryVehicleInsuranceInfo(params: IQuickFillParams): Promise<API.IResponse>` — IQuickFillParams: `{ plateNumber?: string; vehicleVin?: string; insurePlaceCode?: string }`
  **关键决策：** 响应类型复用 `API.IResponse` 而非新建独立类型，因为返回结构与 `/insuranceItem/detail` 一致，已有的 baseInfo 处理逻辑可直接消费
  **变更文件：** `src/api/quote/index.ts` (修改)
  **关联 commit：** 尚未提交（示例用 `abc1234` 占位）
  **依赖：** 无
  **被依赖：** T3(useQuickFill hook)
  **回滚：** `git revert abc1234`，无下游状态副作用，可安全独立回滚；T3 会编译报错但不影响运行时
  </details>

### M2: 核心 Hook 实现（useQuickFill）

> 知识来源：`useQueryBaseInfo` 已有回填模式 + `useHandleForm` 的 initialValues 合成逻辑 + CLAUDE.md 状态管理规范

- [x] **T2** (M): 新增 `src/pages/singleEntry/hooks/useQuickFill.ts` — 涉及文件：`src/pages/singleEntry/hooks/useQuickFill.ts`

  <details>
  <summary>执行详情</summary>

  **契约：** `useQuickFill({ form, formRef, baseInfo, inDrawer, itemNo }): void` — 副作用 hook，无返回值
  **关键决策：**
  - 选择 debounce 300ms 而非 throttle，因为用户输入车架号是连续击键场景
  - 用 `hasFilled` ref 控制仅首次触发，避免用户修改已回填字段后二次覆盖
  - 用 `abortControllerRef` 实现请求取消，避免竞态
  **变更文件：** `src/pages/singleEntry/hooks/useQuickFill.ts` (新增)
  **关联 commit：** 尚未提交（示例用 `bcd2345` 占位）
  **依赖：** T1(API 函数)
  **被依赖：** T3(集成到页面)、T4(增量回填改造)
  **回滚：** `git revert bcd2345`，需同时回滚 T3（页面引用）；T1 可保留不受影响
  </details>

### M3: 集成到 SingleEntryContent + 联调

> 知识来源：`SingleEntryContent.tsx` 组件组装模式 + CLAUDE.md 数据兜底规则

- [x] **T3** (M): 在 `SingleEntryContent.tsx` 中引入 `useQuickFill`，协调 `useQueryBaseInfo` / `useHandleForm` — 涉及文件：`src/pages/singleEntry/SingleEntryContent.tsx`、`src/pages/singleEntry/hooks/useQueryBaseInfo.ts`

  <details>
  <summary>执行详情</summary>

  **契约：** `useQueryBaseInfo` 新增返回 `setBaseInfo` 方法；`SingleEntryContent` 将 `{ form, formRef, baseInfo, inDrawer, itemNo }` 传入 `useQuickFill`
  **关键决策：**
  - `useQueryBaseInfo` 暴露 `setBaseInfo` 而非让 `useQuickFill` 直接操作内部 state，保持 hook 间的单向依赖
  - 快速填单只在新建场景（baseInfo 首次加载完成且无 itemNo）时激活，编辑场景天然跳过
  **变更文件：** `src/pages/singleEntry/SingleEntryContent.tsx` (修改)、`src/pages/singleEntry/hooks/useQueryBaseInfo.ts` (修改)
  **关联 commit：** 尚未提交（示例用 `cde3456` 占位）
  **依赖：** T2(useQuickFill hook)
  **被依赖：** T4(增量回填改造)
  **回滚：** `git revert cde3456`；需同时回滚 T4（如已执行），然后回滚本 Task；`useQueryBaseInfo` 的 `setBaseInfo` 暴露会被移除，但不影响原有功能
  </details>

### M4: 增量回填策略 + 边界处理

> 知识来源：用户反馈 + `useHandleForm` initialValues 映射逻辑 + CLAUDE.md 数据兜底规则（禁止 mock）

- [x] **T4** (M): 改造 `useQuickFill` 回填策略：从整体替换改为增量合并（form.setFieldsValue），过滤 null 值和用户已填字段 — 涉及文件：`src/pages/singleEntry/hooks/useQuickFill.ts`、`src/pages/singleEntry/hooks/useHandleForm.ts`、`src/pages/singleEntry/SingleEntryContent.tsx`

  <details>
  <summary>执行详情</summary>

  **契约：** `useHandleForm` 新增导出 `transformBaseInfoToFormValues(baseInfo): FormValues` 纯函数；`useQuickFill` 内部新增 `buildIncrementalValues(newValues, currentValues, initialValues): Partial<FormValues>` 工具函数
  **关键决策：**
  - 提取 `transformBaseInfoToFormValues` 为纯函数，而非在 useQuickFill 中重写映射逻辑，保证回填字段格式与 useHandleForm 的 initialValues 完全一致
  - `buildIncrementalValues` 深度遍历剔除 null/undefined/空字符串叶节点，对比 currentValues vs initialValues 识别用户已修改字段并跳过
  - 险种/非车/增值服务等 store 数据仅在接口有返回时写入，null 时保留现有，遵守 CLAUDE.md 禁止 mock 数据兜底规则
  **变更文件：** `src/pages/singleEntry/hooks/useQuickFill.ts` (修改)、`src/pages/singleEntry/hooks/useHandleForm.ts` (修改)、`src/pages/singleEntry/SingleEntryContent.tsx` (修改)
  **关联 commit：** 尚未提交（示例用 `def4567` 占位）
  **依赖：** T2(useQuickFill hook)、T3(集成)
  **被依赖：** 无
  **回滚：** `git revert def4567` 可安全独立回滚，回滚后 useQuickFill 恢复为整体替换模式（T2/T3 的功能不受影响，只是回填策略退化）。注意：`useHandleForm` 导出的 `transformBaseInfoToFormValues` 函数会被移除，但该函数无其他消费者
  </details>

---

## 4. 历史包袱约束

> 从 `.wiki/nodes/` 的 Legacy Constraints 章节提取，与本需求相关的约束。

| 来源节点 | 约束描述 | 影响范围 | 应对策略 |
|---------|---------|---------|---------|
| page.single-entry | Legacy Constraints 章节为空 | - | 无需特殊处理 |

**补充约束**（来自代码分析）：

| 发现 | 约束 | 影响范围 | 应对策略 |
|------|------|---------|---------|
| `useHandleForm.onValuesChange` 在非冻结模式下会清空 `displayCoverageList` | 快速填单用 `form.setFieldsValue` 会触发 onValuesChange | T2/T4 | 使用增量合并而非 setBaseInfo → resetFields；onValuesChange 中险种清空逻辑由现有 freeze 机制控制 |
| `useQueryBaseInfo` 的 baseInfo 变化时自动 `form.resetFields()` | 直接修改 baseInfo 会重置整个表单 | T3 | T4 改为 form.setFieldsValue 增量合并，不再修改 baseInfo，避免触发全表单 reset |

---

## 5. 执行日志

> 每个 Task 完成后由 Agent 自动追加记录。

| Task | 完成时间 | 结果 | 备注 |
|------|---------|------|------|
| T1 | 2026-04-29 15:30 | 通过 | 新增 queryVehicleInsuranceInfo API + IQuickFillParams |
| T2 | 2026-04-29 16:00 | 通过 | 新增 useQuickFill hook，含 debounce + abortController + hasFilled |
| T3 | 2026-04-29 16:30 | 通过 | 集成到 SingleEntryContent，useQueryBaseInfo 暴露 setBaseInfo |
| T4 | 2026-04-29 17:15 | 通过 | transformBaseInfoToFormValues 纯函数提取；buildIncrementalValues 增量合并 |

---

## 6. 阻碍与变更记录

| 日期 | 类型 | 描述 | 处理方式 |
|------|------|------|---------|
| 2026-04-29 | 变更 | 快速填单回填策略变更：null 值不覆盖已有内容，用户已填字段不被覆盖 | 原 T3 的整体替换方案拆出 T4，改为增量合并 |
