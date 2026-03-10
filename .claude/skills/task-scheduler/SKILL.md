---
description: 多任务并发调度器 - 从任务清单自动创建 NF 并管理多个 Agent 并发执行
name: task-scheduler
invocable: true
---

# Task Scheduler - 多任务并发调度器

自动化管理多个开发任务的并发执行，最多支持 4 个 Agent 同时运行。

## 功能特性

- 📋 从任务清单文件读取多个开发需求
- 🤖 为每个任务自动创建 NF 并分配 Agent
- ⚡ 智能并发控制（最多 4 个 Agent）
- 🔄 自动循环监控所有任务状态
- 📊 实时进度报告和最终汇总

---

## 使用方法

### 1. 准备任务清单

创建或编辑 `docs/tasks/task-list.md`：

```markdown
## 待处理
- [ ] 添加深色模式切换功能 [优先级:High] [工作量:Medium]
- [ ] 优化项目分析器性能 [优先级:Medium] [工作量:Large]
- [ ] 修复 tmux 集成问题 [优先级:Low] [工作量:Small]
```

### 2. 启动调度器

```bash
/task-scheduler start
```

### 3. 查看进度

```bash
/task-scheduler status
```

### 4. 停止调度器

```bash
/task-scheduler stop
```

---

## 命令详解

当用户调用 `/task-scheduler [command]` 时，你需要执行以下操作：

### Command: `start`

**目的：** 启动任务调度器，开始执行任务清单中的所有任务。

**执行步骤：**

#### 步骤 1：读取并解析任务清单

```markdown
1. 读取 `docs/tasks/task-list.md`
2. 解析所有 `- [ ]` 格式的待处理任务
3. 提取任务信息：
   - 任务描述
   - 优先级 (High/Medium/Low)
   - 工作量 (Small/Medium/Large)
4. 验证任务格式，报告错误
```

**任务解析逻辑：**
```
正则表达式：^- \[ \] (.+?) \[优先级:(High|Medium|Low)\] \[工作量:(Small|Medium|Large)\]$

示例输入：
- [ ] 添加深色模式切换功能 [优先级:High] [工作量:Medium]

解析结果：
{
  "description": "添加深色模式切换功能",
  "priority": "High",
  "workload": "Medium"
}
```

#### 步骤 2：为每个任务创建 NF

```markdown
对于每个解析的任务：
1. 调用 /nf-new 创建新的 NF
2. 传递任务信息：描述、优先级、工作量
3. 记录映射关系：Task Index → NF Number
4. 更新 task-list.md，将任务移到"进行中"
```

**NF 创建示例：**
```
任务：添加深色模式切换功能 [优先级:High] [工作量:Medium]
↓
创建：NF-003-dark-mode.md
映射：Task #1 → NF-003
```

#### 步骤 3：初始化调度器状态

```markdown
创建状态文件：docs/tasks/scheduler-state.json

{
  "status": "running",
  "start_time": "2026-03-10T16:30:00Z",
  "tasks": [
    {
      "task_id": 1,
      "description": "添加深色模式切换功能",
      "nf_number": "NF-003",
      "agent_id": null,
      "status": "pending",
      "priority": "High",
      "workload": "Medium"
    },
    {
      "task_id": 2,
      "description": "优化项目分析器性能",
      "nf_number": "NF-004",
      "agent_id": null,
      "status": "pending",
      "priority": "Medium",
      "workload": "Large"
    }
  ],
  "running_agents": [],
  "completed_tasks": [],
  "failed_tasks": []
}
```

#### 步骤 4：启动初始 Agent（最多 4 个）

```markdown
1. 从 pending 队列取前 4 个任务
2. 为每个任务启动 Agent：
   - 使用 Agent tool
   - 传递提示：处理对应的 NF
   - 记录 agent_id
3. 更新状态文件：
   - 任务状态 → "running"
   - 记录 agent_id
   - 添加到 running_agents 列表
```

