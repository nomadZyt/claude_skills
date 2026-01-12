# Weekly Report Skill

## 使用方式


### Claude 中

> 使用 weekly-report skill 生成本周周报

### 输出结果

- 自动生成 Markdown 文件

- 同时包含：
    - 对上汇报版本
    - 对内同步版本
---

### 执行流程

```text
用户触发
  ↓
收集 Git 提交（仅本人）
  ↓
提取 repo / path / message
  ↓
项目自动识别
  ↓
工作类型分类
  ↓
去噪 & 合并
  ↓
生成两套 Markdown
```
