#!/usr/bin/env bash
# verify-init.sh — 校验 zacc-init-fronted 产出（CLAUDE.md + AI_RULES.md）的完整性
# 用法: bash .claude/skills/zacc-init-fronted/scripts/verify-init.sh [项目根目录]
# 默认项目根目录为当前目录

set -eo pipefail

ROOT="${1:-.}"
CLAUDE_MD="${ROOT}/CLAUDE.md"
AI_RULES="${ROOT}/.claude/AI_RULES.md"

PASS=0
FAIL=0
WARN=0

pass()  { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
fail()  { FAIL=$((FAIL + 1)); echo "  [FAIL] $1"; }
warn()  { WARN=$((WARN + 1)); echo "  [WARN] $1"; }

# ─── 1. 文件存在性 ───

echo ""
echo "=== 1. 文件存在性检查 ==="

if [ -f "${CLAUDE_MD}" ]; then
  pass "CLAUDE.md 存在"
else
  fail "CLAUDE.md 不存在"
fi

if [ -f "${AI_RULES}" ]; then
  pass "AI_RULES.md 存在"
else
  fail "AI_RULES.md 不存在"
fi

if [ ! -f "${CLAUDE_MD}" ] && [ ! -f "${AI_RULES}" ]; then
  echo ""
  echo "=== 结论：两个产出文件均不存在，无法校验 ==="
  exit 1
fi

# ─── 2. CLAUDE.md 占位符检查 ───

echo ""
echo "=== 2. CLAUDE.md 占位符检查 ==="

if [ -f "${CLAUDE_MD}" ]; then
  PLACEHOLDER_COUNT=0
  IN_CODE_BLOCK=0
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '```'*)
        if [ "$IN_CODE_BLOCK" -eq 0 ]; then IN_CODE_BLOCK=1; else IN_CODE_BLOCK=0; fi
        ;;
      *)
        if [ "$IN_CODE_BLOCK" -eq 0 ]; then
          # 匹配英文和中文占位符，如 {name}、{项目名称}
          MATCHES=$(echo "$line" | grep -oE '\{[a-zA-Z_/\xE0-\xEF][^}]{0,60}\}' 2>/dev/null || true)
          if [ -z "$MATCHES" ]; then
            MATCHES=$(echo "$line" | grep -oE '\{[^}]{1,60}\}' 2>/dev/null | grep -v '^{[0-9]' || true)
            # 二次过滤：仅保留含字母或中文的占位符，排除纯符号/数字
            if [ -n "$MATCHES" ]; then
              MATCHES=$(echo "$MATCHES" | grep '[a-zA-Z]' 2>/dev/null || true)
            fi
          fi
          if [ -n "$MATCHES" ]; then
            PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1))
          fi
        fi
        ;;
    esac
  done < "${CLAUDE_MD}"

  if [ "$PLACEHOLDER_COUNT" -eq 0 ]; then
    pass "CLAUDE.md 无残留占位符"
  else
    fail "CLAUDE.md 残留 ${PLACEHOLDER_COUNT} 行含未填充占位符（搜索 {xxx} 格式）"
  fi

  for SECTION in "项目概述" "技术栈" "项目结构" "开发命令" "代码规范" "纠错记录"; do
    if grep -q "## ${SECTION}" "${CLAUDE_MD}" 2>/dev/null; then
      pass "CLAUDE.md 包含 ${SECTION} 章节"
    else
      fail "CLAUDE.md 缺少 ${SECTION} 章节"
    fi
  done

  TECH_ROWS=$(sed -n '/## 技术栈/,/^## /p' "${CLAUDE_MD}" | grep -c '|' 2>/dev/null || true)
  TECH_ROWS=$(echo "${TECH_ROWS}" | tr -d '[:space:]')
  TECH_ROWS=${TECH_ROWS:-0}
  if [ "$TECH_ROWS" -ge 4 ]; then
    pass "技术栈表格有 ${TECH_ROWS} 行"
  else
    warn "技术栈表格仅 ${TECH_ROWS} 行，可能不完整"
  fi

  CMD_BLOCK=$(sed -n '/## 开发命令/,/^## /p' "${CLAUDE_MD}" | grep -c '^[^ #]' 2>/dev/null || true)
  CMD_BLOCK=$(echo "${CMD_BLOCK}" | tr -d '[:space:]')
  CMD_BLOCK=${CMD_BLOCK:-0}
  if [ "$CMD_BLOCK" -ge 2 ]; then
    pass "开发命令章节有内容"
  else
    warn "开发命令章节可能为空或仅有标题"
  fi
fi

# ─── 3. AI_RULES.md 占位符检查 ───

echo ""
echo "=== 3. AI_RULES.md 占位符检查 ==="