**Agent 启动示例：**
```
Agent tool 调用：
{
  "description": "实现 NF-003",
  "prompt": "请实现 NF-003（添加深色模式切换功能）。参考 docs/features/NF-003-dark-mode.md 的设计文档。完成后运行 /nf-verify 验证。",
  "subagent_type": "general-purpose",
  "run_in_background": true
}
```

#### 步骤 5：启动循环监控

```markdown
使用 CronCreate 创建定期任务：

{
  "cron": "*/5 * * * *",  # 每 5 分钟
  "prompt": "/task-scheduler check",
  "recurring": true
}

返回 job_id，保存到状态文件
```

#### 步骤 6：显示启动信息

```markdown
✅ 任务调度器已启动

📋 总任务数：6
⚡ 并发数：4
🔄 检查间隔：5 分钟

进行中的任务：
- Task #1 (NF-003): 添加深色模式切换功能 → Agent-abc123
- Task #2 (NF-004): 优化项目分析器性能 → Agent-def456
- Task #3 (NF-005): 修复 tmux 集成问题 → Agent-ghi789
- Task #4 (NF-006): 添加单元测试 → Agent-jkl012

待处理任务：
- Task #5 (NF-007): 更新文档
- Task #6 (NF-008): 性能优化

💡 使用 /task-scheduler status 查看实时进度
💡 使用 /task-scheduler stop 停止调度器
```

---

### Command: `check`

**目的：** 检查所有运行中任务的状态，自动启动新任务。

**执行步骤：**

#### 步骤 1：读取当前状态

```markdown
1. 读取 docs/tasks/scheduler-state.json
2. 获取 running_agents 列表
3. 检查调度器是否在运行
```

#### 步骤 2：检查所有 NF 状态

```markdown
1. 读取 docs/features/FEATURE_INDEX.md
2. 解析所有 NF 的状态
3. 对于每个 running_agents 中的任务：
   - 查找对应的 NF 状态
   - 检测状态变化：
     - Complete → 任务完成
     - Pending Verification → 等待验证
     - In Progress → 继续运行
```

**状态检测逻辑：**
```
running_agents: [
  { task_id: 1, nf: "NF-003", agent_id: "abc123" }
]

FEATURE_INDEX.md:
| NF-003 | 深色模式 | Complete | Medium | High |

结果：Task #1 已完成 ✅
```

#### 步骤 3：处理完成的任务

```markdown
对于每个完成的任务：
1. 从 running_agents 移除
2. 添加到 completed_tasks
3. 更新 task-list.md：
   - 将任务从"进行中"移到"已完成"
   - 标记为 [x]
4. 记录完成时间
```

#### 步骤 4：启动新任务

```markdown
如果 len(running_agents) < 4 且有 pending 任务：
1. 从 pending 队列取下一个任务
2. 启动新 Agent（参考 start 命令的步骤 4）
3. 更新状态文件
4. 通知用户：
   ✅ Task #X 完成，启动 Task #Y
```

#### 步骤 5：检查是否全部完成

```markdown
如果所有任务都完成：
1. 停止循环监控（CronDelete）
2. 生成最终报告
3. 更新调度器状态为 "completed"
4. 显示汇总信息
```

**全部完成报告：**
```markdown
🎉 所有任务已完成！

📊 执行汇总：
- 总任务数：6
- 成功完成：5
- 失败任务：1
- 总耗时：2 小时 15 分钟

✅ 已完成任务：
- NF-003: 添加深色模式切换功能 (45分钟)
- NF-004: 优化项目分析器性能 (1小时20分钟)
- NF-005: 修复 tmux 集成问题 (15分钟)
- NF-006: 添加单元测试 (30分钟)
- NF-007: 更新文档 (10分钟)

❌ 失败任务：
- NF-008: 性能优化 (错误：依赖项缺失)

💡 使用 /task-scheduler report 查看详细报告
```

