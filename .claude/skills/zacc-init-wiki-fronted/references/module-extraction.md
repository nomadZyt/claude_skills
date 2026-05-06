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
| <= 15 | **全量深度** — 所有模块创建完整节点 | 全部 | 无 |
| 16-30 | **自动分层** — 按评分排序，Top-20 深度扫描，其余轻量 | Top-20 | 其余 |
| 31-60 | **自动分层+用户确认** — Top-30 深度扫描，其余轻量；展示列表让用户确认 | Top-30 | 其余 |
| > 60 | **聚焦模式** — 用 AskUserQuestion 让用户指定关注领域 | 用户指定 | 不创建 |

**调整说明：**
- 提高全量深度阈值（10 → 15）：前端项目模块数通常更多
- 提高自动分层阈值（20 → 30）：减少用户交互频率
- 新增 31-60 档位：覆盖典型中型前端项目

**深度节点**：读取入口文件，提取公开接口，分析依赖关系，生成完整节点文件。
**轻量节点**：只记录路径、文件数、类型标记，不读取源码内容。轻量节点在用户后续需要时可通过 **zacc-init-wiki-fronted** 选「增量更新 → **node update**」（`--id {id}`）升级为深度节点。

## 各语言模块边界定义

### JavaScript / TypeScript

前端项目通常采用 **type-organized** 结构（`src/components/`、`src/pages/`、`src/api/` 等）。提取策略需区分 **容器目录** 与 **实际模块**。

> **注意**：如果 `project_type` 为 `taro-miniprogram` 或 `taro-multi-platform`，应使用下方 Taro 专用容器目录和扫描步骤，而非本节的通用前端策略。

#### 容器目录定义
以下目录为"容器目录"，其内部子目录/文件才是实际模块：

| 容器目录 | 模块形式 | 示例 |
|---------|---------|------|
| `src/components/` | 子目录（每个组件一个目录） | `src/components/Button/` |
| `src/pages/` | 子目录（每个页面一个目录） | `src/pages/checkout/` |
| `src/api/` | 子目录（每个 API 模块一个目录） | `src/api/order/` |
| `src/hooks/` | 文件（每个 hook 一个文件） | `src/hooks/useAuth.ts` |
| `src/store/` | 文件/子目录（store 切片） | `src/store/useStore.ts` |
| `src/utils/`、`src/util/` | 文件（工具函数） | `src/utils/request.ts` |
| `src/contexts/` | 文件（React Context） | `src/contexts/AppContext.tsx` |
| `src/constant/`、`src/constants/` | 文件（常量定义） | `src/constant/enum.ts` |

#### 扫描步骤

**Step 1: 容器目录内模块提取**
对每个容器目录执行：

```
# 组件/页面/API 类（子目录形式）
Glob("src/components/*/index.{ts,tsx,js,jsx}")
Glob("src/pages/*/index.{ts,tsx,js,jsx}")
Glob("src/api/*/index.{ts,tsx,js,jsx}")

# Hooks 类（文件形式）
Glob("src/hooks/*.{ts,tsx}")
排除 index.{ts,tsx}（通常只是 barrel export）

# Store 类
Glob("src/store/*.{ts,tsx}")
Glob("src/store/*/index.{ts,tsx}")

# Utils 类
Glob("src/utils/*.{ts,tsx,js}")
Glob("src/util/*.{ts,tsx,js}")
排除 index.{ts,tsx,js}（通常只是 barrel export）

# Contexts 类
Glob("src/contexts/*.{ts,tsx}")

# Constant 类
Glob("src/constant/*.{ts,tsx,js}")
Glob("src/constants/*.{ts,tsx,js}")
```

**Step 2: 无 index 文件的子目录 fallback**
对容器目录内的子目录，如果无 index 文件但含 1+ 个源码文件，也算模块：
```
目录下文件数 >= 1 且含至少一个 .ts/.tsx/.js/.jsx 文件
```
（原规则要求 3+ 文件，对前端组件过于严格，改为 1+）

**Step 3: 空目录标记**
对 pages/ 下的空目录（如 `src/pages/notification/` 无文件），创建轻量节点并标记 `confidence: low`、`freshness: stale`，提示用户确认是否已废弃。

**Step 4: 去重与合并**
- 如果 `src/components/index.ts` 存在（barrel export），不将其作为独立模块，只将其作为 `components` 容器目录的入口文件记录
- 如果子目录和父目录都被识别为模块，优先保留子目录（更细粒度）

**入口文件**：`index.ts` > `index.tsx` > `index.js` > `index.jsx` > 目录中文件数最多的 `.ts` 文件

### Taro 小程序（taro-miniprogram / taro-multi-platform）

Taro 小程序采用与 Web 前端不同的目录结构和路由机制，需要专用提取策略。

#### 核心差异

