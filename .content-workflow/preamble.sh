#!/bin/bash
# Content Workflow Preamble - 内容生产系统前置检查
# 每次执行工作流前自动运行

set -e

# 获取脚本所在目录（兼容 macOS/Linux/Windows Git Bash）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_ROOT="$(dirname "$SCRIPT_DIR")"
CONTENT_ROOT="$WORKFLOW_ROOT/内容生产系统"

# ===== 基础环境检查 =====
echo "=== Content Workflow 环境检查 ==="
echo "WORK_DIR: $WORKFLOW_ROOT"
echo "CONTENT_ROOT: $CONTENT_ROOT"

# ===== 检查素材库状态 =====
echo ""
echo "=== 素材库状态 ==="

# 统计各素材库文件数量
count_files() {
  local dir="$1"
  local pattern="${2:-*.md}"
  [ -d "$dir" ] || { echo "0"; return; }
  find "$dir" -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' '
}

case_count=$(count_files "$CONTENT_ROOT/01-素材库/案例库")
quote_count=$(count_files "$CONTENT_ROOT/01-素材库/金句库")
concept_count=$(count_files "$CONTENT_ROOT/01-素材库/核心概念库")

echo "案例库: $case_count 个文件"
echo "金句库: $quote_count 个文件"
echo "核心概念库: $concept_count 个文件"

# ===== 今日生产统计 =====
echo ""
echo "=== 今日生产统计 ==="

today=$(date +%Y-%m-%d 2>/dev/null || echo "")

if [ -n "$today" ]; then
  today_drafts=$(count_files "$CONTENT_ROOT/03-文稿库/草稿")
  today_final=$(count_files "$CONTENT_ROOT/03-文稿库/定稿")
else
  today_drafts="0"
  today_final="0"
fi

echo "今日草稿: $today_drafts"
echo "今日定稿: $today_final"

# ===== 加载用户配置 =====
echo ""
echo "=== 用户配置 ==="

if [ -f "$SCRIPT_DIR/config" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/config"
  echo "CONTENT_STYLE: ${CONTENT_STYLE:-default}"
  echo "TARGET_PLATFORM: ${TARGET_PLATFORM:-douyin}"
  echo "DEFAULT_DURATION: ${DEFAULT_DURATION:-60s}"
  echo "PROACTIVE_MODE: ${PROACTIVE_MODE:-true}"
else
  echo "CONTENT_STYLE: default (未配置)"
  echo "TARGET_PLATFORM: douyin (未配置)"
  echo "PROACTIVE_MODE: true (未配置)"
fi

# ===== Learnings 统计 =====
echo ""
echo "=== 学习积累 ==="

if [ -f "$SCRIPT_DIR/learnings.jsonl" ]; then
  learn_count=$(wc -l < "$SCRIPT_DIR/learnings.jsonl" 2>/dev/null | tr -d ' ' || echo "0")
  echo "已记录经验: $learn_count 条"

  if [ "$learn_count" -gt 3 ] 2>/dev/null; then
    echo ""
    echo "最近学习："
    tail -3 "$SCRIPT_DIR/learnings.jsonl" 2>/dev/null | while read -r line; do
      topic=$(echo "$line" | grep -o '"topic":"[^"]*"' | cut -d'"' -f4)
      learning=$(echo "$line" | grep -o '"learning":"[^"]*"' | cut -d'"' -f4)
      [ -n "$topic" ] && echo "  • $topic: $learning"
    done
  fi
else
  echo "已记录经验: 0 条"
fi

# ===== Session 信息 =====
echo ""
echo "=== Session 信息 ==="
SESSION_ID="$$-$(date +%s 2>/dev/null || echo '0')"
echo "SESSION_ID: $SESSION_ID"
echo "TIMESTAMP: $(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%S || echo 'unknown')"