---

### Command: `status`

**目的：** 显示当前调度器状态和任务进度。

**执行步骤：**

```markdown
1. 读取 docs/tasks/scheduler-state.json
2. 显示：
   - 调度器状态（running/stopped/completed）
   - 运行时长
   - 总任务数 / 完成数 / 进行中 / 待处理
   - 每个任务的详细状态
3. 显示进度条
```

**输出示例：**
```markdown
📊 任务调度器状态

状态：运行中 🟢
运行时长：1 小时 30 分钟
进度：[████████░░] 4/6 (67%)

进行中 (2)：
- Task #3 (NF-005): 修复 tmux 集成问题
  Agent: ghi789 | 状态: In Progress | 已运行: 25分钟
- Task #4 (NF-006): 添加单元测试
  Agent: jkl012 | 状态: In Progress | 已运行: 15分钟

待处理 (2)：
- Task #5 (NF-007): 更新文档 [优先级:Medium]
- Task #6 (NF-008): 性能优化 [优先级:Low]

已完成 (2)：
✅ Task #1 (NF-003): 添加深色模式切换功能 (45分钟)
✅ Task #2 (NF-004): 优化项目分析器性能 (1小时20分钟)

下次检查：3 分钟后
```

---

### Command: `stop`

**目的：** 停止调度器，但不停止已运行的 Agent。

**执行步骤：**

```markdown
1. 停止循环监控：
   - 使用 CronDelete 删除定期任务
2. 更新状态文件：
   - status → "stopped"
   - stop_time → 当前时间
3. 保留 running_agents（不停止）
4. 显示停止信息
```

**输出示例：**
```markdown
⏸️ 任务调度器已停止

运行中的 Agent 将继续执行（不受影响）
已停止自动状态检查和新任务启动

当前仍在运行的任务：
- Task #3 (NF-005): Agent ghi789
- Task #4 (NF-006): Agent jkl012

💡 使用 /task-scheduler start 重新启动调度器
💡 使用 /task-scheduler status 查看当前状态
```

---

### Command: `report`

**目的：** 生成详细的执行报告。

**执行步骤：**

```markdown
1. 读取状态文件
2. 生成 Markdown 报告
3. 保存到 docs/tasks/scheduler-report-[timestamp].md
4. 显示报告路径
```

**报告内容：**
```markdown
# 任务调度器执行报告

**生成时间：** 2026-03-10 18:45:00
**总耗时：** 2 小时 15 分钟

## 概览

| 指标 | 数值 |
|------|------|
| 总任务数 | 6 |
| 成功完成 | 5 |
| 失败任务 | 1 |
| 平均耗时 | 27 分钟/任务 |
| 并发效率 | 85% |

## 任务详情

### 已完成任务

#### NF-003: 添加深色模式切换功能
- **状态**：✅ 完成
- **优先级**：High
- **工作量**：Medium
- **Agent**：abc123
- **开始时间**：16:30:00
- **完成时间**：17:15:00
- **耗时**：45 分钟

#### NF-004: 优化项目分析器性能
...

### 失败任务

#### NF-008: 性能优化
- **状态**：❌ 失败
- **错误**：依赖项缺失
- **Agent**：xyz789
- **建议**：检查依赖项配置

## 性能分析

- 最快任务：NF-007 (10分钟)
- 最慢任务：NF-004 (1小时20分钟)
- 并发利用率：平均 3.2 个 Agent

## 建议

1. NF-008 失败，建议检查依赖项
2. 大型任务（Large workload）平均耗时超预期
3. 考虑增加并发数到 6 个
```

---

## 状态文件格式

### `docs/tasks/scheduler-state.json`

