# /nf-explore - 加载项目上下文

## 目的
为新 Agent 会话加载完整的项目上下文。

## 要加载的文件

1. **CLAUDE.md** - 项目约定
2. **docs/features/FEATURE_INDEX.md** - 所有 NF 概览
3. **package.json** - 依赖项和脚本
4. **src/ 结构** - 列出关键目录
5. **用户提到的任何 NF**

## 步骤

1. **读取核心文件**
   ```
   - CLAUDE.md
   - docs/features/FEATURE_INDEX.md
   - package.json
   ```

2. **列出项目结构**
   ```
   src/
   ├── components/
   ├── hooks/
   ├── pages/
   ├── types/
   └── utils/
   ```

3. **检查进行中的 NF**
   - 注意任何"In Progress"的 NF
   - 注意任何"Pending Verification"的 NF

4. **提示用户**
   ```
   ✅ 上下文已加载
   
   进行中的 NF:
   - NF-001: [标题] (状态：Open)
   - NF-002: [标题] (状态：In Progress)
   
   你想做什么？
   - "实现 NF-XXX"
   - "设计 NF-XXX"
   - "创建新 NF"
   ```

## 提示

- 高效加载上下文（不要读取每个文件）
- 按需读取特定 NF 文件
- 记住已加载的上下文以回答后续问题
