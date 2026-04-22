# 核心模块提取策略

> SOP-1 步骤 2 使用此文档。目标：从源代码目录中识别核心业务模块和基础模块。

## 原则

1. **浅扫描**：只用 Glob 扫描目录结构，不读取每个文件内容
2. **入口文件法**：只读每个模块的入口文件（index.ts / __init__.py / mod.rs）
3. **动态深度**：按项目规模自适应，不硬编码模块上限
4. **区分业务与基础**：业务模块是项目特有的；基础模块是通用工具

## 模块数量策略（动态分层）

根据候选模块总数自适应：

| 候选模块数 | 策略 | 深度节点 | 轻量节点 |
|-----------|------|---------|---------|
| <= 10 | **全量深度** — 所有模块创建完整节点 | 全部 | 无 |
| 11-20 | **自动分层** — 按评分排序，Top-10 深度扫描，其余轻量 | Top-10 | 其余 |
| 21-50 | **用户选择** — 展示排名列表，让用户选关注模块 | 用户选择 | 其余 |
| > 50 | **聚焦模式** — 用 AskUserQuestion 让用户指定关注领域 | 用户指定 | 不创建 |

**深度节点**：读取入口文件，提取公开接口，分析依赖关系，生成完整节点文件。
**轻量节点**：只记录路径、文件数、类型标记，不读取源码内容。轻量节点在用户后续需要时可通过 **zacc-wiki-fronted** 选「增量更新 → **node update**」（`--id {id}`）升级为深度节点。

## 各语言模块边界定义

### JavaScript / TypeScript

```
模块 = 含 index.ts 或 index.js 的 src/ 顶级子目录
```

**扫描步骤**：
1. `Glob("src/*/index.{ts,tsx,js,jsx}")` 列出所有一级模块
2. 如果 `src/` 按 feature 组织（`src/features/*/`），则 `Glob("src/features/*/index.{ts,tsx,js,jsx}")`
3. 如果 `src/` 按 type 组织，模块 = `src/components/`、`src/pages/`、`src/api/`、`src/store/` 等各顶级目录
4. 无 index 文件的目录如果含 3+ 个源码文件也算模块

**入口文件**：`index.ts` > `index.tsx` > `index.js` > `index.jsx` > 目录中文件数最多的 `.ts` 文件

### Java

```
模块 = src/main/java/{groupId}/{artifactId}/ 下第 3-4 层 package
```

**扫描步骤**：
1. 从 `pom.xml` 提取 `<groupId>` 和 `<artifactId>` 确定基础包路径
2. `Glob("src/main/java/{group_path}/{artifact}/*/")`  列出业务包
3. 典型业务包：`controller`、`service`、`repository`、`domain`、`config`
4. 如使用 DDD：`application`、`domain`、`infrastructure`、`interfaces`

**入口文件**：包目录下的 `*Service.java` 或 `*Controller.java`（按文件名排序取第一个）

### Go

```
模块 = 根目录下声明同一 package 的目录
```

**扫描步骤**：
1. `Glob("*/*.go")` + `Glob("cmd/*/*.go")` + `Glob("internal/*/*.go")` + `Glob("pkg/*/*.go")`
2. 每个含 `.go` 文件的目录视为一个模块
3. `cmd/` 下的子目录 = 入口模块（Entry 层）
4. `internal/` = 业务模块
5. `pkg/` = 可导出的基础模块

**入口文件**：目录中不以 `_test.go` 结尾的第一个 `.go` 文件

### Python

```
模块 = 含 __init__.py 的目录
```

**扫描步骤**：
1. `Glob("src/*/__init__.py")` 或 `Glob("{package_name}/*/__init__.py")`
2. 如使用 Django：`Glob("*/apps.py")` 识别 Django App
3. 如使用 FastAPI：`Glob("*/router*.py")` 识别路由模块

**入口文件**：`__init__.py` > `main.py` > `app.py`

### Rust

```
模块 = lib.rs 或 main.rs 中的 mod 声明
```

**扫描步骤**：
1. 读取 `src/lib.rs` 或 `src/main.rs`
2. 提取所有 `pub mod xxx;` 和 `mod xxx;` 声明
3. 每个 `mod` 对应 `src/{mod_name}/mod.rs` 或 `src/{mod_name}.rs`

**入口文件**：`mod.rs` > 同名 `.rs` 文件

## 模块排序算法

对所有候选模块执行评分排序，根据上方"模块数量策略"决定深度扫描范围：

```
score = 0.5 * import_score + 0.3 * file_score + 0.2 * git_score
```

### import_score（被引用次数）

```bash
# 用 Grep 统计其他模块引用此模块的次数
Grep: pattern="from.*{module_name}" 或 "import.*{module_name}"
import_count = 匹配行数
import_score = import_count / max_import_count  # 归一化到 0-1
```

### file_score（文件数量）

```bash
# 用 Glob 统计模块下文件数
Glob: "{module_path}/**/*.{ext}"
file_count = 匹配文件数
file_score = file_count / max_file_count  # 归一化到 0-1
```

### git_score（近 3 个月活跃度）

```bash
git log --since="3 months ago" --oneline -- {module_path} | wc -l
git_score = commit_count / max_commit_count  # 归一化到 0-1
```

## 基础模块识别

以下目录名匹配任一关键词即为基础模块（Foundation 层）：

```
utils, util, common, shared, lib, helpers, tools, core,
pkg, internal/common, internal/pkg, base, framework, infrastructure
```

基础模块创建轻量节点：
- 只记录目录路径和文件列表
- 不深入分析公开接口
- 类型标记为 `foundation`

## 公开接口提取

对每个**深度节点**模块的入口文件，提取公开接口：

| 语言 | 公开接口标识 |
|------|-----------|
| JS/TS | `export function/class/const/default` |
| Java | `public class/interface/method`（排除 getter/setter） |
| Go | 大写字母开头的 func/type/var |
| Python | `__all__` 列表内容，或非 `_` 开头的函数/类 |
| Rust | `pub fn/struct/enum/trait` |

提取时只需名称和简要签名，不需要完整实现代码。