```json
{
  "status": "running",
  "start_time": "2026-03-10T16:30:00Z",
  "stop_time": null,
  "cron_job_id": "cron-123",
  "tasks": [
    {
      "task_id": 1,
      "description": "添加深色模式切换功能",
      "nf_number": "NF-003",
      "agent_id": "abc123",
      "status": "completed",
      "priority": "High",
      "workload": "Medium",
      "start_time": "2026-03-10T16:30:00Z",
      "complete_time": "2026-03-10T17:15:00Z",
      "duration_minutes": 45
    }
  ],
  "running_agents": [
    {
      "task_id": 3,
      "agent_id": "ghi789",
      "nf_number": "NF-005",
      "start_time": "2026-03-10T16:35:00Z"
    }
  ],
  "completed_tasks": [1, 2],
  "failed_tasks": [
    {
      "task_id": 8,
      "error": "依赖项缺失"
    }
  ],
  "stats": {
    "total_tasks": 6,
    "completed": 5,
    "failed": 1,
    "total_duration_minutes": 135
  }
}
```

---

## 错误处理

### 任务清单文件不存在
```markdown
❌ 错误：找不到任务清单文件

请创建 docs/tasks/task-list.md 并添加任务。
参考模板：docs/tasks/task-list-template.md

示例：
```
## 待处理
- [ ] 任务描述 [优先级:High] [工作量:Medium]
```
```

### 任务格式错误
```markdown
⚠️ 任务格式错误

以下任务格式不正确：
- 第 3 行：缺少优先级标签
- 第 5 行：工作量值无效（应为 Small/Medium/Large）

请修正后重新运行。
```

### Agent 启动失败
```markdown
❌ Agent 启动失败：Task #3 (NF-005)
错误：Agent tool 返回错误

任务已标记为失败。
继续处理其他任务...
```

### 状态文件损坏
```markdown
❌ 状态文件损坏

scheduler-state.json 格式错误。
是否重新初始化？[y/n]

警告：将丢失当前进度。
```

---

## 实现注意事项

### 1. 并发控制
- 使用 `running_agents` 列表跟踪当前运行的 Agent
- 每次检查确保 `len(running_agents) <= 4`
- 从 pending 队列按顺序取任务（或按优先级）

### 2. 状态同步
- 每次 check 都读取 FEATURE_INDEX.md 获取最新状态
- 不依赖缓存，始终读取文件
- 使用文件锁防止并发写入冲突（可选）

### 3. Agent 生命周期
- Agent 启动后独立运行
- 调度器不直接控制 Agent
- 通过 NF 状态间接判断 Agent 是否完成

### 4. 错误恢复
- 状态文件持久化所有信息
- 调度器崩溃后可恢复
- 使用 `/task-scheduler start` 恢复运行

### 5. 性能考虑
- 避免频繁读取大文件
- check 间隔建议 5 分钟（可配置）
- 状态文件使用 JSON 便于解析

---

## 测试场景

### 场景 1：正常流程
```
1. 创建包含 3 个任务的清单
2. 运行 /task-scheduler start
3. 观察 3 个 Agent 启动
4. 等待 5 分钟，检查状态更新
5. 等待所有任务完成
6. 验证报告生成
```

### 场景 2：并发限制
```
1. 创建包含 6 个任务的清单
2. 运行 /task-scheduler start
3. 验证只启动 4 个 Agent
4. 等待 1 个完成
5. 验证自动启动第 5 个 Agent
```

### 场景 3：错误处理
```
1. 创建格式错误的任务清单
2. 运行 /task-scheduler start
3. 验证错误提示
4. 修正格式后重试
```

### 场景 4：停止和恢复
```
1. 启动调度器，执行 2 个任务
2. 运行 /task-scheduler stop
3. 验证循环监控停止
4. 运行 /task-scheduler start
5. 验证从上次状态恢复
```

---

## 版本历史

- **v1.0** (2026-03-10)
  - 初始版本
  - 支持基本的任务调度和并发控制
  - 支持循环监控和自动启动

---

**NF 关联：** NF-002
**创建日期：** 2026-03-10
**最后更新：** 2026-03-10
