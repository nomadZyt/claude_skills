---
name: miniprogram-test-gen
description: 根据小程序代码改动或指定页面，自动生成可被 miniprogram-devtools MCP Server 执行的自动化测试用例
---

# 小程序自动化测试用例生成器

## 触发条件

当用户提到以下关键词时触发：
- "生成测试用例"、"自动化测试"、"测试用例生成"
- "帮我测试这个改动"、"测试覆盖"
- `/miniprogram-test-gen`

## 前置条件

- 当前工作目录是一个微信小程序项目（包含 `app.json`），或者用户指定了小程序项目路径
- `miniprogram-devtools` MCP Server 已配置并可用

## 工作流程

### Step 1: 确定测试范围

**方式 A — 基于 Git Diff（默认）**

1. 执行 `git diff --name-only HEAD` 和 `git diff --cached --name-only` 获取改动文件列表
2. 从改动文件中过滤出小程序页面相关文件（.wxml / .js / .ts / .json / .wxss）
3. 按页面路径分组（如 `pages/login/login.wxml` 和 `pages/login/login.js` 归为同一页面）
4. 如果没有 git 改动，提示用户使用方式 B

**方式 B — 用户指定**

用户直接指定要测试的页面路径或功能名称，例如：
- "帮我对 pages/login/login 生成测试用例"
- "帮我测试登录功能"

### Step 2: 分析页面代码

对每个涉及的页面，读取以下文件并提取信息：

**从 .wxml 中提取：**
- 表单元素: `<input>` 的 placeholder / label 文本 → 用于 `input` 工具的 `label` 参数
- 按钮元素: `<button>` 和可点击 `<view>` 的文本内容 → 用于 `tap` 工具的 `text` 参数
- 选择器: `<picker>` 相关元素及其标签 → 用于 `select` 工具
- 列表/循环: `wx:for` 元素 → 可能需要 `get_elements` 验证列表渲染

**从 .js/.ts 中提取：**
- `wx.request` 调用: URL、method、请求参数 → 生成 `start_network_capture` + `get_network_log` 断言
- 页面跳转: `wx.navigateTo` / `wx.redirectTo` / `wx.switchTab` 等 → 生成 `get_page_info` 断言
- `data` 初始值和 `setData` 调用 → 生成 `get_page_data` 断言
- 生命周期函数中的逻辑（onLoad、onShow）→ 决定页面加载后的前置验证

**从 .json 中提取：**
- `usingComponents` → 了解自定义组件使用情况
- 页面配置（navigationBarTitleText 等）

### Step 3: 展示测试计划概览，等待用户确认

在生成 JSON 之前，**必须先以自然语言表格展示测试计划**，让用户判断是否需要调整。

**展示格式：**

```
## 测试计划概览

页面: /pages/login/login
改动文件: login.js, login.wxml (2个文件)
测试场景数: 3

### 场景 1: 正常登录流程
| # | 操作 | 目标 | 预期结果 |
|---|------|------|----------|
| 1 | 导航到页面 | /pages/login/login | 页面正常加载 |
| 2 | 输入手机号 | 13800138000 | 输入框填入手机号 |
| 3 | 输入密码 | Test@123456 | 输入框填入密码 |
| 4 | 点击登录 | "登录" 按钮 | 调用 POST /api/login，跳转到首页 |

断言: 登录接口返回 200 + 页面跳转到 /pages/home/index

### 场景 2: 空表单提交
| # | 操作 | 目标 | 预期结果 |
|---|------|------|----------|
| 1 | 导航到页面 | /pages/login/login | 页面正常加载 |
| 2 | 点击登录 | "登录" 按钮 | 不调用登录接口，显示错误提示 |

断言: 未触发 /api/login 请求

### 场景 3: 验证码登录切换
...

涉及接口: POST /api/login, GET /api/sms/send, POST /api/sms/verify
失败策略: smart（页面跳转失败则停止后续场景）
```

**询问用户：**
- "以上测试计划是否需要调整？可以增删场景、修改操作步骤或测试数据"
- 等待用户确认或提出修改意见
- 用户确认后再进入 Step 4 生成 JSON

### Step 4: 生成测试用例 JSON

用户确认测试计划后，在小程序项目根目录下创建 `.test-cases/` 目录，输出 JSON 文件：

**文件命名**: `<页面名>-<YYYYMMDD-HHmmss>.json`

例如: `.test-cases/login-20260407-143000.json`

**JSON 格式规范**:

