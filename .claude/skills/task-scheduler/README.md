# Task Scheduler - 多任务并发调度器

自动化管理多个开发任务的并发执行，充分利用 Claude 的并发能力。

## 快速开始

### 1. 创建任务清单

复制模板并填写你的任务：

```bash
cp docs/tasks/task-list-template.md docs/tasks/task-list.md
```

编辑 `docs/tasks/task-list.md`：

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

调度器将：
- ✅ 为每个任务创建 NF
- ✅ 启动最多 4 个并发 Agent
- ✅ 每 5 分钟检查状态
- ✅ 自动启动新任务

### 3. 监控进度

```bash
/task-scheduler status
```

### 4. 查看报告

```bash
/task-scheduler report
```

---

## 功能特性

### 🤖 自动化
- 自动创建 NF 文件
- 自动分配 Agent
- 自动状态监控
- 自动启动新任务

### ⚡ 并发执行
- 最多 4 个 Agent 同时运行
- 智能调度算法
- 队列管理

### 📊 进度跟踪
- 实时状态显示
- 详细执行报告
- 性能分析

### 🔄 循环监控
- 使用 `/loop` 定期检查
- 自动检测完成
- 自动启动下一个

---

## 命令参考

### `/task-scheduler start`

启动任务调度器。

**前置条件：**
- `docs/tasks/task-list.md` 存在
- NF 系统已初始化

**执行流程：**
1. 解析任务清单
2. 创建所有 NF
3. 启动前 4 个 Agent
4. 启动循环监控（每 5 分钟）

### `/task-scheduler check`

手动检查任务状态（通常由 `/loop` 自动调用）。

**执行内容：**
- 读取所有 NF 状态
- 检测完成的任务
- 启动新 Agent（如有空位）
- 更新状态文件

### `/task-scheduler status`

显示当前进度。

**显示内容：**
- 调度器状态
- 运行时长
- 进度百分比
- 每个任务的详细状态

### `/task-scheduler stop`

停止调度器。

**注意：**
- 已运行的 Agent 不会停止
- 停止循环监控
- 停止新任务启动

### `/task-scheduler report`

生成详细报告。

**报告包含：**
- 执行概览
- 每个任务的详情
- 性能分析
- 改进建议

---

## 任务清单格式

### 基本格式

```markdown
- [ ] [任务描述] [优先级:High|Medium|Low] [工作量:Small|Medium|Large]
```

### 示例

```markdown
## 待处理
- [ ] 添加用户认证功能 [优先级:High] [工作量:Large]
- [ ] 优化数据库查询 [优先级:Medium] [工作量:Medium]
- [ ] 更新 README 文档 [优先级:Low] [工作量:Small]
- [ ] 添加单元测试 [优先级:High] [工作量:Medium]
- [ ] 修复登录页面 bug [优先级:High] [工作量:Small]
```

### 字段说明

**优先级：**
- `High` - 高优先级，重要且紧急
- `Medium` - 中优先级，重要但不紧急
- `Low` - 低优先级，可以延后

**工作量：**
- `Small` - 小型任务（< 4 小时）
- `Medium` - 中型任务（4-16 小时）
- `Large` - 大型任务（> 16 小时）

---

## 状态文件

### `docs/tasks/scheduler-state.json`

调度器的持久化状态，包含：

```json
{
  "status": "running",
  "start_time": "2026-03-10T16:30:00Z",
  "cron_job_id": "cron-123",
  "tasks": [...],
  "running_agents": [...],
  "completed_tasks": [...],
  "failed_tasks": [...]
}
```

**字段说明：**
- `status`: running | stopped | completed
- `tasks`: 所有任务的详细信息
- `running_agents`: 当前运行的 Agent 列表
- `completed_tasks`: 已完成的任务 ID 列表
- `failed_tasks`: 失败的任务信息

### 手动修改状态文件

⚠️ **不推荐** 手动修改状态文件，除非：
- 调度器状态异常
- 需要强制恢复
- 需要取消某个任务

修改后运行 `/task-scheduler start` 恢复。

---

## 工作流程

### 完整流程

```
1. 用户创建 task-list.md
    ↓
2. 运行 /task-scheduler start
    ↓
3. 调度器解析任务清单
    ↓
4. 为每个任务调用 /nf-new 创建 NF
    ↓
5. 启动前 4 个 Agent
    ↓
6. 启动循环监控（/loop 5m）
    ↓
7. 每 5 分钟检查 NF 状态
    ↓
8. 检测到任务完成 → 启动新 Agent
    ↓
9. 重复步骤 7-8 直到所有任务完成
    ↓
10. 生成最终报告
```

### 并发调度逻辑

```
pending_queue: [Task1, Task2, Task3, Task4, Task5, Task6]
running_agents: [] (max 4)

初始启动：
running_agents: [Task1, Task2, Task3, Task4]
pending_queue: [Task5, Task6]

Task1 完成：
running_agents: [Task2, Task3, Task4, Task5]
pending_queue: [Task6]

Task2, Task3 完成：
running_agents: [Task4, Task5, Task6]
pending_queue: []

全部完成：
running_agents: []
completed_tasks: [Task1, Task2, Task3, Task4, Task5, Task6]
```

