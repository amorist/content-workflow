#!/bin/bash
# Content Workflow Upgrade - 升级脚本

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_ROOT="$(dirname "$SCRIPT_DIR")"

VERSION_FILE="$WORKFLOW_ROOT/.version"
UPGRADE_FILE="$WORKFLOW_ROOT/.upgrade"
CONFIG_DIR="$SCRIPT_DIR"
BACKUP_DIR="$WORKFLOW_ROOT/.backup"

# GitHub 仓库配置
GITHUB_REPO="${GITHUB_REPO:-amorist/content-workflow}"
GITHUB_RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取当前版本
get_current_version() {
  if [ -f "$VERSION_FILE" ]; then
    tr -d '[:space:]' < "$VERSION_FILE"
  else
    echo "0.0.0"
  fi
}

# 获取远程版本
get_remote_version() {
  if command -v curl >/dev/null 2>&1; then
    curl -s "${GITHUB_RAW_URL}/.version" 2>/dev/null | tr -d '[:space:]' || echo ""
  else
    echo ""
  fi
}

# 读取升级信息
read_upgrade_info() {
  if [ -f "$UPGRADE_FILE" ]; then
    cat "$UPGRADE_FILE"
  fi
}

# 写入升级信息
write_upgrade_info() {
  local from_version="$1"
  local to_version="$2"
  local timestamp
  timestamp=$(date +%Y-%m-%d_%H:%M:%S 2>/dev/null || date +%Y-%m-%d)

  cat > "$UPGRADE_FILE" << EOF
last_upgrade:
  from: $from_version
  to: $to_version
  timestamp: $timestamp
  source: github
EOF
}

# 创建备份
create_backup() {
  local version
  version=$(get_current_version)
  local backup_name="backup_v${version}_$(date +%Y%m%d_%H%M%S 2>/dev/null || date +%Y%m%d)"
  local backup_path="$BACKUP_DIR/$backup_name"

  printf "${BLUE}创建备份...${NC}\n"
  mkdir -p "$backup_path"

  # 备份用户数据
  [ -d "$WORKFLOW_ROOT/内容生产系统" ] && \
    cp -r "$WORKFLOW_ROOT/内容生产系统" "$backup_path/" 2>/dev/null || true

  # 备份配置
  [ -d "$CONFIG_DIR" ] && \
    cp -r "$CONFIG_DIR" "$backup_path/" 2>/dev/null || true

  # 备份版本文件
  [ -f "$VERSION_FILE" ] && \
    cp "$VERSION_FILE" "$backup_path/" 2>/dev/null || true

  printf "${GREEN}✓ 备份已创建: %s${NC}\n" "$backup_path"
  echo "$backup_path"
}

# 从 GitHub 更新
update_from_github() {
  local target_version="$1"

  printf "${BLUE}从 GitHub 下载更新...${NC}\n"

  if ! command -v curl >/dev/null 2>&1; then
    printf "${RED}✗ 需要 curl 来下载更新${NC}\n"
    return 1
  fi

  # 创建临时目录
  local temp_dir
  temp_dir=$(mktemp -d 2>/dev/null || echo "/tmp/content-workflow-update-$$")
  mkdir -p "$temp_dir"

  printf "下载 SKILL.md...\n"
  curl -sL "${GITHUB_RAW_URL}/SKILL.md" -o "$temp_dir/SKILL.md" 2>/dev/null || {
    printf "${RED}✗ 下载失败${NC}\n"
    rm -rf "$temp_dir"
    return 1
  }

  printf "下载 references...\n"
  mkdir -p "$temp_dir/references"
  for file in 生成文稿.md 生成标题.md 优化开头.md 检索素材.md 选题记录.md 数据复盘.md; do
    curl -sL "${GITHUB_RAW_URL}/references/$file" -o "$temp_dir/references/$file" 2>/dev/null || true
  done

  printf "下载工作流脚本...\n"
  mkdir -p "$temp_dir/.content-workflow"
  for file in update-check.sh upgrade.sh preamble.sh timeline.sh learnings.sh; do
    curl -sL "${GITHUB_RAW_URL}/.content-workflow/$file" -o "$temp_dir/.content-workflow/$file" 2>/dev/null || true
  done

  # 应用更新
  printf "${BLUE}应用更新...${NC}\n"

  [ -f "$temp_dir/SKILL.md" ] && cp "$temp_dir/SKILL.md" "$WORKFLOW_ROOT/"
  [ -d "$temp_dir/references" ] && cp -r "$temp_dir/references/"* "$WORKFLOW_ROOT/references/" 2>/dev/null || true
  [ -d "$temp_dir/.content-workflow" ] && cp -r "$temp_dir/.content-workflow/"* "$CONFIG_DIR/" 2>/dev/null || true

  # 更新版本号
  echo "$target_version" > "$VERSION_FILE"

  # 清理临时目录
  rm -rf "$temp_dir"

  printf "${GREEN}✓ 更新完成${NC}\n"
}

# 恢复备份
restore_backup() {
  local backup_path="$1"

  if [ ! -d "$backup_path" ]; then
    printf "${RED}✗ 备份不存在: %s${NC}\n" "$backup_path"
    return 1
  fi

  printf "${YELLOW}恢复备份...${NC}\n"

  [ -d "$backup_path/内容生产系统" ] && {
    rm -rf "$WORKFLOW_ROOT/内容生产系统"
    cp -r "$backup_path/内容生产系统" "$WORKFLOW_ROOT/"
  }

  [ -d "$backup_path/.content-workflow" ] && {
    rm -rf "$CONFIG_DIR"
    cp -r "$backup_path/.content-workflow" "$WORKFLOW_ROOT/"
  }

  [ -f "$backup_path/.version" ] && \
    cp "$backup_path/.version" "$VERSION_FILE"

  printf "${GREEN}✓ 备份已恢复${NC}\n"
}

