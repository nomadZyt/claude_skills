#!/bin/bash

# 1. 接收外部参数，如果没有传则报错退出
SKILL_NAME=$1

if [ -z "$SKILL_NAME" ]; then
  echo "❌ 错误：请提供要测试的 Skill 名称！"
  echo "💡 用法：./evals/run-eval.sh <skill-name> [--dry-run]"
  echo "例如：./evals/run-eval.sh zacc-requirement-spec"
  exit 1
fi

DRY_RUN=0
if [ "$2" = "--dry-run" ]; then
  DRY_RUN=1
fi

# 2. 定义动态路径变量（子目录三件套布局：evals/skills/<name>/<name>.{md,judge.txt,assert.js}）
# 注意：脚本内部会 cd 到 .test-workspace，因此需要用 ../evals/... 形式给 claude 引用
SKILL_FILE_REL="evals/skills/${SKILL_NAME}/${SKILL_NAME}.md"
JUDGE_RULES_FILE_REL="evals/skills/${SKILL_NAME}/${SKILL_NAME}.judge.txt"
ASSERT_SCRIPT="evals/skills/${SKILL_NAME}/${SKILL_NAME}.assert.js"
SCHEMA_FILE_REL="evals/schemas/style-rubric.json"
OUTPUT_SCORE="evals/artifacts/${SKILL_NAME}_score.json"

# 在 .test-workspace 内引用仓库根文件的相对前缀
SKILL_FILE="../${SKILL_FILE_REL}"
JUDGE_RULES_FILE="../${JUDGE_RULES_FILE_REL}"
SCHEMA_FILE="../${SCHEMA_FILE_REL}"

# 前置检查：确保核心文件存在（在仓库根视角）
if [ ! -f "$SKILL_FILE_REL" ]; then
    echo "❌ 找不到对应的 Skill 文件: ${SKILL_FILE_REL}"
    echo "💡 期望布局: evals/skills/${SKILL_NAME}/${SKILL_NAME}.md"
    exit 1
fi

if [ ! -f "$JUDGE_RULES_FILE_REL" ]; then
    echo "⚠️  找不到裁判规则: ${JUDGE_RULES_FILE_REL}"
fi

if [ ! -f "$SCHEMA_FILE_REL" ]; then
    echo "❌ 找不到评分量表: ${SCHEMA_FILE_REL}"
    exit 1
fi

# 确保 artifacts 目录存在
mkdir -p evals/artifacts

if [ $DRY_RUN -eq 1 ]; then
    echo "🔍 [dry-run] 路径预检 ($SKILL_NAME):"
    echo "   Skill prompt       : $SKILL_FILE_REL  ($( [ -f "$SKILL_FILE_REL" ] && echo OK || echo MISSING ))"
    echo "   Judge rubric       : $JUDGE_RULES_FILE_REL  ($( [ -f "$JUDGE_RULES_FILE_REL" ] && echo OK || echo MISSING ))"
    echo "   Assert script      : $ASSERT_SCRIPT  ($( [ -f "$ASSERT_SCRIPT" ] && echo OK || echo MISSING ))"
    echo "   Schema             : $SCHEMA_FILE_REL  ($( [ -f "$SCHEMA_FILE_REL" ] && echo OK || echo MISSING ))"
    echo "   Artifacts dir      : evals/artifacts/ (created if missing)"
    echo "   Output score file  : $OUTPUT_SCORE"
    echo "   Sandbox (cwd 内)   : .test-workspace/ (真跑时会 rm -rf 重建)"
    echo "✅ dry-run 通过，无真实执行"
    exit 0
fi

echo "🚀 [1/4] 初始化靶场环境 (${SKILL_NAME})..."
rm -rf .test-workspace
mkdir -p .test-workspace

# 将 skill prompt 复制进沙盒：claude -p 会把工作目录隔离，无法访问 ../，
# 所以把 prompt 文件放到 .test-workspace 内以便 Agent 读取
cp "$SKILL_FILE_REL" .test-workspace/_task.md

# Claude Code 对工作目录下的 .claude/ 有硬保护，Agent 无法创建该目录。
# 脚本预建 .claude/ 与占位 AI_RULES.md，Agent 只需 Write 填充内容即可（覆盖已有文件是允许的）。
mkdir -p .test-workspace/.claude
cat > .test-workspace/.claude/AI_RULES.md <<'AIRULES_PLACEHOLDER'
# AI 红线规则（由 eval 预置占位；请 Agent 按任务要求补充实际红线内容）
AIRULES_PLACEHOLDER

cd .test-workspace

echo "🤖 [2/4] 唤醒 Claude Code 执行任务..."
# 动态读取对应的 md 文件（已复制为 ./_task.md）
claude -p --permission-mode bypassPermissions "请严格按照 ./_task.md 中的要求，在当前目录执行任务。执行完毕后删除 _task.md 并直接退出，无需多言。"

echo "🔍 [3/4] 执行第一层：运行 ${SKILL_NAME} 的客观断言..."
cd ..
# 动态执行对应的断言脚本（如果存在的话）
if [ -f "$ASSERT_SCRIPT" ]; then
    node "$ASSERT_SCRIPT"
    if [ $? -ne 0 ]; then
      echo "❌ 客观断言未通过，终止 Eval。"
      exit 1
    fi
else
    echo "⚠️ 未找到专属断言脚本 ($ASSERT_SCRIPT)，跳过客观检查。"
fi

echo "⚖️ [4/4] 执行第二层：唤醒 Claude 裁判进行专项打分..."
# 将通用的指令、动态的专属规则文件、通用的 Schema 拼装在一起
JUDGE_PROMPT="请扮演一个严苛的资深代码审查员。审查 .test-workspace 目录下的产物。
执行以下专属打分规则：
$(cat "$JUDGE_RULES_FILE_REL")

你必须严格按照 ${SCHEMA_FILE_REL} 的数据结构输出结果。
只输出合法的 JSON 字符串，不要包含任何 Markdown 标记，不要任何解释！"

# 将结果输出到带 Skill 前缀的专属文件中
claude -p --permission-mode bypassPermissions "$JUDGE_PROMPT" > "$OUTPUT_SCORE"

echo "✅ Eval 流程结束！查看评分结果："
cat "$OUTPUT_SCORE"
