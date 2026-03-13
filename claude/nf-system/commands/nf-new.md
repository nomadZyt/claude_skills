# /nf-new - 创建新 New Feature

## 目的
从用户的想法或需求创建新的 NF（New Feature）文件。

## 步骤

### 1. 读取并校验索引
- 读取 `docs/features/FEATURE_INDEX.md`
- **格式校验**：验证表格结构完整（表头、分隔行、列数一致）
- 如果格式异常，先提示用户修复后再创建新 NF
- 找到最大的 NF 编号
- 下一个 = 最大 + 1

### 2. 从用户收集需求
如果未提供则询问：
- 要解决什么问题？
- 优先级：High / Medium / Low？
- 预估工作量：Small (<4h) / Medium (4-16h) / Large (>16h)？

### 3. 创建 NF 文件
- 路径：`docs/features/NF-XXX-[slug].md`
- 使用 TEMPLATE.md 作为模板
- 填充所有章节

### 4. 更新 FEATURE_INDEX.md
- 在"进行中的功能"表格中添加条目
- 状态设为"Planned"

### 5. 向用户确认
```
✅ 已创建 NF-XXX: [标题]
📄 文件：docs/features/NF-XXX-[slug].md
📊 状态：Planned
下一步：运行 /nf-explore 然后开始设计
```

## 交互示例

**用户：** 帮我创建 NF，要做个深色模式切换功能

**你：**
1. 必要时问澄清问题
2. 创建 `NF-001-dark-mode.md`
3. 返回确认信息

## 边界情况

- 如果 `docs/features/` 不存在 → 先运行 nf-init
- 如果用户提供的信息很少 → 创建骨架 NF，章节标记为"TBD"
- 如果 FEATURE_INDEX.md 格式损坏 → 提示修复后再创建