if [ -f "${AI_RULES}" ]; then
  PLACEHOLDER_COUNT_RULES=0
  IN_CODE_BLOCK_RULES=0
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      '```'*)
        if [ "$IN_CODE_BLOCK_RULES" -eq 0 ]; then IN_CODE_BLOCK_RULES=1; else IN_CODE_BLOCK_RULES=0; fi
        ;;
      *)
        if [ "$IN_CODE_BLOCK_RULES" -eq 0 ]; then
          MATCHES=$(echo "$line" | grep -oE '\{[a-zA-Z_/\xE0-\xEF][^}]{0,60}\}' 2>/dev/null || true)
          if [ -z "$MATCHES" ]; then
            MATCHES=$(echo "$line" | grep -oE '\{[^}]{1,60}\}' 2>/dev/null | grep -v '^{[0-9]' || true)
            if [ -n "$MATCHES" ]; then
              MATCHES=$(echo "$MATCHES" | grep '[a-zA-Z]' 2>/dev/null || true)
            fi
          fi
          if [ -n "$MATCHES" ]; then
            PLACEHOLDER_COUNT_RULES=$((PLACEHOLDER_COUNT_RULES + 1))
          fi
        fi
        ;;
    esac
  done < "${AI_RULES}"

  if [ "$PLACEHOLDER_COUNT_RULES" -eq 0 ]; then
    pass "AI_RULES.md 无残留占位符"
  else
    fail "AI_RULES.md 残留 ${PLACEHOLDER_COUNT_RULES} 行含未填充占位符"
  fi

  for SECTION in "技术栈红线" "架构模式红线" "代码风格红线" "业务逻辑红线" "功能修改确认规则"; do
    if grep -q "${SECTION}" "${AI_RULES}" 2>/dev/null; then
      pass "AI_RULES.md 包含 ${SECTION} 章节"
    else
      fail "AI_RULES.md 缺少 ${SECTION} 章节"
    fi
  done

  for SECTION_TAG in "技术栈红线" "架构模式红线" "代码风格红线" "业务逻辑红线"; do
    RULE_LINES=$(sed -n "/${SECTION_TAG}/,/^## /p" "${AI_RULES}" | grep -cE '^\s*[-|]' 2>/dev/null || true)
    RULE_LINES=$(echo "${RULE_LINES}" | tr -d '[:space:]')
    RULE_LINES=${RULE_LINES:-0}
    if [ "$RULE_LINES" -ge 2 ]; then
      pass "${SECTION_TAG} 含 ${RULE_LINES} 条规则/表格行"
    else
      warn "${SECTION_TAG} 仅 ${RULE_LINES} 条规则，可能不完整"
    fi
  done

  CONFIRM_ROWS=$(sed -n '/功能修改确认规则/,/^## /p' "${AI_RULES}" | grep -c '|' 2>/dev/null || true)
  CONFIRM_ROWS=$(echo "${CONFIRM_ROWS}" | tr -d '[:space:]')
  CONFIRM_ROWS=${CONFIRM_ROWS:-0}
  if [ "$CONFIRM_ROWS" -ge 4 ]; then
    pass "功能修改确认规则表格有 ${CONFIRM_ROWS} 行"
  else
    warn "功能修改确认规则表格仅 ${CONFIRM_ROWS} 行，建议至少 5 条操作"
  fi
fi

# ─── 4. 交叉一致性检查 ───

echo ""
echo "=== 4. 交叉一致性检查 ==="

if [ -f "${CLAUDE_MD}" ] && [ -f "${AI_RULES}" ]; then
  if grep -qE "AI_RULES|AI 红线" "${CLAUDE_MD}" 2>/dev/null; then
    pass "CLAUDE.md 引用了 AI_RULES.md"
  else
    warn "CLAUDE.md 未引用 AI_RULES.md，建议在 AI 红线规则 章节添加链接"
  fi

  PKG_CLAUDE=$(grep -oE '(npm|yarn|pnpm|bun)' "${CLAUDE_MD}" 2>/dev/null | head -1 || true)
  PKG_RULES=$(grep -oE '(npm|yarn|pnpm|bun)' "${AI_RULES}" 2>/dev/null | head -1 || true)
  if [ -n "${PKG_CLAUDE}" ] && [ -n "${PKG_RULES}" ]; then
    if [ "${PKG_CLAUDE}" = "${PKG_RULES}" ]; then
      pass "包管理器一致: ${PKG_CLAUDE}"
    else
      warn "包管理器不一致: CLAUDE.md=${PKG_CLAUDE} vs AI_RULES.md=${PKG_RULES}"
    fi
  fi
fi

# ─── 5. HTML 注释残留检查 ───

echo ""
echo "=== 5. 模板注释残留检查 ==="

for FILE in "${CLAUDE_MD}" "${AI_RULES}"; do
  if [ -f "${FILE}" ]; then
    FNAME=$(basename "${FILE}")
    COMMENT_COUNT=$(grep -c '<!--' "${FILE}" 2>/dev/null || true)
    COMMENT_COUNT=$(echo "${COMMENT_COUNT}" | tr -d '[:space:]')
    COMMENT_COUNT=${COMMENT_COUNT:-0}
    if [ "$COMMENT_COUNT" -eq 0 ]; then
      pass "${FNAME} 无 HTML 注释残留"
    else
      warn "${FNAME} 含 ${COMMENT_COUNT} 处 HTML 注释（可能是模板指引未清理）"
    fi
  fi
done

# ─── 汇总 ───

echo ""
echo "==================================="
echo "  PASS: ${PASS} | FAIL: ${FAIL} | WARN: ${WARN}"
echo "==================================="

if [ "$FAIL" -gt 0 ]; then
  echo "  RESULT: 存在 ${FAIL} 项失败，产出不合格，请补充修正。"
  exit 1
else
  if [ "$WARN" -gt 0 ]; then
    echo "  RESULT: 无致命问题，但有 ${WARN} 项警告，建议检查。"
  else
    echo "  RESULT: 产出校验全部通过。"
  fi
  exit 0
fi
