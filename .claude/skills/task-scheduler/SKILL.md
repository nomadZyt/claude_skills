---
description: 多任务并发调度器 - 基于 Team 机制自动创建 NF 并管理多个 Agent 并发执行
name: task-scheduler
invocable: true
---

# Task Scheduler - 多任务并发调度器 (v2.0 Team 机制)

基于 Claude Code 原生 Team 机制（TeamCreate + TaskCreate + SendMessage）的多任务并发调度器。
Agent 完成后主动发消息通知调度器（team lead），无需轮询。

## 核心架构

- **TeamCreate** 创建调度团队，调度器作为 team lead
- **TaskCreate** 管理任务状态和依赖关系
- **Agent** 以 teammate 身份运行，完成后通过 SendMessage 通知 lead
- **TaskList/TaskUpdate** 实时追踪任务状态
- 最大并发数：4 个 Agent

---

## 使用方法

### 1. 准备任务清单

创建或编辑 `docs/tasks/task-list.md`：

```markdown
## 待处理
- [ ] 添加深色模式切换功能 [优先级:High] [工作量:Medium]
- [ ] 优化项目分析器性能 [优先级:Medium] [工作量:Large]
- [ ] 修复 tmux 集成问题 [优先级:Low] [工作量:Small]
- [ ] 编写集成测试 [优先级:Medium] [工作量:Medium] [依赖:1,2]
```

任务编号从 1 开始，按清单中的顺序自动分配。`[依赖:1,2]` 表示该任务在第 1、2 个任务完成后才会启动。

### 2. 启动调度器

```
/task-scheduler start
```

### 3. 查看进度

```
/task-scheduler status
```

### 4. 停止调度器

```
/task-scheduler stop
```

---

## 命令详解

当用户调用 `/task-scheduler [command]` 时，执行以下操作：

### Command: `start`

**目的：** 启动任务调度器，创建 Team 并开始执行任务。

**执行步骤：**

#### 步骤 1：读取并解析任务清单

```
1. 读取 `docs/tasks/task-list.md`
2. 解析所有 `- [ ]` 格式的待处理任务
3. 提取任务信息：描述、优先级、工作量
4. 验证任务格式，报告错误
```

**任务解析逻辑：**
```
正则表达式：^- \[ \] (.+?) \[优先级:(High|Medium|Low)\] \[工作量:(Small|Medium|Large)\](?:\s*\[依赖:([\d,]+)\])?$

任务编号从 1 开始，按清单中出现的顺序自动分配。

示例输入（无依赖）：
- [ ] 添加深色模式切换功能 [优先级:High] [工作量:Medium]

解析结果：
{
  "index": 1,
  "description": "添加深色模式切换功能",
  "priority": "High",
  "workload": "Medium",
  "dependencies": []
}

示例输入（有依赖）：
- [ ] 编写集成测试 [优先级:Medium] [工作量:Medium] [依赖:1,2]

解析结果：
{
  "index": 4,
  "description": "编写集成测试",
  "priority": "Medium",
  "workload": "Medium",
  "dependencies": [1, 2]
}

依赖说明：
- [依赖:X,Y] 中的数字是任务在清单中的序号（从 1 开始）
- 依赖的任务必须全部 completed 后，该任务才可被调度
- 依赖标签是可选的，省略表示无依赖
```

**依赖关系验证（步骤 1.5）：**
```
解析完所有任务后，执行依赖关系验证：

1. 检查依赖编号有效性：
   - 所有 dependencies 中的编号必须 >= 1 且 <= 任务总数
   - 任务不能依赖自身
   - 无效依赖报错并中止

2. 检查循环依赖（拓扑排序 - Kahn 算法）：
   - 构建有向图：对每个任务 T，若 T.dependencies 包含 D，则添加边 D → T
   - 计算每个节点的入度
   - 将入度为 0 的节点加入队列
   - 逐个出队，将其指向节点的入度减 1，入度变为 0 则入队
   - 如果处理的节点数 < 任务总数，说明存在循环依赖
   - 循环依赖报错并中止，列出未被处理的任务编号

验证通过后继续步骤 2。
```

#### 步骤 2：为每个任务创建 NF

```
对于每个解析的任务：
1. 如果任务工作量 >= Medium，调用 /nf-new 创建新的 NF
2. 记录映射关系：Task Index → NF Number
3. 更新 task-list.md，将任务移到"进行中"

注意：Small 工作量的任务可以直接执行，无需创建 NF
```

#### 步骤 3：启动 Web Dashboard 服务器