```json
{
  "name": "测试用例名称",
  "description": "测试目的描述",
  "page": "/pages/xxx/xxx",
  "generatedAt": "ISO 8601 时间",
  "generatedFrom": "git-diff | manual",
  "changedFiles": ["pages/login/login.js", "pages/login/login.wxml"],
  "stopOnError": "smart",
  "steps": [
    {
      "id": 1,
      "action": "MCP 工具名",
      "params": { "MCP 工具参数": "值" },
      "description": "步骤描述"
    }
  ],
  "assertions": [
    {
      "stepId": 1,
      "type": "断言类型",
      "expect": { "断言条件": "期望值" }
    }
  ]
}
```

**`action` 必须是以下 MCP 工具之一：**

| action | 说明 | 常用参数 |
|--------|------|----------|
| `navigate_to` | 页面导航 | `url`, `method` |
| `start_network_capture` | 开始抓包 | `clear` |
| `get_network_log` | 获取网络日志 | `url`（可选，**正则**过滤 URL）、`clear` |
| `stop_network_capture` | 停止抓包 | 无 |
| `screenshot` | 截图 | `waitFor` |
| `get_page_info` | 获取页面信息 | 无 |
| `get_page_data` | 获取页面数据 | `dataPath` |
| `get_wxml` | 获取 WXML | `selector` |
| `get_page_stack` | 获取页面栈 | 无 |
| `get_elements` | 获取元素 | `selector`, `text` |
| `tap` | 点击 | `text`, `selector` |
| `input` | 输入 | `label`, `selector`, `value` |
| `select` | 选择 | `label`, `selector`, `value` |
| `evaluate` | 执行 JS | `code` |
| `snapshot` | 全量快照 | `waitFor` |
| `wait_user_confirm` | 仅等待人工确认（不截图） | 见下文「人工接管」 |

**人工接管（`run_test_case` 执行时）**

当流程依赖**系统级弹窗**、真机授权、或无法被 automator 点击的界面时，在 JSON 里应显式表达「需要人手」，避免只用长 `waitFor` 盲等：

1. **`wait_user_confirm` 步骤**（推荐单独一步）  
   - 在 `tap` 等触发系统弹窗的步骤**之后**插入，`description` 写清用户要做什么。  
   - 可选 `params`：`releaseFile`（放行文件相对/绝对路径，默认 `.test-cases/.mcp-continue-step-<id>`）、`pollIntervalMs`、`maxWaitMs`（`0` 表示不限，默认 30 分钟）、`message` / `confirmMessage`（覆盖提示文案）。

2. **`screenshot` / `snapshot` + 文案约定**（与 MCP `test-runner` 一致）  
   - `description` 含 **`【需要你操作】`**：`run_test_case` 会**阻塞**，直到用户在 **connect 的 projectPath 根目录**下创建放行文件（默认 `<project>/.test-cases/.mcp-continue-step-<步骤id>`）。stderr 会打印 `touch "绝对路径"`；执行前会先删除同名旧文件，通过后也会删掉该文件。  
   - 含 **`【二次提醒】`** 且**不含** `【需要你操作】`：**不再次阻塞**，仅 stderr 提醒，并继续该步的 `waitFor`（用于「若还没点请抓紧」类缓冲，不要求第二次 touch）。  
   - 显式 `params.waitUserConfirm: true` 可强制与 `【需要你操作】` 等效的阻塞；`waitUserConfirm: false` 可关闭对描述的正则识别。

3. **生成用例时的写作建议**  
   - 首个人工卡点：用 **`【需要你操作】`** + 较短 `waitFor`（放行后的界面稳定时间，如 1500–3000ms）。  
   - 可选后续一步：仅用 **`【二次提醒】`** + 较长 `waitFor`，不要求新放行文件。  
   - 在 Step 4 概览表或摘要中注明：「含人工步骤，执行时需按 MCP stderr 提示 `touch` 放行文件」。

**`assertions` 断言类型：**

| type | expect 字段 | 说明 |
|------|-------------|------|
| `network` | `urlContains`（**正则**匹配完整 URL 字符串）、`method`、`status` | 验证网络请求；`urlContains` 中 `.` `?` 等按 RegExp 语义，需字面量时请转义 |
| `page_path` | `path` | 验证当前页面路径 |
| `page_data` | `fieldNotEmpty`, `fieldEquals`, `fieldContains` | 验证页面数据 |
| `element_exists` | `text`, `selector`, `minCount` | 验证元素存在 |
| `screenshot` | `description` | 人工检查点（截图标记） |

### Step 5: 标准测试模板

每个测试用例应包含以下标准步骤模式：