| 维度 | Web 前端 | Taro 小程序 |
|------|---------|------------|
| 路由定义 | React Router / Vue Router 组件内 | `app.config.ts` 的 `pages[]` 数组 |
| 页面入口 | `src/pages/*/index.tsx` | `src/pages/*/index.tsx`（相同但路由来源不同） |
| 全局配置 | 无统一入口 | `src/app.config.ts`（页面路由、tabBar、window 等） |
| 小程序专属 | 无 | `src/services/`（API 封装）、自定义组件 |
| 样式方案 | CSS/SCSS Modules 等 | `*.module.scss`（Taro 推荐） |
| 跨端适配 | 无 | 条件编译 `process.env.TARO_ENV` |

#### 容器目录定义

| 容器目录 | 模块形式 | 示例 | 说明 |
|---------|---------|------|------|
| `src/pages/` | 子目录（每个页面一个目录） | `src/pages/index/` | 页面路由从 `app.config.ts` 提取 |
| `src/components/` | 子目录（自定义组件） | `src/components/NavBar/` | 小程序自定义组件 |
| `src/services/` | 文件/子目录（API 服务） | `src/services/user.ts` | Taro 常用命名，等价于 Web 的 `api/` |
| `src/api/` | 文件/子目录（API 服务） | `src/api/order.ts` | 部分项目仍用 `api/` |
| `src/store/` | 文件/子目录（状态管理） | `src/store/user.ts` | 通常配合 mobx/zustand |
| `src/hooks/` | 文件（共享逻辑） | `src/hooks/useLogin.ts` | |
| `src/utils/` | 文件（工具函数） | `src/utils/request.ts` | Taro.request 封装 |
| `src/constant/` | 文件（常量/枚举） | `src/constant/env.ts` | |
| `src/subpackages/` | 子目录（分包） | `src/subpackages/marketing/` | 小程序分包目录 |

#### 扫描步骤

**Step 0: 解析 app.config.ts 提取路由信息**

```
Read("src/app.config.ts") 或 Read("src/app.config.js")
提取:
  - pages[] → 主包页面列表
  - subPackages[] → 分包配置（root + pages）
  - tabBar.list → Tab 页面列表
```

此步骤必须在其他扫描前执行，因为 Taro 页面的 **合法性** 由 `app.config.ts` 决定，而非目录存在性。

**Step 1: 主包页面提取**

```
# 从 app.config.ts 的 pages[] 生成页面列表
# 如 pages: ['pages/index/index', 'pages/user/index']
# 则页面模块为:
#   src/pages/index/ → page.index
#   src/pages/user/  → page.user

Glob("src/pages/*/index.{ts,tsx,js,jsx}")
```

对每个页面，额外记录其在 `app.config.ts` 中的路由路径（如 `pages/index/index`）作为 `aliases`。

**Step 2: 分包提取**

```
# 从 app.config.ts 的 subPackages[] 提取
# 如 subPackages: [{ root: 'subpackages/marketing', pages: ['index/index'] }]
# 则分包模块为:
#   src/subpackages/marketing/ → subpackage.marketing（分包节点）
#   src/subpackages/marketing/pages/index/ → page.marketing-index

Glob("src/subpackages/*/index.{ts,tsx,js,jsx}")
Glob("src/subpackages/*/pages/*/index.{ts,tsx,js,jsx}")
```

分包节点类型为 `subpackage`，标记 `tags: ["layer:entry"]`。分包内的页面与主包页面同类型但增加 `tags: ["subpackage"]`。

**Step 3: 自定义组件提取**

```
Glob("src/components/*/index.{ts,tsx,js,jsx}")
```

同 Web 前端的 components 处理，但需注意 Taro 自定义组件可能包含：
- 组件 JSON 配置文件（`index.json`）：声明组件依赖关系
- 组件样式文件（`index.module.scss`）：Taro 推荐 CSS Modules

对含 `index.json` 的组件，读取其 `usingComponents` 字段提取组件间依赖。

**Step 4: 服务层提取**

```
# Taro 项目常用 services/ 替代 api/
Glob("src/services/*.{ts,tsx,js}")
Glob("src/services/*/index.{ts,tsx,js,jsx}")
# 兼容使用 api/ 的项目
Glob("src/api/*.{ts,tsx,js}")
Glob("src/api/*/index.{ts,tsx,js,jsx}")
```

**Step 5: 基础模块提取**

同 Web 前端的 hooks / store / utils / constant / contexts 扫描，但增加：

```
# Taro 专属工具
Glob("src/utils/request.{ts,tsx,js}")  # Taro.request 封装
```

**Step 6: 空目录与未注册页面处理**

- `app.config.ts` 中注册但目录不存在的页面：创建轻量节点，标记 `confidence: low`、`freshness: stale`
- 目录存在但未在 `app.config.ts` 注册的页面：创建轻量节点，标记 `confidence: low`，添加 `tags: ["unregistered-page"]`，提示用户确认

#### 入口文件

与 Web 前端相同：`index.ts` > `index.tsx` > `index.js` > `index.jsx`

**特殊入口**：
- App 级入口：`src/app.ts` / `src/app.tsx`（全局生命周期）
- 全局配置：`src/app.config.ts`（路由、tabBar、窗口配置）

