#!/usr/bin/env bash
# verify-requirement.sh — 校验 zacc-requirement-spec 产出的需求文档是否满足下游 zacc-task-spec 的输入契约
# 用法: bash verify-requirement.sh docs/requirements/{feature-name}.md

set -e

FILE="${1:-}"

if [[ -z "$FILE" ]]; then
  echo "用法: $0 <requirement-file.md>"
  exit 2
fi

if [[ ! -f "$FILE" ]]; then
  echo "FAIL: 文件不存在: $FILE"
  exit 1
fi

PASS=0
FAIL=0
WARN=0

check() {
  local name="$1"
  local pattern="$2"
  local level="${3:-FAIL}"  # FAIL / WARN

  if grep -qE "$pattern" "$FILE"; then
    echo "PASS: $name"
    PASS=$((PASS+1))
  else
    if [[ "$level" == "WARN" ]]; then
      echo "WARN: $name (缺失: 匹配模式 /$pattern/)"
      WARN=$((WARN+1))
    else
      echo "FAIL: $name (缺失: 匹配模式 /$pattern/)"
      FAIL=$((FAIL+1))
    fi
  fi
}

check_section() {
  local title="$1"
  local level="${2:-FAIL}"
  check "章节存在: $title" "^##+\s+${title}" "$level"
}

echo "=== 校验需求文档: $FILE ==="
echo

# 机读 Meta 必填
check_section "元数据" FAIL
check "Meta: feature-name 字段" "^\|\s*feature-name\s*\|\s*\`[a-z0-9-]+\`" FAIL
check "Meta: 主模块路径字段" "^\|\s*主模块路径\s*\|" FAIL
check "Meta: 关联 Wiki 节点字段" "^\|\s*关联 Wiki 节点\s*\|" FAIL

# 上游产物摘要
check_section "上游产物摘要" WARN

# 至少一个子需求六段式结构
check_section "背景" FAIL
check_section "现状问题" FAIL
check_section "改造方案" FAIL
check_section "验收标准" FAIL
check_section "受影响文件" FAIL

# 全局约束 / 交付说明
check_section "全局约束" WARN
check_section "交付说明" WARN

# 占位符未被替换检测
if grep -qE "\{[a-z_-]+\}" "$FILE"; then
  unreplaced=$(grep -oE "\{[a-z_-]+\}" "$FILE" | sort -u | head -5 | tr '\n' ' ')
  echo "WARN: 存在未替换占位符: $unreplaced"
  WARN=$((WARN+1))
fi

echo
echo "=== 结果 ==="
echo "PASS: $PASS | WARN: $WARN | FAIL: $FAIL"

if [[ $FAIL -gt 0 ]]; then
  echo "结论: 不合格,下游 zacc-task-spec 无法消费。请补全 FAIL 项。"
  exit 1
else
  if [[ $WARN -gt 0 ]]; then
    echo "结论: 合格但有警告,建议补全 WARN 项以提升 task-spec 规划质量。"
  else
    echo "结论: 合格,可直接喂给 zacc-task-spec。"
  fi
  exit 0
fi
