# 更新日志

## 更新日志

### v1.3.0（2026‑04‑29）

- **单一信源一致性修复**
  - SKILL.md 步骤 0 去掉内联框架列表，改为引用 `references/tech-stack-detection.md` 作为唯一信源，与 `non-frontend-degraded.md` 保持一致

- **步骤 6d 版本号动态化**
  - 初始化日志中的版本号不再硬编码，改为读取 SKILL.md frontmatter 的 `version` 字段

- **占位符校验增强**
  - `scripts/verify-init.sh` 占位符正则扩展支持中文字符（如 `{项目名称}`），避免漏检

- **AI_RULES.md 增量更新策略**
  - 已有 AI_RULES.md 时新增「增量更新」选项（原仅支持重新生成）
  - 增量更新保留「附录 → 纠错追加规则」章节的已有条目，仅更新四类红线正文

- **USAGE.md 全面更新**
  - 同步 v1.2.0 以来所有新增特性：校验脚本、步骤 6c/6d、参考文档清单、业务特性章节
  - 新增「何时应重新执行初始化」指引（重大依赖升级、框架迁移、目录重构等触发场景）
  - 新增校验脚本使用说明和 FAQ 补充

- **页面流转分析补充 Modal/Drawer**
  - `references/page-flow-analysis.md` 新增「3b. Modal/Drawer 流转识别」子章节
  - 覆盖 CRUD 弹窗、确认弹窗、多步弹窗、级联弹窗、选择器弹窗五种 B 端常见模式
  - 核心产出新增 Modal/Drawer 模式分析项

- **业务特性识别扩展**
  - `references/business-features.md` 新增「8. 权限体系」（RBAC/按钮级权限/前端权限控制）
  - `references/business-features.md` 新增「9. 实时数据推送」（WebSocket/SSE/长轮询）
  - 关键文件速查表同步更新

- **新增斜杠命令模板**
  - 创建 `templates/commands/zacc-init-fronted.md`，修复步骤 6b 引用的源模板缺失问题

- **Monorepo 子包分析范围限定**
  - 步骤 1 新增 Monorepo 子包选择交互和后续步骤范围限定指引
  - 明确子包模式下步骤 2～6 以子包为根目录、产出文件标注初始化范围

### v1.2.0（2026‑04‑29）

- **新增产出校验脚本**
  - 新增 `scripts/verify-init.sh`，自动校验 CLAUDE.md 和 AI_RULES.md 的产出完整性
  - 检查项：占位符残留、必要章节完整性、红线规则非空、交叉一致性、模板注释清理
  - 步骤 6c 强制执行校验，FAIL 项必须修正后才能进入步骤 7

- **模板条件处理指引**
  - `CLAUDE.md.tpl` 和 `AI_RULES.md.tpl` 中每个占位符/章节添加 HTML 注释指引
  - 明确未检测到时的处理规则：填「未检测到」、整行删除、或写默认值
  - `AI_RULES.md.tpl` 新增 `{skillVersion}` 元信息字段
  - 附录章节增加「纠错追加规则」子分类结构

- **补充步骤 2/步骤 3 独立参考文档**
  - 新增 `references/project-structure-analysis.md`：扫描策略、深度控制、组织模式识别（按功能/类型/模块/路由/混合）、关键目录标注
  - 新增 `references/code-standards-extraction.md`：配置文件读取优先级（ESLint/Prettier/Biome/TS/Stylelint/EditorConfig）、命名风格推断方法、Commit 规范检测
  - SKILL.md 步骤 2/3 增加对新参考文档的引用

- **新增执行日志机制**
  - `CLAUDE.md.tpl` 底部新增「初始化日志」章节（时间、技能版本、模式、变更摘要）
  - SKILL.md 新增步骤 6d 填写初始化日志

- **业务特性映射到 CLAUDE.md**
  - `CLAUDE.md.tpl` 新增「业务特性」章节，与 `business-features.md` 分析结果对接

- **框架语法参考裁剪指引**
  - `data-flow-analysis.md` 的「框架语法参考」段添加裁剪规则：仅阅读当前项目对应框架的示例

- **统一 UI 框架检测信源**
  - `non-frontend-degraded.md` 的前端框架判定改为引用 `tech-stack-detection.md` 框架表，不再重复列举具体框架名

### v1.1.0（2026‑04‑27）

- **新增非前端降级模式**
  - 步骤 0 新增项目类型门禁：通过 `package.json` 依赖表判定是否前端项目（检测 Web UI 框架如 React / Vue / Angular / Svelte / Next / Nuxt / Umi 等）。
  - 非前端项目执行时需用户确认后进入降级模式，按 `references/non-frontend-degraded.md` 收缩分析维度。
  - 降级模式在输出摘要中显式标注初始化模式。
  - 新增 `references/non-frontend-degraded.md` 降级策略参考文档。

- **Wiki 输出目录更新**
  - 配套 `zacc-init-wiki-fronted` 将 Wiki 产出目录从 `.wiki/` 改为 `wiki/`，更新了所有相关引用。
  - 涉及文件：`SKILL.md`、`USAGE.md`。

- **新增 Wiki 技能联动检测**
  - 步骤 7 收尾时探测 `zacc-init-wiki-fronted` 是否已安装，未安装时追加提醒。

### v1.0.0（2026‑04‑16）

- **初始版本发布**
  - 六维度前端项目分析：项目信息收集、项目结构分析、代码规范提取、数据流转 + 页面流转分析、AI 红线分析、文件生成/更新。
  - 自动生成 `CLAUDE.md`（项目配置）和 `.claude/AI_RULES.md`（AI 红线规则）。
  - 支持增量更新已有 CLAUDE.md，保留用户自定义内容。
  - 纠错自学习机制：用户纠正 AI 输出时自动追加纠错记录。
  - 可选斜杠命令入口：`.claude/commands/zacc-init-fronted.md`。
  - 包含 6 份参考文档和 2 份模板文件。
