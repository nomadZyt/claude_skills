# 优先级队列调度算法

## 概述

task-scheduler 使用优先级队列对 pending 任务进行排序，确保高优先级任务优先获得 Agent 资源。该算法在以下场景中被使用：

- **步骤 5**：初始启动时选取首批 Agent
- **步骤 9**：Agent 完成后调度下一批任务
- **check 命令**：补救调度时选取任务

## 优先级权重

| 优先级 | 权重 | 说明 |
|--------|------|------|
| High   | 3    | 紧急/关键任务，优先执行 |
| Medium | 2    | 常规任务 |
| Low    | 1    | 低优先级/可延迟任务 |

## 排序规则

1. **按优先级权重降序排列**：High(3) > Medium(2) > Low(1)
2. **同优先级按任务 ID 升序排列**：先创建的任务先执行（FIFO）
3. **被阻塞任务跳过**：`blockedBy` 中有未完成任务的不参与排序

## 算法伪代码

```
function selectNextTasks(allTasks, maxConcurrency):
    // 1. 计算可用 Agent 槽位
    inProgressCount = allTasks.filter(t => t.status == "in_progress").length
    maxSlots = maxConcurrency - inProgressCount

    if maxSlots <= 0:
        return []

    // 2. 筛选可调度的 pending 任务
    schedulable = allTasks
        .filter(t => t.status == "pending")
        .filter(t => t.blockedBy.length == 0)  // 无未完成的依赖

    // 3. 按优先级队列排序
    priorityWeight = { "High": 3, "Medium": 2, "Low": 1 }

    schedulable.sort((a, b) => {
        // 先按优先级权重降序
        weightDiff = priorityWeight[b.priority] - priorityWeight[a.priority]
        if weightDiff != 0:
            return weightDiff

        // 同优先级按任务 ID 升序（先创建先执行）
        return a.task_id - b.task_id
    })

    // 4. 取前 maxSlots 个
    return schedulable.slice(0, maxSlots)
```

## 示例

假设有以下 pending 任务（当前 1 个 in_progress，最大并发 4）：

| 任务 ID | 描述 | 优先级 | blockedBy |
|---------|------|--------|-----------|
| 3 | 修复登录 bug | High | [] |
| 5 | 添加单元测试 | Medium | [3] |
| 7 | 优化性能 | High | [] |
| 8 | 更新文档 | Low | [] |
| 9 | 重构代码 | Medium | [] |

排序结果（可调度，排除 #5 因为被 #3 阻塞）：

1. #3 - High, ID=3
2. #7 - High, ID=7
3. #9 - Medium, ID=9
4. #8 - Low, ID=8

可用槽位 = 4 - 1 = 3，所以启动 #3、#7、#9。

当 #3 完成后，#5 的 blockedBy 清空，下次调度时 #5 变为可调度状态。

## 与依赖系统的配合

优先级队列与任务依赖系统协同工作：

- 依赖系统通过 `blockedBy` 控制任务的**可调度性**
- 优先级队列在可调度任务中决定**执行顺序**
- 当依赖任务完成后，被解锁的任务按其优先级重新参与排序

## 复杂度

- 时间复杂度：O(n log n)，其中 n 为 pending 任务数（排序主导）
- 空间复杂度：O(n)，筛选后的任务数组
