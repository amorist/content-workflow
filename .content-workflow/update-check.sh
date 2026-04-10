#!/bin/bash
# Content Workflow Update Check - 更新检查脚本

set -e

# 获取脚本所在目录（兼容 macOS/Linux/Windows Git Bash）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_ROOT="$(dirname "$SCRIPT_DIR")"

VERSION_FILE="$WORKFLOW_ROOT/.version"
CONFIG_DIR="$SCRIPT_DIR"

# GitHub 仓库配置
GITHUB_REPO="${GITHUB_REPO:-amorist/content-workflow}"
REMOTE_VERSION_URL="${REMOTE_VERSION_URL:-https://raw.githubusercontent.com/${GITHUB_REPO}/main/.version}"

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
    curl -s "$REMOTE_VERSION_URL" 2>/dev/null | tr -d '[:space:]' || echo ""
  else
    echo ""
  fi
}

# 版本号比较
compare_versions() {
  local v1="$1"
  local v2="$2"

  if [ "$v1" = "$v2" ]; then
    return 0
  fi

  # 使用 sort -V 进行版本比较
  local higher
  higher=$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | tail -n 1)

  if [ "$higher" = "$v2" ]; then
    return 2
  else
    return 1
  fi
}

# 检查更新
check_update() {
  local current_version
  current_version=$(get_current_version)
  local remote_version
  remote_version=$(get_remote_version)
  local last_check_file="$CONFIG_DIR/.last-update-check"

  printf "${BLUE}检查更新...${NC}\n"
  printf "当前版本: ${GREEN}%s${NC}\n" "$current_version"

  if [ -z "$remote_version" ]; then
    printf "${YELLOW}⚠ 无法获取远程版本信息${NC}\n"
    touch "$last_check_file" 2>/dev/null || true
    return 1
  fi

  printf "远程版本: ${GREEN}%s${NC}\n" "$remote_version"

  compare_versions "$current_version" "$remote_version"
  local result=$?

  if [ $result -eq 2 ]; then
    echo ""
    printf "${YELLOW}╔════════════════════════════════════╗${NC}\n"
    printf "${YELLOW}║     🎉 有新版本可用！              ║${NC}\n"
    printf "${YELLOW}╚════════════════════════════════════╝${NC}\n"
    echo ""
    printf "当前: ${RED}%s${NC} → 最新: ${GREEN}%s${NC}\n" "$current_version" "$remote_version"
    echo ""
    echo "更新方式:"
    echo "  1. 自动更新: bash .content-workflow/upgrade.sh"
    echo "  2. 手动更新: git pull origin main"
    echo ""
    echo "仓库地址: https://github.com/$GITHUB_REPO"
    touch "$last_check_file" 2>/dev/null || true
    return 0
  elif [ $result -eq 0 ]; then
    printf "${GREEN}✓ 已是最新版本${NC}\n"
  else
    printf "${YELLOW}⚠ 本地版本高于远程版本${NC}\n"
  fi

  touch "$last_check_file" 2>/dev/null || true
}

# 显示版本信息
show_version() {
  local version
  version=$(get_current_version)
  printf "${BLUE}Content Workflow${NC} 版本 ${GREEN}%s${NC}\n" "$version"
  echo ""
  echo "仓库: https://github.com/$GITHUB_REPO"
  echo "更新检查: $(date 2>/dev/null || echo 'unknown')"
}

# 主入口
case "${1:-}" in
  --version|-v)
    get_current_version
    ;;
  --check|-c)
    check_update
    ;;
  --info|-i)
    show_version
    ;;
  *)
    check_update
    ;;
esac