# 执行升级
perform_upgrade() {
  local target_version="${1:-}"
  local current_version
  current_version=$(get_current_version)

  # 如果没有指定版本，获取远程最新版本
  if [ -z "$target_version" ]; then
    target_version=$(get_remote_version)
    if [ -z "$target_version" ] || [ "$target_version" = "404:NotFound" ]; then
      printf "${YELLOW}⚠ 无法获取远程版本，使用本地升级${NC}\n"
      target_version="$(echo "$current_version" | awk -F. '{print $1"."$2"."($3+1)}')"
    fi
  fi

  printf "${BLUE}=== Content Workflow 升级 ===${NC}\n"
  printf "当前版本: %s\n" "$current_version"
  printf "目标版本: %s\n" "$target_version"
  echo ""

  local backup_path
  backup_path=$(create_backup)
  echo ""

  # 尝试从 GitHub 更新
  if update_from_github "$target_version"; then
    echo ""
    printf "${GREEN}✓ 从 GitHub 升级成功${NC}\n"
  else
    printf "${YELLOW}⚠ GitHub 更新失败，执行本地版本更新${NC}\n"
    echo "$target_version" > "$VERSION_FILE"
  fi

  # 写入升级信息
  write_upgrade_info "$current_version" "$target_version"

  echo ""
  printf "新版本: %s\n" "$target_version"
  printf "备份位置: %s\n" "$backup_path"
}

# 列出备份
list_backups() {
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "暂无备份"
    return 0
  fi

  echo "=== 可用备份 ==="
  local count=0
  for backup in "$BACKUP_DIR"/backup_v*; do
    [ -d "$backup" ] || continue
    count=$((count + 1))
    basename "$backup"
  done | sort -r | nl
}

# 清理旧备份
cleanup_backups() {
  local keep_count="${1:-5}"

  [ -d "$BACKUP_DIR" ] || return 0

  printf "${BLUE}清理旧备份（保留最近 %s 个）...${NC}\n" "$keep_count"

  local backups=()
  for backup in "$BACKUP_DIR"/backup_v*; do
    [ -d "$backup" ] && backups+=("$backup")
  done

  local total=${#backups[@]}
  [ "$total" -le "$keep_count" ] && {
    echo "备份数量未超过限制，无需清理"
    return 0
  }

  # 按修改时间排序
  IFS=$'\n' sorted_backups=($(ls -td "${backups[@]}" 2>/dev/null || echo ""))
  unset IFS

  local to_delete=$((total - keep_count))
  printf "将删除 %s 个旧备份\n" "$to_delete"

  for ((i=keep_count; i<total; i++)); do
    [ -n "${sorted_backups[$i]}" ] && [ -d "${sorted_backups[$i]}" ] && {
      printf "删除: %s\n" "$(basename "${sorted_backups[$i]}")"
      rm -rf "${sorted_backups[$i]}"
    }
  done

  printf "${GREEN}✓ 清理完成${NC}\n"
}

# 显示升级历史
show_upgrade_history() {
  echo "=== 升级历史 ==="

  if [ -f "$UPGRADE_FILE" ]; then
    cat "$UPGRADE_FILE"
  else
    echo "暂无升级记录"
  fi

  echo ""
  echo "=== 版本历史 ==="
  if [ -f "$CONFIG_DIR/.upgrade-history" ]; then
    cat "$CONFIG_DIR/.upgrade-history"
  else
    echo "暂无版本记录"
  fi
}

# 显示帮助
show_help() {
  cat << 'EOF'
Content Workflow 升级工具

用法:
  upgrade.sh [命令] [选项]

命令:
  upgrade [版本]    升级到指定版本（默认从GitHub获取最新）
  backup            创建当前版本备份
  restore <编号>    恢复到指定备份
  list              列出所有备份
  cleanup [数量]    清理旧备份（默认保留5个）
  history           显示升级历史
  version           显示当前版本
  help              显示此帮助

示例:
  upgrade.sh              # 检查并升级到最新版本
  upgrade.sh 2.1.0        # 升级到指定版本
  upgrade.sh backup
  upgrade.sh restore 1
  upgrade.sh cleanup 3

仓库: https://github.com/amorist/content-workflow
EOF
}

# 主入口
case "${1:-}" in
  upgrade|up|"" )
    perform_upgrade "${2:-}"
    ;;
  backup|bak)
    create_backup
    ;;
  restore|res)
    [ -z "${2:-}" ] && {
      printf "${RED}错误: 请指定备份编号${NC}\n"
      list_backups
      exit 1
    }
    [ -d "$BACKUP_DIR" ] || {
      printf "${RED}错误: 没有可用备份${NC}\n"
      exit 1
    }
    target_backup=$(list_backups | grep "^ *${2}\." | sed 's/^ *[0-9]*\. //')
    [ -z "$target_backup" ] && {
      printf "${RED}错误: 无效的备份编号${NC}\n"
      list_backups
      exit 1
    }
    restore_backup "$BACKUP_DIR/$target_backup"
    ;;
  list|ls)
    list_backups
    ;;
  cleanup|clean)
    cleanup_backups "${2:-5}"
    ;;
  history|hist)
    show_upgrade_history
    ;;
  version|v)
    printf "当前版本: %s\n" "$(get_current_version)"
    ;;
  help|h|--help|-h)
    show_help
    ;;
  *)
    show_help
    exit 1
    ;;
esac
