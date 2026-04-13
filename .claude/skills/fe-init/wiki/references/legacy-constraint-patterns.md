# 历史包袱识别模式

> SOP-2 使用此文档。目标：识别代码中的技术债、逻辑矛盾、不可触碰的遗留逻辑。

## 信号检测

使用 Grep 检测以下信号。当 AI 在编码过程中遇到这些信号时，应建议用 `/wiki-update legacy` 记录。

### 直接标记信号

| 信号类别 | Grep 模式 | 说明 |
|---------|----------|------|
| TODO | `TODO\|FIXME\|HACK\|XXX` | 开发者留下的待办标记 |
| 警告注释 | `WORKAROUND\|TEMP\|TEMPORARY` | 临时方案标记 |
| 保留警告 | `DO NOT MODIFY\|DO NOT DELETE\|DO NOT REMOVE\|KEEP THIS\|DON'T TOUCH` | 强制保留标记 |
| 废弃标记 | `@deprecated\|@obsolete\|DEPRECATED` | 正式废弃声明 |

### 间接结构信号

| 信号类别 | Grep 模式 | 说明 |
|---------|----------|------|
| 版本兼容 | `legacy\|compat\|v1\|v2\|oldApi\|newApi` | 新旧版本共存 |
| 特性开关 | `featureFlag\|killSwitch\|toggle\|isEnabled` | 运行时开关 |
| 条件分支 | `isLegacyMode\|useFallback\|useOldBehavior` | 遗留模式判断 |
| API 版本共存 | `/v1/.*` 和 `/v2/.*` 在同一代码库 | 多版本 API |
| 重复实现 | 同名函数出现在不同模块 | 代码分裂 |

### 矛盾信号

| 信号 | 检测方法 | 说明 |
|------|---------|------|
| 注释与代码不符 | AI 在阅读代码时判断 | 注释说"不可能为空"但代码做了空判断 |
| 测试被跳过 | `@Ignore\|skip\|xit\|xdescribe\|@Disabled` | 有测试但被禁用 |
| 死代码 | 函数声明但无引用 | unreachable code |

## 严重程度分级

| 级别 | 定义 | 示例 |
|------|------|------|
| **Critical** | 修改会导致系统故障或数据丢失 | `DO NOT DELETE - 删除会导致支付回调失败` |
| **Warning** | 修改需要额外测试验证 | `这个 v1 API 还有 5 个外部系统在调用` |
| **Info** | 已知技术债，非紧急 | `TODO: 重构为使用新的缓存框架` |

## 分级判定规则

1. 涉及金钱/支付/安全 → **Critical**
2. 涉及外部系统对接/数据库 Schema → **Critical**
3. `DO NOT` 系列注释 → **Critical**
4. 版本兼容代码仍有流量 → **Warning**
5. 被跳过的测试 → **Warning**
6. 一般 TODO/FIXME → **Info**
7. 代码风格问题 → **Info**

## 记录格式

使用 `templates/wiki-legacy-section.md.tpl` 模板：

```markdown
### LC-{number}: {constraint_title}

- **Current_State**: {代码的实际当前行为}
- **Do_Not_Touch**: {禁止修改的部分及原因}
- **Context**: {为什么代码是这样的历史原因/业务背景}
- **Severity**: {Info|Warning|Critical}
- **Recorded**: {YYYY-MM-DD}
- **Reporter**: {AI|User}
```

## AI 自动建议流程

当 AI 在编码过程中检测到上述信号时：

1. 暂停当前操作
2. 用 AskUserQuestion 提示：
   ```
   检测到疑似历史包袱：
   - 文件：{file_path}:{line}
   - 信号：{signal_type}
   - 内容：{code_snippet}

   是否记录为 Legacy Constraint？
   选项：
   1. 是，记录为 Critical
   2. 是，记录为 Warning
   3. 是，记录为 Info
   4. 跳过，不记录
   ```
3. 根据用户选择，执行 `/wiki-update legacy`
4. 继续原来的编码任务

## 批量扫描模式

执行 `/wiki-update scan` 时，可选启用批量历史包袱扫描：

1. 对每个节点对应的源目录，执行上述 Grep 模式
2. 汇总所有匹配结果
3. 按严重程度排序展示
4. 让用户批量确认哪些需要记录
