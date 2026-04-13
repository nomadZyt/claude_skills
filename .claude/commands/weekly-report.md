# /weekly-report — 众安车险周报生成器

## 目的

根据用户提供的数据，生成符合众安车险品牌风格的 HTML 周报页面。

## 步骤

读取 `.claude/skills/weekly-report/SKILL.md` 并按以下流程执行：

1. **获取数据** — 从用户对话输入或指定文件中获取周报数据
2. **校验必填项** — 检查日期范围和核心数据是否齐全，**缺失时主动询问用户补充**
3. **提醒建议项** — 品牌曝光、投放转化、下周计划缺失时，提醒用户是否需要补充
4. **读取模板** — 读取 `templates/weekly-report-template.html` 作为参考
5. **生成 HTML** — 根据数据动态构建各模块 HTML 内容
6. **输出文件** — 保存到 `output/weekly-report-{YYYY-MM-DD}.html`
7. **预览** — 在浏览器中打开预览（如可用）

## 参数

- 无参数时：提示用户输入周报数据
- 带文件路径时：从指定文件读取数据（如 `/weekly-report data.md`）
- 用户已在对话中提供数据时：直接解析生成

## 参考文件

- `templates/weekly-report-template.html` — HTML 周报模板
