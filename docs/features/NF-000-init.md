NF-000: NF 系统初始化

状态：Complete      优先级：High
工作量：Small       影响：开发工作流基础

## 问题
需要结构化的方法来管理 AI Agent 的功能开发。

## 方案
实现 NF (New Feature) 系统：
1. 创建 docs/features/ 目录结构
2. 创建 FEATURE_INDEX.md 用于追踪
3. 创建 NF 模板
4. 安装 6 个斜杠命令
5. 更新 CLAUDE.md 约定
6. 自动检测项目技术栈

## 修改的文件
- docs/features/FEATURE_INDEX.md (新增)
- docs/features/TEMPLATE.md (新增)
- docs/dev_guide/README.md (新增)
- .claude/commands/nf-*.md (新增 6 个)
- CLAUDE.md (修改)

## 验证
- [x] 目录结构已创建
- [x] 所有文件到位
- [x] 斜杠命令已安装
- [x] 技术栈已自动检测

---
创建日期：2026-03-10
完成日期：2026-03-10