```
在后台启动 WebSocket 服务器，用于 Web Dashboard 实时更新：

Bash tool 调用（后台运行）：
{
  "command": "node .claude/skills/task-scheduler/web/server.js",
  "description": "启动 Task Scheduler Dashboard WebSocket 服务器",
  "run_in_background": true
}

服务器信息：
- HTTP 端口：8099（默认）
- WebSocket 端点：ws://localhost:8099/ws
- 监听文件：docs/tasks/scheduler-state.json（自动从项目根目录定位）
- 服务器启动后自动打开浏览器

如果端口 8099 被占用，使用备用端口：
node .claude/skills/task-scheduler/web/server.js --port 8081

记录服务器进程信息到 scheduler-state.json：
{
  "dashboard_port": 8099,
  "dashboard_pid": {进程ID}
}
```

#### 步骤 4：创建 Team

```
调用 TeamCreate：
{
  "team_name": "task-scheduler-{timestamp}",
  "description": "任务调度器 - 管理 N 个并发开发任务"
}

记录 team_name，后续所有操作都使用这个 team_name。
```

#### 步骤 5：创建 Tasks 并设置依赖

```
4a. 创建所有任务：

对每个解析的任务调用 TaskCreate：
{
  "subject": "实现: {任务描述}",
  "description": "优先级: {priority}\n工作量: {workload}\nNF编号: {nf_number}\n依赖: {dependencies}\n\n详细要求: {任务描述}",
  "activeForm": "正在实现 {任务描述}"
}

记录映射关系：清单序号(index) → TaskCreate 返回的 task_id
例如：{ 1: "task-101", 2: "task-102", 3: "task-103", 4: "task-104" }

4b. 设置依赖关系：

创建完所有任务后，遍历有依赖的任务，调用 TaskUpdate 设置 addBlockedBy：

对每个 task，如果 task.dependencies 不为空：
  将 dependencies 中的清单序号转换为对应的 task_id
  调用 TaskUpdate({
    taskId: task.task_id,
    addBlockedBy: [dep_task_id_1, dep_task_id_2, ...]
  })

示例：
  清单中任务 4 依赖任务 1 和 2（[依赖:1,2]）
  映射后：task-104 blockedBy [task-101, task-102]
  调用：TaskUpdate({ taskId: "task-104", addBlockedBy: ["task-101", "task-102"] })

注意：必须先创建所有任务再设置依赖，因为需要知道所有 task_id。
```

#### 步骤 6：启动 Agent（最多 4 个）

```
从 pending 任务中按优先级队列排序取前 N 个（N = 4 - 当前 in_progress 数量）：

优先级队列排序规则（详见 docs/tasks/priority-algorithm.md）：
1. 按优先级权重降序：High(3) > Medium(2) > Low(1)
2. 同优先级按任务 ID 升序（先创建的任务先执行）
3. 被阻塞的任务（blockedBy 中有未完成任务）不参与排序，直接跳过

排序伪代码：
  pendingTasks
    .filter(task => task.blockedBy.length === 0)
    .sort((a, b) => {
      const weight = { High: 3, Medium: 2, Low: 1 };
      if (weight[b.priority] !== weight[a.priority])
        return weight[b.priority] - weight[a.priority];
      return a.task_id - b.task_id;
    })
    .slice(0, maxSlots)    // maxSlots = 4 - in_progress_count

对排序后的每个任务启动一个 Agent：

Agent tool 调用：
{
  "description": "实现 {NF编号或任务描述}",
  "prompt": "你是任务调度团队的成员。你的任务是：

## 任务信息
- 任务ID: {task_id}
- 描述: {任务描述}
- NF编号: {nf_number}（如有）
- 优先级: {priority}
- 工作量: {workload}

## 执行要求
1. 首先使用 TaskUpdate 将你的任务标记为 in_progress
2. 如果有 NF 文件，参考 docs/features/{nf_file} 的设计文档
3. 实现任务要求的功能
4. 完成后运行必要的验证

## 完成后必做（关键！）
完成所有工作后，你必须：
1. 使用 TaskUpdate 将你的任务（ID: {task_id}）标记为 completed
2. 使用 SendMessage 通知 team lead 你的完成状态：
   SendMessage({
     type: 'message',
     recipient: 'lead',
     content: '任务 {task_id} 已完成: {简要说明完成内容}',
     summary: '任务{task_id}完成'
   })

如果任务失败，同样通知 team lead 并说明失败原因。",
  "subagent_type": "general-purpose",
  "team_name": "{team_name}",
  "name": "worker-{task_id}",
  "run_in_background": true
}
```

#### 步骤 7：保存状态到 scheduler-state.json（备份）

