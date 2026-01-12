# 执行追踪说明

## 如何知道脚本是否被调用

### 方法 1: 查看日志文件

执行 skill 后，会在**脚本所在目录**（skill 根目录）生成 `weekly-report.log` 文件，包含详细的执行记录：

```bash
# 查看完整日志
cat weekly-report.log

# 或查看最后几行
tail -20 weekly-report.log

# 实时查看（如果脚本正在运行）
tail -f weekly-report.log
```

**日志文件位置：**
- 位置：在 skill 根目录下的 `weekly-report.log`
- 说明：无论从哪个目录运行脚本，日志文件都会创建在 `main.py` 所在的目录中

**日志内容包括：**
- 脚本启动信息（工作目录、脚本目录）
- 执行时间戳
- 每个步骤的开始和结束
- 收集到的提交数量
- 项目分类统计
- 错误信息（如果有）

**如果日志文件没有生成：**
1. 检查脚本是否真的被执行了
2. 检查脚本目录的写入权限
3. 运行测试脚本验证：`python3 test_log.py`

### 方法 2: 查看控制台输出

执行 `main.py` 时，控制台会实时显示执行进度：

```
2024-01-15 10:00:00 [INFO] ============================================================
2024-01-15 10:00:00 [INFO] 开始执行周报生成流程
2024-01-15 10:00:00 [INFO] ============================================================
2024-01-15 10:00:00 [INFO] 
[步骤 1/3] 收集 Git 提交记录...
2024-01-15 10:00:00 [INFO] 作者邮箱: user@example.com
2024-01-15 10:00:00 [INFO] 扫描仓库: ['.']
...
```

### 方法 3: 检查输出文件

如果脚本成功执行，会生成以下文件：
- `weekly-report-internal.md` - 对内同步版本
- `weekly-report-lead.md` - 对上汇报版本

如果这些文件存在且内容不为空，说明脚本已成功执行。

### 方法 4: 在代码中添加调试信息

如果需要更详细的追踪，可以在各个脚本中添加 `print` 或 `logger` 语句：

```python
# 在 collect_commits.py 中
def get_commits(repo_path: str, author_email: str) -> List[Dict]:
    print(f"[DEBUG] 开始收集提交: repo={repo_path}, author={author_email}")
    # ... 代码 ...
    print(f"[DEBUG] 收集完成，共 {len(commits)} 个提交")
    return commits
```

## 执行流程追踪

完整的执行流程如下：

```
用户触发 skill
  ↓
Claude 读取 SKILL.md
  ↓
[日志] [步骤 1/3] 收集 Git 提交记录...
  ↓
调用: collect_commits.get_commits()
  ↓
[日志] 总共收集到 N 个提交
  ↓
[日志] [步骤 2/3] 分析和分类提交...
  ↓
调用: analyze_commits.enrich_commits()
  ↓
[日志] 分析完成，共 N 个提交
  ↓
[日志] [步骤 3/3] 生成 Markdown 报告...
  ↓
[日志] 报告已生成
  ↓
[日志] 周报生成完成！
```

## 常见问题

### Q: 如何确认脚本是否被调用？

A: 检查以下内容：
1. 是否存在 `weekly-report.log` 文件
2. 日志文件中是否有执行记录
3. 是否生成了输出文件（`weekly-report-internal.md` 和 `weekly-report-lead.md`）

### Q: 日志文件在哪里？

A: 在脚本所在目录（skill 根目录）下，文件名为 `weekly-report.log`。即使从其他目录运行脚本，日志文件也会创建在 `main.py` 所在的目录中。

**路径说明：** `weekly-report-skill/weekly-report.log`（相对于 skill 根目录）

### Q: 为什么日志文件没有生成？

A: 可能的原因：
1. **脚本还没有被执行** - 检查是否真的调用了 `main.py`
2. **权限问题** - 检查脚本目录是否有写入权限
3. **导入错误** - 如果脚本在导入模块时就失败了，可能还没配置日志就退出了

**排查步骤：**
```bash
# 1. 进入 skill 目录
cd .claude/skills/weekly-report-skill

# 2. 测试日志功能
python3 test_log.py

# 3. 检查文件是否存在
ls -lh weekly-report.log

# 4. 手动运行主脚本
python3 main.py
```

### Q: 如何查看详细的执行信息？

A: 日志级别已设置为 `INFO`，会记录所有关键步骤。如果需要更详细的信息，可以修改 `main.py` 中的日志级别为 `DEBUG`
