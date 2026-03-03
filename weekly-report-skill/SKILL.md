---
name: weekly_report_generator
description: 自动收集 Git 日志并根据业务映射生成规范周报。当用户提到“写周报”、“整理本周进展”时触发。
dependencies: python>=3.8
---

# Weekly Report Skill

你的职责是：

当用户请求"生成周报 / 本周做了什么 / 输出周报"时：

**处理流程：**
1. 调用脚本`scripts/collect_commits.py`收集 Git 提交记录（仅处理【用户本人】的 commit）在skill目录下生成`commits_data.json`
2. 调用脚本`scripts/analyze_commits.py`基于commit记录`commits_data.json`进行以下分析并在在skill目录下生成`analysis_result_with_diff.json`：
   - 仓库名
   - 文件完整路径
   - commit message
   - 修改对比
3. 根据上述代码分析产生的结果`analysis_result_with_diff.json`自动完成，一定要等待该文件生成结束再进行下面操作：
   - 项目识别
   - 工作类型分类
   - 梳理当前 commit 的代码流程
   - 结合代码的diff信息进行梳理，标记处重点改动内容
   - 价值抽象
4. 使用统一事实数据和第3步骤的分析结果，基于当前大模型分析处理（不使用任何脚本）,按照`OUTPUT_TEMPLATE.md`模板生成，
   - 对上汇报版 Markdown，并在当前目录输出文件,文件命名为[生成日期]_[当前周期]_[leader]
   - 对内同步版 Markdown，并在当前目录输出文件,包含更为详细的内容，以及在第3步骤中标记的重点改动内容进行diff输出，文件命名为[生成日期]_[当前周期]_[self]
5. 对脚本的执行以及分析进行记录
   - 所有执行步骤会记录到 `weekly-report.log` 文件中
   - 控制台会实时显示执行进度和结果
   - 日志包含：时间戳、执行步骤、提交数量、项目分类统计等

规则约束：

- 不编造未发生的工作
- 不放大 merge / sync 类提交
- 表述偏结果与价值，而非过程细节

当信息不足时：

- 使用“项目级别 + 工作类型”进行保守归类
- 不要求用户补充说明
