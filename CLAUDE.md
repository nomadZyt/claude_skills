# 项目约定

## 技术栈
- Unknown

## Commit 规范
- 格式：`NF-XXX: [动词] [描述]`
- 示例：`NF-001: 添加用户登录组件`
- 动词用现在时：add, update, fix, refactor

## 代码规范
- 遵循项目已有代码风格
- 保持一致性
- 添加必要的注释

## 测试
- 测试框架：[待配置]
- 运行测试：[待配置]

---

## NF 系统

### 规则
- 所有功能开发先创建 NF 文件（>4 小时的工作）
- NF 状态流转：Planned → Design → Open → In Progress → Pending Verification → Complete
- 每个 commit 关联 NF 编号
- 完成后更新 FEATURE_INDEX.md 并归档

### 命令
- `/nf-new` - 创建新 NF
- `/nf-status` - 查看所有 NF 状态
- `/nf-explore` - 加载项目上下文
- `/nf-verify` - 验证代码
- `/nf-close` - 关闭并归档 NF
- `/nf-deep` - 并行深度分析（复杂问题）
- `/task-scheduler` - 多任务并发调度器（自动管理多个 NF）

### 文件位置
- NF 索引：`docs/features/FEATURE_INDEX.md`
- NF 模板：`docs/features/TEMPLATE.md`
- NF 文件：`docs/features/NF-XXX-*.md`
- 归档目录：`docs/features/archive/`
- 开发规范：`docs/dev_guide/`
