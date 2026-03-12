# Task Scheduler - 多任务并发调度器 (v2.4)

基于 Claude Code 原生 Team 机制的多任务并发调度器。Agent 完成后主动通知调度器，无需轮询。

## 快速开始

### 1. 创建任务清单

```bash
cp docs/tasks/task-list-template.md docs/tasks/task-list.md
```

编辑 `docs/tasks/task-list.md`：

```markdown
## 待处理
- [ ] 添加深色模式切换功能 [优先级:High] [工作量:Medium]
- [ ] 优化项目分析器性能 [优先级:Medium] [工作量:Large]
- [ ] 修复 tmux 集成问题 [优先级:Low] [工作量:Small]
- [ ] 编写集成测试 [优先级:Medium] [工作量:Medium] [依赖:1,2]
```

任务编号按清单顺序从 1 开始。`[依赖:1,2]` 表示该任务在第 1、2 个任务完成后才会启动。

### 2. 启动调度器

```
/task-scheduler start
```

调度器将：
- 创建 Team（调度器为 team lead）
- 为每个任务创建 Task
- 启动最多 4 个并发 Agent（作为 teammate）
- Agent 完成后自动通知调度器
- 调度器自动启动下一个任务

### 3. 监控进度

```
/task-scheduler status
```

### 4. Web Dashboard（实时更新）

启动 WebSocket 服务器，在浏览器中实时查看任务进度：

```bash
cd .claude/skills/task-scheduler/web
npm start
```

浏览器打开 http://localhost:8080 即可看到实时更新的 Dashboard。

**特性：**
- WebSocket 实时推送状态变化
- 自动降级到轮询模式（WebSocket 不可用时）
- 显示任务进度、优先级、工作量
- 显示活跃 Agent 列表
- 深色主题，支持移动端

### 5. 查看报告

```
/task-scheduler report
```

---

## 架构说明

### v2.0 Team 机制（当前版本）

```
用户创建 task-list.md
    ↓
/task-scheduler start
    ↓
TeamCreate 创建调度团队
    ↓
TaskCreate × N 创建所有任务
    ↓
Agent × min(N, 4) 启动 worker
    ↓
/loop 10m /task-scheduler check（安全网）
    ↓
Worker 完成 → SendMessage 通知 lead（主路径）
    ↓          ↗ /loop check 发现状态变化（备用路径）
Lead 收到通知 → 启动下一个 Worker
    ↓
全部完成 → 停止 loop → 生成报告 → TeamDelete 清理
```

**核心优势：**
- 事件驱动为主（Agent SendMessage 通知）
- `/loop` 安全网兜底（防止通知丢失或 Agent 卡住）
- 原生 TaskList 管理状态
- 支持优雅停止（shutdown_request）

### 对比 v1.0（已弃用）

| 特性 | v1.0 (Cron) | v2.0 (Team + Loop) |
|------|-------------|---------------------|
| 主调度 | Cron 每5分钟轮询（唯一机制） | Agent SendMessage 通知（事件驱动） |
| 安全网 | 无 | `/loop 10m` 定期 check（兜底） |
| 任务管理 | scheduler-state.json | TaskCreate/TaskList |
| Agent 通信 | 无（读文件判断） | SendMessage |
| 停止机制 | CronDelete | shutdown_request + CronDelete |
| 可靠性 | 低（Cron prompt 无法调 Skill） | 高（双保险机制） |

---

## 命令参考

### `/task-scheduler start`

启动任务调度器。

**前置条件：**
- `docs/tasks/task-list.md` 存在且格式正确

**执行流程：**
1. 解析任务清单（含依赖关系）
2. 验证依赖：编号有效性 + 循环依赖检测
3. 创建 NF（工作量 >= Medium 的任务）
4. TeamCreate 创建调度团队
5. TaskCreate 创建所有任务，TaskUpdate 设置 addBlockedBy
6. 启动前 4 个无阻塞的 Agent（作为 teammate）
7. 启动 `/loop 10m /task-scheduler check` 安全网
8. 等待 Agent 通知，依赖解锁后自动调度后续任务

### `/task-scheduler check`

检查任务状态并补救调度。手动或由 `/loop` 自动触发。

**执行内容：**
- 调用 TaskList 获取实时状态
- 检测卡住的任务（in_progress 超 30 分钟无进展）
- 如有空闲槽位，启动新 Agent（安全网核心价值）
- 全部完成时自动停止 loop 并生成报告