```
创建/更新 docs/tasks/scheduler-state.json：
{
  "status": "running",
  "start_time": "{ISO时间}",
  "team_name": "{team_name}",
  "tasks": [
    {
      "index": 1,
      "task_id": "{TaskCreate返回的ID}",
      "description": "任务描述",
      "nf_number": "NF-XXX",
      "agent_name": "worker-{id}",
      "priority": "High",
      "workload": "Medium",
      "dependencies": [],
      "status": "running"
    },
    {
      "index": 4,
      "task_id": "{TaskCreate返回的ID}",
      "description": "编写集成测试",
      "nf_number": null,
      "agent_name": null,
      "priority": "Medium",
      "workload": "Medium",
      "dependencies": [1, 2],
      "status": "blocked"
    }
  ],
  "index_to_task_id": { "1": "task-101", "2": "task-102", "3": "task-103", "4": "task-104" },
  "max_concurrency": 4
}

status 字段说明：
- "pending"  — 无依赖或依赖已满足，等待调度
- "blocked"  — 有未完成的依赖，暂不可调度
- "running"  — Agent 正在执行
- "completed"— 已完成
- "failed"   — 执行失败
```

#### 步骤 8：显示启动信息

```
✅ 任务调度器已启动（Team 机制 v2.4）

📋 总任务数：{N}
⚡ 最大并发：4
🏗️ Team: {team_name}
🌐 Dashboard: http://localhost:8099

进行中的任务：
- Task #{id}: {描述} → worker-{id}
- Task #{id}: {描述} → worker-{id}
...

待处理任务：
- Task #{id}: {描述}
...

💡 Agent 完成后会自动通知调度器
🔄 安全网：/loop 10m 定期检查（防止通知丢失）
📊 Dashboard 实时更新状态（WebSocket 长连接）
💡 使用 /task-scheduler status 查看实时进度
💡 使用 /task-scheduler stop 停止调度器
```

#### 步骤 9：启动 /loop 安全网检查

```
启动定期检查作为安全网，防止 Agent 通知丢失或卡住：

调用 /loop skill：
  /loop 10m /task-scheduler check

这会每 10 分钟自动运行一次 check 命令。
- 不是主要调度机制（主要靠 Agent SendMessage 通知）
- 作为 fallback：如果 Agent 卡住没发通知，loop 会发现并补救
- 间隔较长（10 分钟），不会造成性能负担

将 loop 信息记录到 scheduler-state.json：
  "loop_interval": "10m",
  "loop_active": true
```

#### 步骤 10：等待 Agent 通知并调度

```
调度器作为 team lead 等待 Agent 的消息。

当收到 Agent 的完成通知后（或 /loop 触发 check 发现状态变化时）：
1. 调用 TaskList 检查当前状态
2. 统计 completed / in_progress / pending（含 blocked）任务数
3. 检查依赖解锁：
   - 遍历所有 pending 任务的 blockedBy 列表
   - 如果 blockedBy 中的所有任务都已 completed，该任务变为可调度
   - TaskList 原生支持：当 blockedBy 中的任务全部 completed 后，
     该任务的 blockedBy 自动清空，变为普通 pending 任务
4. 如果还有可调度的 pending 任务 且 in_progress < 4：
   - 按优先级队列排序选取任务（同步骤 6）
   - 启动新的 Agent
5. 如果所有任务都 completed：
   - 停止 WebSocket 服务器（kill dashboard_pid）
   - 生成最终报告
   - 对所有 Agent 发送 shutdown_request
   - 调用 TeamDelete 清理
   - 更新 scheduler-state.json 状态为 "completed"
```

---

### Command: `check`

**目的：** 检查任务状态并补救调度。可手动调用，也由 `/loop` 定期触发。

**触发方式：**
- 手动：用户输入 `/task-scheduler check`
- 自动：`/loop 10m /task-scheduler check`（start 时启动）

**执行步骤：**

```
1. 读取 scheduler-state.json 获取 team_name
2. 调用 TaskList 获取所有任务状态
3. 统计各状态的任务数：completed / in_progress / pending
4. 检测卡住的任务：
   - 如果某个任务 in_progress 超过 30 分钟无进展，标记为可能卡住
   - 输出警告信息
5. 补救调度（使用优先级队列排序）：
   - 如果有 pending 任务且 in_progress < 4：
     按优先级队列排序选取任务并启动新 Agent（排序规则同步骤 6）：
     High(3) > Medium(2) > Low(1)，同优先级按任务 ID 升序，跳过被阻塞任务
   - 这是 /loop 安全网的核心价值——即使 Agent 的 SendMessage 丢失，
     loop 触发的 check 会通过 TaskList 发现已完成的任务并补启新 Agent
6. 显示当前状态摘要
7. 如果所有任务完成：
   - 停止 /loop（不再需要检查）
   - 触发报告生成
   - 清理 Team
```

