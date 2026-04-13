# /wiki-query — 架构感知查询

## 目的

基于 Wiki 知识图谱回答项目架构相关问题，确保建议尊重依赖关系和历史包袱。

## 用法

```
/wiki-query 如何修改用户登录逻辑
/wiki-query 支付模块的上下游有哪些
/wiki-query 哪些模块依赖数据库模块
```

## 硬规则（不可违反）

1. **禁止** 未读 `.wiki/index.md` 直接读 `src/` 给建议
2. **必须** 先读 `.wiki/index.md`
3. **必须** 追踪上下游依赖至少一层
4. **必须** 合并相关节点的 Legacy Constraints 到回答中

## 步骤

读取 `.claude/skills/fe-init/wiki/WIKI.md` 的 SOP-3 部分，按以下流程执行：

1. **加载 Wiki 索引** — 读取 `.wiki/index.md`（如不存在，提示先执行 `/wiki-init`）
2. **定位相关节点** — 匹配用户问题关键词到节点的 title/path/exports
3. **追踪上下游** — 读取匹配节点的 dependencies 和 dependents，加载邻居节点
4. **合并历史包袱** — 检查所有相关节点的 Legacy Constraints
5. **输出结果** — 相关模块表 + 依赖影响图 + 历史包袱提醒 + 修改建议 + 影响范围