```
1. navigate_to → 导航到目标页面
2. start_network_capture → 开始抓包
3. screenshot → 前置截图（确认页面加载）
4. [交互操作] → input / tap / select（根据页面分析）
5. screenshot(waitFor: 3000) → 操作后截图
6. get_network_log → 检查接口调用
7. get_page_info → 验证页面状态
8. get_page_data → 验证数据变更
9. stop_network_capture → 停止抓包
10. snapshot → 保存全量快照作为测试证据
```

若涉及 **定位/相册/麦克风等系统授权**，在触发弹窗的 `tap` 之后增加人工步骤，例如：

```
… → tap(触发系统授权) → wait_user_confirm（说明「请在系统弹窗点允许」）
  → screenshot（短 waitFor，确认弹窗已关）
```

或使用带 **`【需要你操作】`** 的 `screenshot`/`snapshot` 一步完成「等人 + 短延迟截图」，勿再依赖 10s+ 纯盲等作为唯一手段。

### Step 6: 测试数据生成策略

为表单字段生成合理的测试数据：

| 字段类型 | 识别方式 | 测试数据 |
|----------|----------|----------|
| 手机号 | placeholder/label 含 "手机"、"电话" | `13800138000` |
| 姓名 | 含 "姓名"、"名字" | `张三` |
| 身份证 | 含 "身份证"、"证件号" | `110101199001011234` |
| 密码 | 含 "密码"、"password" | `Test@123456` |
| 验证码 | 含 "验证码"、"captcha" | `123456` |
| 金额 | 含 "金额"、"价格" | `100.00` |
| 日期 | `<picker mode="date">` | 当前日期 |
| 地址 | 含 "地址"、"地区" | `北京市朝阳区` |
| 通用文本 | 其他 input | `测试数据` |

### Step 7: 输出并询问执行

1. 将生成的 JSON 写入 `.test-cases/` 目录
2. 展示测试用例摘要（步骤数、断言数、涉及接口）
3. 询问用户：
   - "要立即执行这个测试用例吗？"
   - "需要调整某些步骤或测试数据吗？"
4. 如果用户选择执行：
   - 确认 MCP 已连接（未连接则先 `connect`）
   - **优先方式：调用 `start_test_session` 开启测试会话，然后逐步调用各 MCP 工具执行测试**。会话开启后，所有操作自动记录进度、自动截图、自动收集接口数据，所有步骤完成或失败时自动生成 Markdown 测试报告（含截图、接口数据、操作路径）
   - 备选方式：调用 `run_test_case` 工具一次性执行（适合步骤少的简单用例）。`run_test_case` 会往 **stderr** 打每步进度；含人工放行时务必让用户查看 stderr 并按提示 `touch` 放行文件后再继续。
   - 执行完毕后，告知用户报告输出路径

### 测试会话使用说明

`start_test_session` 是 MCP Server 提供的测试会话管理工具，调用后会：
- 解析测试用例 JSON，初始化进度跟踪
- 创建输出目录（`{用例名}-output/`），包含 `progress.json`（实时进度）、`screenshots/`（会话自动截图）、`snapshots/`（`run_test_case` 内 `snapshot` 步骤存档）、`{用例文件名}-report.json`（`run_test_case` 结构化报告，与 `report.json` 会话报告并存）
- 之后每次调用 `tap`、`screenshot`、`navigate_to`、`get_network_log` 等 MCP 工具时，**自动记录**步骤结果、截图、接口数据到会话中
- 所有步骤执行完毕或因错误停止时，**自动生成** `report.md`（Markdown 报告）和 `report.json`

**`stopOnError` 字段说明：**
- `"smart"`（默认）：步骤失败时，如果涉及页面跳转（navigate_to/tap）则停止所有后续用例，否则仅停止当前用例继续下一个
- `"always"`：任何步骤失败立即停止所有用例
- `"never"`：步骤失败仅停止当前用例，继续执行下一个用例

## 输出格式

生成用例后，以表格形式展示摘要：

```
已生成测试用例: .test-cases/login-20260407-143000.json

页面: /pages/login/login
来源: git diff (3 个文件变更)
步骤数: 10
断言数: 3
涉及接口: POST /api/login, GET /api/user/info

步骤概览:
| # | 操作 | 描述 |
|---|------|------|
| 1 | navigate_to | 导航到登录页 |
| 2 | start_network_capture | 开始网络抓包 |
| 3 | screenshot | 前置截图 |
| 4 | input(手机号) | 输入 13800138000 |
| 5 | input(密码) | 输入 Test@123456 |
| 6 | tap(登录) | 点击登录按钮 |
| 7 | screenshot | 操作后截图 |
| 8 | get_network_log | 检查登录接口 |
| 9 | get_page_info | 验证页面跳转 |
| 10 | snapshot | 保存测试快照 |

是否立即执行？
```