**输出示例（由 /loop 触发时）：**
```
🔍 任务状态检查（定期巡检）

进度：[████████░░] 4/6 (67%)

✅ completed: 4
🔄 in_progress: 2
⏳ pending: 0

所有任务已分配，等待完成中...
下次巡检：10 分钟后
```

**输出示例（发现需要补救时）：**
```
🔍 任务状态检查（定期巡检）

进度：[██████░░░░] 3/6 (50%)

⚠️ 发现调度机会：
- Task #4 已完成但未触发新任务调度
- 正在启动 Task #5 的 Agent...

✅ completed: 3
🔄 in_progress: 2 → 3（新启动 1 个）
⏳ pending: 1 → 0
```

---

### Command: `status`

**目的：** 显示当前调度器状态和任务进度。

**执行步骤：**

```
1. 调用 TaskList 获取所有任务实时状态
2. 读取 docs/tasks/scheduler-state.json 获取 team_name 和 start_time
3. 计算运行时长
4. 按状态分组显示所有任务
```

**输出示例：**
```
📊 任务调度器状态

状态：运行中 🟢
Team: task-scheduler-1710000000
运行时长：1 小时 30 分钟
进度：[████████░░] 4/6 (67%)

🔄 进行中 (2)：
- Task #5: 修复 tmux 集成问题 → worker-5
- Task #6: 添加单元测试 → worker-6

⏳ 待处理 (0)：
（无）

✅ 已完成 (4)：
- Task #1: 添加深色模式切换功能
- Task #2: 优化项目分析器性能
- Task #3: 更新 README 文档
- Task #4: 修复登录页面 bug
```

---

### Command: `stop`

**目的：** 停止调度器，关闭所有 Agent。

**执行步骤：**

```
1. 停止 /loop 安全网：
   - 调用 CronList 查找活跃的 loop job
   - 调用 CronDelete 删除对应的 cron job
2. 停止 Web Dashboard 服务器：
   - 读取 scheduler-state.json 获取 dashboard_pid
   - 调用 Bash: kill {dashboard_pid}
3. 读取 scheduler-state.json 获取 team_name
4. 调用 TaskList 获取所有 in_progress 任务
5. 对每个运行中的 Agent 发送 shutdown_request：
   SendMessage({
     type: "shutdown_request",
     recipient: "worker-{task_id}",
     content: "调度器停止，请结束当前工作"
   })
6. 等待 shutdown_response 或超时
7. 调用 TeamDelete 清理 Team 资源
8. 更新 scheduler-state.json：
   - status → "stopped"
   - stop_time → 当前时间
   - loop_active → false
   - dashboard_pid → null
9. 显示停止信息
```

**输出示例：**
```
⏹️ 任务调度器已停止

已停止 Web Dashboard 服务器
已发送停止请求给所有运行中的 Agent
Team 资源已清理

最终状态：
- 已完成：4
- 已停止：2
- 待处理：0

💡 使用 /task-scheduler start 重新启动
```

---

### Command: `report`

**目的：** 生成详细的执行报告。

**执行步骤：**

```
1. 调用 TaskList 获取所有任务信息
2. 读取 scheduler-state.json 获取时间信息
3. 生成 Markdown 报告
4. 保存到 docs/tasks/scheduler-report-{timestamp}.md
5. 在终端显示报告摘要
```

**报告内容：**
```markdown
# 任务调度器执行报告

**生成时间：** {当前时间}
**Team:** {team_name}
**总耗时：** {时长}

## 概览

| 指标 | 数值 |
|------|------|
| 总任务数 | N |
| 成功完成 | X |
| 失败任务 | Y |

## 任务详情

### 已完成任务

| 任务 | NF | 优先级 | 工作量 | Agent |
|------|-----|--------|--------|-------|
| 描述 | NF-XXX | High | Medium | worker-1 |

### 失败任务

| 任务 | 错误原因 |
|------|----------|
| 描述 | 错误信息 |
```

---

## 错误处理

### 任务清单文件不存在
```
❌ 错误：找不到任务清单文件

请创建 docs/tasks/task-list.md 并添加任务。

示例：
## 待处理
- [ ] 任务描述 [优先级:High] [工作量:Medium]
```

### 任务格式错误
```
⚠️ 任务格式错误

以下任务格式不正确：
- 第 X 行：缺少优先级标签
- 第 Y 行：工作量值无效

请修正后重新运行。
```

