# /nf-close - 关闭并归档 NF

## 目的
完成 NF：更新状态、归档文件、更新变更日志。

## 前置条件
- NF 状态应为"Complete"或"Pending Verification"
- 所有验证步骤应通过

## 步骤

### 1. 确认 NF 编号
如果未指定，询问用户要关闭哪个 NF：
```
你想关闭哪个 NF？
```

### 2. 更新 FEATURE_INDEX.md
- 将条目从"进行中的功能"移动到"已完成"
- 添加完成日期
- 如果存在，从"待验证"中移除

### 3. 归档 NF 文件
```bash
mv docs/features/NF-XXX-*.md docs/features/archive/
```

### 4. 更新 CHANGELOG.md
追加条目：
```markdown
## [{{date}}]

### 新增
- NF-XXX: [功能名称] - [简短描述]

### 修改
- [任何修改]

### 修复
- [任何修复]
```

如果 CHANGELOG.md 不存在，用 Keep a Changelog 格式创建它。

### 5. 更新 NF 文件（归档前）
在 NF 文件底部添加：
```markdown
---
**完成日期：** {{date}}
**总结：** [简短总结实现的内容]
**备注：** [任何后续事项或技术债务]
```

### 6. 确认
```
✅ NF-XXX 已关闭并归档

📄 已归档：docs/features/archive/NF-XXX-*.md
📊 索引已更新
📝 变更日志已更新

下一步？
- 开始 NF-YYY 实现
- 创建新 NF
```

## 边界情况

- NF 未完成 → 警告用户，要求先验证
- 有未提交的更改 → 提醒用户在关闭前提交