---

## 错误处理

### 常见问题

#### 1. 任务清单文件不存在

**错误信息：**
```
❌ 错误：找不到任务清单文件
```

**解决方案：**
```bash
cp docs/tasks/task-list-template.md docs/tasks/task-list.md
# 编辑 task-list.md 添加你的任务
```

#### 2. 任务格式错误

**错误信息：**
```
⚠️ 任务格式错误
- 第 3 行：缺少优先级标签
```

**解决方案：**
确保任务格式正确：
```markdown
- [ ] 任务描述 [优先级:High] [工作量:Medium]
```

#### 3. Agent 启动失败

**错误信息：**
```
❌ Agent 启动失败：Task #3 (NF-005)
```

**解决方案：**
- 检查 NF 文件是否正确创建
- 查看错误日志
- 手动创建 Agent 测试

#### 4. 状态文件损坏

**错误信息：**
```
❌ 状态文件损坏
```

**解决方案：**
```bash
# 备份现有状态
cp docs/tasks/scheduler-state.json docs/tasks/scheduler-state.backup.json

# 删除损坏的状态文件
rm docs/tasks/scheduler-state.json

# 重新启动调度器
/task-scheduler start
```

---

## 高级用法

### 自定义检查间隔

默认每 5 分钟检查一次，可以修改：

```markdown
在 SKILL.md 中修改 cron 表达式：
"*/5 * * * *"  # 每 5 分钟
"*/10 * * * *" # 每 10 分钟
"*/2 * * * *"  # 每 2 分钟
```

### 调整并发数

默认最多 4 个并发 Agent，可以修改：

```markdown
在 SKILL.md 的并发控制逻辑中修改：
len(running_agents) < 4  # 改为 6 或其他值
```

⚠️ **注意：** 并发数过高可能导致：
- API 限流
- 资源占用过多
- 上下文冲突

### 优先级排序

当前按任务顺序执行，可以实现优先级排序：

```python
# 伪代码
pending_tasks.sort(key=lambda t: priority_map[t.priority])
# High: 0, Medium: 1, Low: 2
```

---

## 性能优化建议

### 1. 合理拆分任务

- ✅ 好：任务大小适中（4-16 小时）
- ❌ 差：单个任务过大（>2 天）

**原因：** 大任务会长时间占用 Agent 槽位，降低并发效率。

### 2. 控制并发数

- ✅ 好：4 个并发
- ⚠️ 可选：6 个并发（高配额用户）
- ❌ 差：>8 个并发（容易触发限流）

### 3. 设置合理的检查间隔

- ✅ 好：5 分钟（默认）
- ⚠️ 可选：3 分钟（任务较小时）
- ❌ 差：1 分钟（过于频繁）

---

## 限制和注意事项

### 当前限制

1. **不支持任务依赖**
   - 任务按顺序或优先级执行
   - 无法指定 "Task B 依赖 Task A"

2. **不支持任务取消**
   - 已启动的 Agent 无法强制停止
   - 只能停止调度器

3. **有限的错误恢复**
   - Agent 失败不会自动重试
   - 需要手动处理失败任务

### 后续改进

- [ ] 支持任务依赖关系（DAG）
- [ ] 支持任务取消和重启
- [ ] 自动重试失败任务
- [ ] 实时 Web UI
- [ ] 通知集成（Slack/Email）

---

## 常见问题 (FAQ)

### Q: 可以同时运行多少个任务？

A: 默认最多 4 个并发 Agent。可以修改，但不推荐超过 6 个。

### Q: 任务会按什么顺序执行？

A: 默认按任务清单中的顺序。未来版本会支持优先级排序。

### Q: 如何暂停调度器？

A: 运行 `/task-scheduler stop`。已运行的 Agent 不会停止。

### Q: 如何恢复执行？

A: 运行 `/task-scheduler start`。调度器会从上次状态恢复。

### Q: Agent 失败了怎么办？

A: 调度器会标记为失败并继续处理其他任务。需要手动修复后重新运行。

### Q: 可以修改正在运行的任务吗？

A: 不推荐。可以停止调度器，修改状态文件，然后重新启动。

### Q: 状态文件会自动清理吗？

A: 不会。需要手动删除或归档旧的状态文件。

---

## 贡献指南

欢迎改进和扩展功能！

**改进方向：**
- 任务依赖关系支持
- 优先级队列实现
- Web UI 界面
- 更智能的调度算法
- 更好的错误恢复

---

## 版本历史

### v1.0 (2026-03-10)
- ✨ 初始版本
- ✅ 支持基本任务调度
- ✅ 支持并发控制（最多 4 个）
- ✅ 支持循环监控
- ✅ 支持状态报告

---

## 许可证

MIT License

---

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。

**相关文档：**
- [NF-002 设计文档](../docs/features/NF-002-task-scheduler.md)
- [SKILL.md 详细规范](./SKILL.md)
- [任务清单模板](../docs/tasks/task-list-template.md)
