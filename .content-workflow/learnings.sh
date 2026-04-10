#!/bin/bash
# Content Workflow Learnings - 学习积累系统
# 记录每次内容生产的经验教训

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEARNINGS_FILE="$SCRIPT_DIR/learnings.jsonl"

# 初始化文件
init_learnings() {
  [ -f "$LEARNINGS_FILE" ] && return
  mkdir -p "$(dirname "$LEARNINGS_FILE")" 2>/dev/null || true
  touch "$LEARNINGS_FILE"
}

# 获取当前日期
get_date() {
  date +%Y-%m-%d 2>/dev/null || echo "unknown"
}

# 获取当前时间戳
get_timestamp() {
  date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%S || echo "unknown"
}

# 添加学习记录
add_learning() {
  init_learnings

  local topic="$1"
  local learning="$2"
  local performance="${3:-unknown}"
  local tags="${4:-}"
  local timestamp
  timestamp=$(get_timestamp)
  local date
  date=$(get_date)

  # 转义特殊字符
  learning=$(printf '%s' "$learning" | sed 's/"/\\"/g')
  topic=$(printf '%s' "$topic" | sed 's/"/\\"/g')

  local entry
  entry=$(printf '{"date":"%s","timestamp":"%s","topic":"%s","learning":"%s","performance":"%s","tags":"%s"}' \
    "$date" "$timestamp" "$topic" "$learning" "$performance" "$tags")

  echo "$entry" >> "$LEARNINGS_FILE"
  echo "✅ 已记录学习: $topic"
}

# 搜索学习记录
search_learnings() {
  init_learnings

  local keyword="$1"
  local limit="${2:-5}"

  [ -f "$LEARNINGS_FILE" ] || { echo "暂无学习记录"; return; }
  grep -i "$keyword" "$LEARNINGS_FILE" 2>/dev/null | tail -$limit
}

# 按主题获取学习
get_topic_learnings() {
  init_learnings

  local topic="$1"
  local limit="${2:-3}"

  [ -f "$LEARNINGS_FILE" ] || return
  grep "\"topic\":\"$topic\"" "$LEARNINGS_FILE" 2>/dev/null | tail -$limit
}

# 获取热门标签
get_popular_tags() {
  init_learnings

  [ -f "$LEARNINGS_FILE" ] || return
  grep -o '"tags":"[^"]*"' "$LEARNINGS_FILE" 2>/dev/null | \
    cut -d'"' -f4 | \
    tr ',' '\n' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -10
}

# 生成学习摘要
generate_summary() {
  init_learnings

  local count
  count=$(wc -l < "$LEARNINGS_FILE" 2>/dev/null | tr -d ' ' || echo "0")
  echo "=== 学习积累摘要 ==="
  echo "总记录数: $count"
  echo ""
  echo "热门主题:"
  grep -o '"topic":"[^"]*"' "$LEARNINGS_FILE" 2>/dev/null | \
    cut -d'"' -f4 | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -5 | \
    while read -r line; do
      echo "  $line"
    done
  echo ""
  echo "热门标签:"
  get_popular_tags | while read -r line; do
    echo "  $line"
  done
}

# 导出学习记录
export_learnings() {
  local output_file="$1"
  [ -f "$LEARNINGS_FILE" ] || return
  cp "$LEARNINGS_FILE" "$output_file"
  echo "✅ 已导出到: $output_file"
}

# 主入口
case "${1:-}" in
  add)
    add_learning "$2" "$3" "$4" "$5"
    ;;
  search)
    search_learnings "$2" "$3"
    ;;
  topic)
    get_topic_learnings "$2" "$3"
    ;;
  tags)
    get_popular_tags
    ;;
  summary)
    generate_summary
    ;;
  export)
    export_learnings "$2"
    ;;
  *)
    echo "Content Workflow Learnings"
    echo ""
    echo "Usage:"
    echo "  $0 add <topic> <learning> [performance] [tags]  - 添加学习记录"
    echo "  $0 search <keyword> [limit]                       - 搜索学习记录"
    echo "  $0 topic <topic> [limit]                          - 获取主题学习"
    echo "  $0 tags                                           - 热门标签"
    echo "  $0 summary                                        - 学习摘要"
    echo "  $0 export <output_file>                           - 导出记录"
    echo ""
    echo "Example:"
    echo "  $0 add '夫妻关系' '开头用亏字效果好' '500w+' '情感,开头'"
    exit 1
    ;;
esac
