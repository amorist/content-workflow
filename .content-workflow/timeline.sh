#!/bin/bash
# Content Workflow Timeline - 会话时间线追踪
# 记录内容生产的完整流程

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMELINE_FILE="$SCRIPT_DIR/timeline.jsonl"

# 生成 Session ID
SESSION_ID="${SESSION_ID:-$$-$(date +%s 2>/dev/null || echo '0')}"

# 获取当前时间戳
get_timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%S || echo "unknown"
}

# 记录事件
log_event() {
  local event_type="$1"
  local details="${2:-{}}"
  local timestamp
  timestamp=$(get_timestamp)

  printf '{"session":"%s","event":"%s","timestamp":"%s","details":%s}\n' \
    "$SESSION_ID" "$event_type" "$timestamp" "$details" >> "$TIMELINE_FILE"
}

# 记录选题事件
log_topic() {
  local topic="$1"
  log_event "选题" "{\"topic\":\"$topic\"}"
}

# 记录生成文稿事件
log_draft() {
  local title="$1"
  local duration="$2"
  log_event "生成文稿" "{\"title\":\"$title\",\"duration\":\"$duration\"}"
}

# 记录审核事件
log_review() {
  local result="$1"
  log_event "内容审核" "{\"result\":\"$result\"}"
}

# 记录发布事件
log_publish() {
  local platform="$1"
  local title="$2"
  log_event "发布" "{\"platform\":\"$platform\",\"title\":\"$title\"}"
}

# 记录数据复盘事件
log_review_data() {
  local title="$1"
  local views="$2"
  log_event "数据复盘" "{\"title\":\"$title\",\"views\":$views}"
}

# 获取当前会话的时间线
get_session_timeline() {
  [ -f "$TIMELINE_FILE" ] || return
  grep "\"session\":\"$SESSION_ID\"" "$TIMELINE_FILE" 2>/dev/null | tail -20
}

# 获取今日统计
get_today_stats() {
  local today
  today=$(date +%Y-%m-%d 2>/dev/null || echo "")
  [ -n "$today" ] && [ -f "$TIMELINE_FILE" ] || { echo "0"; return; }
  grep "$today" "$TIMELINE_FILE" 2>/dev/null | wc -l | tr -d ' '
}

# 主入口
case "${1:-}" in
  topic)
    log_topic "$2"
    ;;
  draft)
    log_draft "$2" "$3"
    ;;
  review)
    log_review "$2"
    ;;
  publish)
    log_publish "$2" "$3"
    ;;
  review-data)
    log_review_data "$2" "$3"
    ;;
  timeline)
    get_session_timeline
    ;;
  today)
    get_today_stats
    ;;
  *)
    echo "Usage: $0 {topic|draft|review|publish|review-data|timeline|today} [args...]"
    exit 1
    ;;
esac