### `/task-scheduler status`

显示当前进度（从 TaskList 读取实时数据）。

### `/task-scheduler stop`

停止调度器。

**执行内容：**
- 停止 `/loop` 安全网（CronDelete）
- 向所有运行中的 Agent 发送 shutdown_request
- TeamDelete 清理 Team 资源
- 更新 scheduler-state.json

### `/task-scheduler report`

生成详细 Markdown 报告，保存到 `docs/tasks/` 目录。

---

## 任务清单格式

### 基本格式

```markdown
- [ ] [任务描述] [优先级:High|Medium|Low] [工作量:Small|Medium|Large]
- [ ] [任务描述] [优先级:High|Medium|Low] [工作量:Small|Medium|Large] [依赖:1,2]
```

### 字段说明

**优先级：**
- `High` - 高优先级，优先启动
- `Medium` - 中优先级
- `Low` - 低优先级，最后启动

**工作量：**
- `Small` - 小型任务（< 4 小时），直接执行
- `Medium` - 中型任务（4-16 小时），创建 NF
- `Large` - 大型任务（> 16 小时），创建 NF

**依赖（可选）：**
- `[依赖:X,Y]` - 该任务依赖第 X 和第 Y 个任务
- 任务编号从 1 开始，按清单中出现的顺序分配
- 所有依赖任务完成后，该任务才会被调度
- 不允许循环依赖（启动时会自动检测）
- 省略此标签表示无依赖，可立即调度

---

## 状态文件

### `docs/tasks/scheduler-state.json`

持久化备份文件，主要状态通过 TaskList 管理：

```json
{
  "status": "running",
  "start_time": "2026-03-12T10:00:00Z",
  "team_name": "task-scheduler-1710000000",
  "tasks": [...],
  "max_concurrency": 4
}
```

**注意：** 此文件为备份，主要状态来源是 Team 的 TaskList。

---

## 错误处理

| 错误 | 解决方案 |
|------|----------|
| 任务清单不存在 | 创建 `docs/tasks/task-list.md` |
| 任务格式错误 | 检查格式：`- [ ] 描述 [优先级:X] [工作量:Y]` |
| 依赖编号无效 | 检查 `[依赖:...]` 中的编号是否在有效范围内 |
| 循环依赖 | 重新设计依赖关系，确保是有向无环图（DAG） |
| Agent 启动失败 | 检查 NF 文件，手动重试 |
| Team 创建失败 | 先运行 `/task-scheduler stop` 清理旧 Team |

---

## 限制

1. **最大并发数 4** — 过高可能导致 API 限流
2. **Agent 失败不自动重试** — 需手动处理
3. **Team 生命周期绑定会话** — 会话结束 Team 自动清理

---

## 版本历史

### v2.5 (2026-03-12)
- 移除：Slack 通知模块（用户不使用 Slack）
- 删除：`lib/slack-notifier.js` 和 `notification-config.md`

### v2.4 (2026-03-12)
- 新增：Web Dashboard 实时更新支持（WebSocket + 轮询降级）
- 新增：`web/server.js` WebSocket 服务器
- 新增：`web/index.html` 自动连接 WebSocket，实时显示状态
- 新增：单元测试（server.test.js）
- 支持：任务状态变化自动推送到浏览器
- 支持：连接状态指示器（WebSocket/Polling 模式）

### v2.3 (2026-03-12)
- 新增：Slack 通知集成（task_started / task_completed / task_failed / all_completed）

### v2.2 (2026-03-12)
- 新增：优先级队列调度算法

### v2.1 (2026-03-12)
- 新增任务依赖关系支持（`[依赖:X,Y]` 语法）
- 依赖验证：编号有效性检查 + 循环依赖检测（拓扑排序）
- 依赖感知调度：通过 TaskUpdate addBlockedBy 管理阻塞
- scheduler-state.json 增加 dependencies 和 index_to_task_id 字段

### v2.0 (2026-03-12)
- 重构为 Team 机制，替代 Cron 轮询
- Agent 完成后主动通知（SendMessage）
- 原生 TaskList 管理任务状态
- 支持 shutdown_request 优雅停止

### v1.0 (2026-03-10)
- 初始版本（Cron 轮询，已弃用）

---

**相关文档：**
- [SKILL.md 详细规范](./SKILL.md)
- [任务清单模板](../../docs/tasks/task-list-template.md)
- [带依赖关系的任务清单示例](../../docs/tasks/task-list-with-deps-example.md)
