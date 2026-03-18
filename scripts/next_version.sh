#!/usr/bin/env bash
# next_version.sh — 生成下一个 vYYYY.MM.DD.N 版本号
# 读取当天已有 git tag，输出当天的下一个可用版本

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY=$(date +%Y.%m.%d)
PREFIX="v${TODAY}."

cd "$REPO_DIR"
git fetch --tags --quiet 2>/dev/null || true

LAST_N=$(git tag --list "${PREFIX}*" 2>/dev/null \
    | sed "s/^${PREFIX}//" \
    | grep -E '^[0-9]+$' \
    | sort -n \
    | tail -1)

NEXT_N=$(( ${LAST_N:-0} + 1 ))
echo "${PREFIX}${NEXT_N}"