### Agent 启动失败
```
❌ Agent 启动失败：Task #{id}
错误：{错误信息}

任务已标记为失败，继续处理其他任务...
```

### Team 创建失败
```
❌ Team 创建失败
错误：{错误信息}

请检查是否已有同名 Team 在运行。
可以先运行 /task-scheduler stop 清理旧 Team。
```

### 依赖编号无效
```
❌ 依赖关系错误

以下任务的依赖编号无效：
- 任务 #4：依赖 [7]，但总共只有 5 个任务
- 任务 #3：不能依赖自身

请修正 [依赖:...] 标签后重新运行。
```

### 循环依赖
```
❌ 检测到循环依赖

以下任务形成了循环依赖：
- 任务 #2 依赖 #3
- 任务 #3 依赖 #2

请重新设计依赖关系，确保是有向无环图（DAG）。
```

---

## 实现注意事项

### 1. 并发控制
- 通过 TaskList 统计 in_progress 状态的任务数
- 确保 in_progress 数量 <= 4
- 新 Agent 启动前检查并发数

### 2. 状态管理
- **主要状态源**：TaskList（原生 Team 任务管理）
- **备份状态源**：scheduler-state.json（持久化）
- 每次操作后同步更新 scheduler-state.json

### 3. Agent 生命周期
- Agent 启动时加入 Team（通过 team_name 参数）
- Agent 通过 TaskUpdate 更新自己的任务状态
- Agent 通过 SendMessage 通知 team lead
- Agent 完成后自动进入 idle 状态，lead 会收到通知

### 4. 调度循环（双保险）
- **主路径**：Team lead 收到 Agent SendMessage/idle 通知后自动触发调度
- **安全网**：`/loop 10m /task-scheduler check` 定期巡检
  - 防止 Agent 通知丢失或 Agent 卡住
  - check 会通过 TaskList 发现状态变化并补救调度
  - 全部完成后自动停止 loop
- **手动**：用户随时可调用 `/task-scheduler check`

### 5. 错误恢复
- scheduler-state.json 持久化所有信息（含依赖映射 index_to_task_id）
- 如果调度器崩溃，可通过 /task-scheduler start 恢复
- 恢复时读取 scheduler-state.json 重建 Team

### 6. 任务依赖关系
- 依赖通过 `[依赖:X,Y]` 语法在 task-list.md 中声明
- 解析时验证：编号有效性 + 无循环依赖（拓扑排序）
- 使用 TaskUpdate 的 addBlockedBy 设置依赖，TaskList 原生管理阻塞状态
- 调度时自动跳过 blockedBy 非空的任务
- 当被依赖任务完成后，依赖者的 blockedBy 自动清空，进入可调度状态
- scheduler-state.json 中 index_to_task_id 映射清单序号到 task_id

---

## 版本历史

- **v2.4** (2026-03-12)
  - 移除：Slack 通知模块（用户不使用 Slack）
  - 删除：`lib/slack-notifier.js` 和 `notification-config.md`

- **v2.3** (2026-03-12)
  - 新增：可选 Slack 通知集成（task_started / task_completed / task_failed / all_completed）
  - 新增：`docs/tasks/notification-config.md` 通知配置文档
  - 支持 Webhook URL 环境变量、静默时段、失败 @mention
  - 通知异步发送，失败不阻塞调度主流程

- **v2.2** (2026-03-12)
  - 新增：优先级队列调度算法（High>Medium>Low，同优先级按任务 ID 升序）
  - 新增：`docs/tasks/priority-algorithm.md` 算法说明文档
  - 优化：步骤 5、步骤 9、check 命令均使用统一的优先级排序逻辑
  - 优化：被阻塞任务自动跳过，不参与优先级排序

- **v2.1** (2026-03-12)
  - 新增：任务依赖关系支持（`[依赖:X,Y]` 语法）
  - 新增：依赖验证（编号有效性 + 循环依赖检测）
  - 新增：依赖感知调度（blockedBy 自动管理）
  - 优化：scheduler-state.json 增加 index_to_task_id 映射和 dependencies 字段

- **v2.0** (2026-03-12)
  - 重构：从 Cron 轮询改为 Team 机制
  - Agent 完成后主动通知，无需轮询
  - 使用 TaskCreate/TaskList 原生任务管理
  - 使用 SendMessage 事件驱动调度
  - 支持 shutdown_request 优雅停止 Agent

- **v1.0** (2026-03-10)
  - 初始版本（Cron 轮询机制，已弃用）

---

**NF 关联：** NF-002
**创建日期：** 2026-03-10
**最后更新：** 2026-03-12 (v2.4 移除 Slack 通知模块)
