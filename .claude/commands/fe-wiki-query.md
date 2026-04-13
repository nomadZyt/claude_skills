# /fe-wiki-query — 架构感知查询

## 目的

基于 `.wiki/` 知识图谱回答项目架构问题。确保修改建议尊重依赖关系和历史包袱。

## 用法

```
/fe-wiki-query 如何修改用户登录逻辑
/fe-wiki-query 支付模块的上下游有哪些
```

## 硬规则

1. **禁止** 未读 Wiki 直接读 `src/` 给建议
2. **必须** 先读 `.wiki/index.md`
3. **必须** 追踪上下游依赖至少一层
4. **必须** 合并 Legacy Constraints 到回答中

## 步骤

读取 `.claude/skills/fe-init/wiki/WIKI.md` 的 SOP-3 部分并按流程执行：

1. **加载索引** — `.wiki/index.md`
2. **定位节点** — 匹配关键词到 title/path/exports
3. **追踪依赖** — 加载邻居节点
4. **合并历史包袱** — 检查所有相关节点
5. **输出结果** — 模块表 + 影响图 + 历史包袱 + 建议 + 影响范围
