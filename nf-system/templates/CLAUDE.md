# 项目约定

## 技术栈
- React 18 + TypeScript
- TailwindCSS
- Vite

## Commit 规范
- 格式：`NF-XXX: [动词] [描述]`
- 示例：`NF-001: 添加用户登录组件`
- 动词用现在时：add, update, fix, refactor

## 代码规范
- 组件用函数式 + hooks
- 类型定义放在 `src/types/`
- 测试文件与源码同级：`ComponentName.test.tsx`
- 避免 `any` 类型，用 `unknown` 或具体类型

## 测试
- 单元测试覆盖率 > 80%
- 用 Vitest + React Testing Library
- E2E 用 Playwright

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

### 文件位置
- NF 索引：`docs/features/FEATURE_INDEX.md`
- NF 模板：`docs/features/TEMPLATE.md`
- NF 文件：`docs/features/NF-XXX-*.md`
- 归档目录：`docs/features/archive/`
- 开发规范：`docs/dev_guide/`
