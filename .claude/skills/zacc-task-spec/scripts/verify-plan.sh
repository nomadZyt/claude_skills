#!/usr/bin/env bash
# verify-plan.sh — IMPLEMENTATION_PLAN.md 执行详情完整性校验（macOS/Linux 兼容）
# 用法: bash verify-plan.sh <path-to-IMPLEMENTATION_PLAN.md>
set -euo pipefail

PLAN_FILE="${1:?用法: bash verify-plan.sh <IMPLEMENTATION_PLAN.md 路径>}"

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "❌ FAIL: 文件不存在: $PLAN_FILE"
  exit 1
fi

PASS=0
FAIL=0
WARN=0

pass() { echo "  ✅ PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ FAIL: $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  ⚠️  WARN: $1"; WARN=$((WARN + 1)); }

PLAN_CONTENT=$(cat "$PLAN_FILE")

# 提取所有已完成的 Task ID（[x] 标记）
COMPLETED_TASKS=$(echo "$PLAN_CONTENT" | grep -E '\[x\]' | sed -n 's/.*\*\*\([A-Za-z0-9]*\)\*\*.*/\1/p' || true)

if [[ -z "$COMPLETED_TASKS" ]]; then
  echo "ℹ️  没有已完成的 Task，跳过校验。"
  exit 0
fi

echo "🔍 校验 IMPLEMENTATION_PLAN: $PLAN_FILE"
echo "   已完成 Task: $(echo $COMPLETED_TASKS | tr '\n' ' ')"
echo ""

REQUIRED_FIELDS="契约 关键决策 变更文件 关联_commit 依赖 被依赖 回滚"

for TASK_ID in $COMPLETED_TASKS; do
  echo "── $TASK_ID ──"

  # 提取 Task 区块：从 [x] **TaskID** 到下一个 "- [" 行
  TASK_BLOCK=$(echo "$PLAN_CONTENT" | awk "/\[x\].*\*\*${TASK_ID}\*\*/,/^- \[/" || true)

  # 检查 1: <details> 区块是否存在
  if ! echo "$TASK_BLOCK" | grep -q '<details>' 2>/dev/null; then
    fail "$TASK_ID: 缺少 <details> 执行详情区块"
    echo ""
    continue
  fi

  # 检查 2: 7 个必填字段是否存在且非占位符
  for FIELD_KEY in $REQUIRED_FIELDS; do
    # 将下划线还原为空格用于匹配
    FIELD=$(echo "$FIELD_KEY" | tr '_' ' ')

    FIELD_LINE=$(echo "$TASK_BLOCK" | grep "\\*\\*${FIELD}：\\*\\*" || true)
    FIELD_VALUE=$(echo "$FIELD_LINE" | sed "s/.*\*\*${FIELD}：\*\*[[:space:]]*//" || true)

    if [[ -z "$FIELD_VALUE" ]]; then
      fail "$TASK_ID: 缺少字段「${FIELD}」"
      continue
    fi

    # 检查是否为占位符
    if echo "$FIELD_VALUE" | grep -qE '^\{.*\}$|^\.\.\.$|^[[:space:]]*$'; then
      fail "$TASK_ID: 字段「${FIELD}」仍为占位符: $FIELD_VALUE"
    else
      pass "$TASK_ID: 字段「${FIELD}」已填写"
    fi
  done

  # 检查 3: commit hash 真实性
  COMMIT_LINE=$(echo "$TASK_BLOCK" | grep '\\*\\*关联 commit：\\*\\*' || true)
  COMMIT_HASH=$(echo "$COMMIT_LINE" | sed -n 's/.*[`[:space:]]\([a-f0-9]\{7,40\}\)[`[:space:]]*.*/\1/p' || true)
  if [[ -z "$COMMIT_HASH" ]]; then
    COMMIT_HASH=$(echo "$COMMIT_LINE" | grep -oE '[a-f0-9]{7,40}' | head -1 || true)
  fi
  if [[ -n "$COMMIT_HASH" ]]; then
    if git log --oneline "$COMMIT_HASH" -1 &>/dev/null; then
      pass "$TASK_ID: commit $COMMIT_HASH 存在于 git log"
    else
      fail "$TASK_ID: commit $COMMIT_HASH 不存在于 git log"
    fi
  fi

  # 检查 4: 变更文件存在性
  CHANGED_LINE=$(echo "$TASK_BLOCK" | grep '\\*\\*变更文件：\\*\\*' || true)
  CHANGED_VALUE=$(echo "$CHANGED_LINE" | sed 's/.*\*\*变更文件：\*\*[[:space:]]*//' || true)
  if [[ -n "$CHANGED_VALUE" ]]; then
    FILE_PATHS=$(echo "$CHANGED_VALUE" | grep -oE '`[^`]+\.[a-zA-Z]+`' | tr -d '`' || true)
    for FILE_PATH in $FILE_PATHS; do
      if [[ -f "$FILE_PATH" ]]; then
        pass "$TASK_ID: 文件 $FILE_PATH 存在"
      else
        warn "$TASK_ID: 文件 $FILE_PATH 不存在（可能已重命名或删除）"
      fi
    done
  fi

  echo ""
done

# 检查 5: 依赖双向一致性
echo "── 依赖一致性检查 ──"
for TASK_ID in $COMPLETED_TASKS; do
  TASK_BLOCK=$(echo "$PLAN_CONTENT" | awk "/\[x\].*\*\*${TASK_ID}\*\*/,/^- \[/" || true)
  DEP_LINE=$(echo "$TASK_BLOCK" | grep '\*\*依赖：\*\*' | grep -v '被依赖' | sed 's/.*\*\*依赖：\*\*[[:space:]]*//' || true)

  if [[ -n "$DEP_LINE" && "$DEP_LINE" != "无" && ! "$DEP_LINE" =~ ^\{.*\}$ ]]; then
    DEP_IDS=$(echo "$DEP_LINE" | grep -oE 'T[0-9]+' || true)
    for DEP_ID in $DEP_IDS; do
      DEP_BLOCK=$(echo "$PLAN_CONTENT" | awk "/\*\*${DEP_ID}\*\*/,/^- \[/" || true)
      BLOCKED_BY=$(echo "$DEP_BLOCK" | grep '\*\*被依赖：\*\*' || true)
      if [[ -n "$BLOCKED_BY" ]] && echo "$BLOCKED_BY" | grep -q "$TASK_ID"; then
        pass "依赖一致: $TASK_ID 依赖 $DEP_ID，$DEP_ID 的被依赖包含 $TASK_ID"
      else
        warn "依赖不一致: $TASK_ID 声明依赖 $DEP_ID，但 $DEP_ID 的被依赖中未包含 $TASK_ID"
      fi
    done
  fi
done

echo ""
echo "════════════════════════════════"
echo "  PASS: $PASS | FAIL: $FAIL | WARN: $WARN"

if [[ $FAIL -gt 0 ]]; then
  echo "  结论: ❌ 校验未通过，请补充缺失的执行详情后再标记 [x]"
  exit 1
else
  if [[ $WARN -gt 0 ]]; then
    echo "  结论: ⚠️  校验通过（有警告），建议检查上述警告项"
  else
    echo "  结论: ✅ 校验全部通过"
  fi
  exit 0
fi
