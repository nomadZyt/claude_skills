# 更新日志

## 更新日志

### v1.0.0（2026‑04‑16）

- **初始版本发布**
  - 双能力架构：项目初始化（规则下沉 + 目录创建）+ 根据 PRD 生成 HTML 原型。
  - 项目初始化：自动检测已有状态，增量写入 CLAUDE.md 规则小节和 `.cursor/rules/zacc-prd-init-html.mdc`，创建 `prototype/` 目录，幂等执行不覆盖已有内容。
  - 原型生成：读取 PRD/md 文件，按结构化中间协议生成 HTML 原型（Structural Metadata / Zero Visual Noise / Modular Chunking / Chunk Annotation / Semantic HTML / Business Logic in Comments）。
  - 多文件联动：`index.html` 作为 SPA 容器，通过 JS 动态加载子模块，子模块独立可运行且通过 `navigate()` 跨模块跳转。
  - 已有 HTML 保护：`prototype/` 下已有 HTML 文件须用户明确同意后才按规则对齐，不自动改写。
  - 覆盖检查：目标文件已存在时必须询问用户，覆盖写入不拼接追加。
  - 包含 1 份参考文档（`references/rules.md`）和 1 份模板文件。
