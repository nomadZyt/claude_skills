NF-003: 为 task-scheduler 添加单元测试

状态：Planned       优先级：High
工作量：Medium  影响：确保任务调度器的稳定性和可靠性

## 问题
task-scheduler Skill 目前缺少单元测试，需要添加完整的测试覆盖。

## 方案
为任务调度器的核心功能编写单元测试：
- 任务清单解析
- NF 创建逻辑
- Agent 管理和并发控制
- 状态监控和更新
- 错误处理

## 要修改的文件
- `.claude/skills/task-scheduler/tests/` (新增) - 测试文件目录
- `.claude/skills/task-scheduler/tests/test-parser.sh` (新增) - 任务解析测试
- `.claude/skills/task-scheduler/tests/test-scheduler.sh` (新增) - 调度逻辑测试

## 验证
- [ ] 所有测试通过
- [ ] 测试覆盖率 > 80%

## 依赖项
- task-scheduler Skill 已实现

---
**创建日期：** 2026-03-10
**最后更新：** 2026-03-10
**由 task-scheduler 自动创建**