#### 条件编译处理

Taro 项目中 `process.env.TARO_ENV` 用于跨端条件编译。扫描时：
- 将条件编译分支标记为 `tags: ["conditional-compile"]`
- 在节点中记录涉及的 `TARO_ENV` 值（如 `weapp`、`h5`、`alipay`）
- 不展开条件编译分支，只记录存在条件编译这一事实

#### 路由关系提取

Taro 的路由关系从 `app.config.ts` 提取，而非从代码中的 `<Route>` 组件：

```
# 主包页面路由
app.config.ts → pages[] → 每个页面路由路径

# 分包页面路由
app.config.ts → subPackages[].root + subPackages[].pages[]

# Tab 导航
app.config.ts → tabBar.list[].pagePath → Tab 页面
```

- 页面间跳转（`Taro.navigateTo` / `Taro.redirectTo` / `Taro.switchTab`）通过 Grep 扫描提取为 `route_to` / `route_from`
- Grep 模式：`Taro\.(navigateTo|redirectTo|switchTab|reLaunch|navigateBack)\s*\(` 提取目标路径

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

## 模块排序算法（前端项目适配版）

对所有候选模块执行评分排序，但**基础模块不参与淘汰**，仅用于确定深度扫描的优先级。

### 前端项目评分公式

```
score = 0.25 * import_score + 0.25 * file_score + 0.20 * git_score + 0.30 * type_score
```

**调整说明：**
- 降低 `import_score` 权重（0.5 → 0.25）：页面类模块 import_in 通常为 0，不应因此被过滤
- 新增 `type_score`（0.30）：按模块类型赋予基础分，确保各类型模块都有代表性被深度扫描

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

### type_score（模块类型基础分）

| 模块类型 | 基础分 | 说明 |
|---------|--------|------|
| `page` | 0.8 | 页面是业务入口，必须被深度扫描 |
| `subpackage` | 0.75 | 小程序分包，按独立模块处理 |
| `api` | 0.7 | API 模块是数据层核心 |
| `service` | 0.7 | Taro 项目 API 封装层（等价于 api） |
| `component` | 0.6 | 组件是 UI 层核心 |
| `hook` | 0.5 | 共享逻辑钩子 |
| `store` | 0.5 | 状态管理模块 |
| `util` | 0.3 | 工具函数 |
| `constant` | 0.2 | 常量定义 |
| `config` | 0.2 | 配置文件 |

**类型判定规则：**
- 路径含 `pages/` → `page`
- 路径含 `subpackages/` → `subpackage`（Taro 小程序分包）
- 路径含 `api/` → `api`
- 路径含 `services/` → `service`（Taro 项目常用命名，等价于 api）
- 路径含 `components/` → `component`
- 路径含 `hooks/` 或文件名以 `use` 开头 → `hook`
- 路径含 `store/` → `store`
- 路径含 `utils/` 或 `util/` → `util`
- 路径含 `constant/` 或 `constants/` → `constant`
- 路径含 `config/` → `config`

## 基础模块识别

以下目录名匹配任一关键词即为基础模块（Foundation 层）：

```
# 通用基础
utils, util, common, shared, lib, helpers, tools, core,
pkg, internal/common, internal/pkg, base, framework, infrastructure,

# 前端专属基础
components,      # 共享组件库（被多页面引用）
hooks,           # 共享逻辑钩子
store,           # 全局状态管理
contexts,        # React Context 提供者
constant, constants,  # 业务常量/枚举
config,          # 配置文件

# Taro 小程序专属基础
services,        # API 服务封装层（等价于 api）
subpackages,     # 分包目录（作为容器目录，内部子目录才是模块）
```

**前端项目特殊处理：**
- `src/components/` 整体标记为 `foundation` 层，但其内部子目录（如 `Button/`, `Modal/`）根据被引用范围判定：
  - 被 3+ 个页面引用 → `foundation`
  - 只被 1-2 个页面引用 → `business`
- `src/hooks/` 整体标记为 `foundation`
- `src/store/` 整体标记为 `foundation`
- `src/contexts/` 整体标记为 `foundation`
- `src/constant/`、`src/constants/` 整体标记为 `foundation`

**Taro 小程序特殊处理：**
- `src/services/` 整体标记为 `foundation`（API 封装层，等价于 Web 前端的 `api/`）
- `src/subpackages/` 作为容器目录，其内部子目录（每个分包）标记为 `business`，子目录内的页面按普通页面处理
- `src/utils/request.ts`（Taro.request 封装）标记为 `foundation`，这是 Taro 项目网络层的关键基础模块

**基础模块处理策略：**
- 基础模块不再参与评分排序的淘汰，全部创建节点（至少轻量节点）
- 基础模块的轻量节点保留 `key_files` 列表，便于后续升级为深度节点
- 基础模块中的高频被引用者（如 `components/Button` 被 import 10+ 次）自动升级为深度节点

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
