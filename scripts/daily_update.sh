#!/usr/bin/env bash
# daily_update.sh — 每日自动更新 Awesome-Auto-Research repo
#
# 通过已有的 ACP 基础设施调用 Copilot CLI，执行完整更新流程。
# 读取 AGENTS.md 获取持久指令，执行发现→过滤→更新→报告→审计→推送六步工作流。
#
# 用法（crontab）：
#   TZ=Europe/Berlin
#   0 20 * * * /lhome/peizhli/Projects/Awesome-Auto-Research/scripts/daily_update.sh >> /lhome/peizhli/Projects/Awesome-Auto-Research/logs/daily.log 2>&1
#
# 环境变量（可选）：
#   AWESOME_AR_CHAT_ID   — Telegram chat_id，用于接收任务完成/失败通知
#   DELEGATE_TIMEOUT     — Copilot session 超时秒数（默认 7200 = 2小时）
#   COPILOT_MODEL        — 使用的模型（默认 claude-sonnet-4.6）

set -euo pipefail

# ─── 配置 ─────────────────────────────────────────────────────────────────────
REPO_DIR="/lhome/peizhli/Projects/Awesome-Auto-Research"
ACP_SCRIPT="/lhome/peizhli/.openclaw/workspace/tools/delegate-to-copilot-acp.sh"
CHAT_ID="${AWESOME_AR_CHAT_ID:--5225911312}"  # 默认使用 Daily Affairs 群组
TIMEOUT="${DELEGATE_TIMEOUT:-7200}"
MODEL="${COPILOT_MODEL:-claude-sonnet-4.6}"

DATE=$(date +%Y-%m-%d)

# ─── 前置检查 ─────────────────────────────────────────────────────────────────
if [[ ! -f "$ACP_SCRIPT" ]]; then
    echo "[daily_update] ERROR: ACP script not found: $ACP_SCRIPT" >&2
    exit 1
fi

if [[ ! -d "$REPO_DIR/.git" ]]; then
    echo "[daily_update] ERROR: repo not found: $REPO_DIR" >&2
    exit 1
fi

echo "[daily_update] ===== 开始 ${DATE} 例行更新 ====="

# ─── 任务 prompt ──────────────────────────────────────────────────────────────
# AGENTS.md 会被 Copilot CLI 在 CWD 内自动读取，这里只给出启动指令。
TASK="Daily maintenance run for the Awesome-Auto-Research repository.

Today is ${DATE}.

Your full operating instructions are in ${REPO_DIR}/AGENTS.md — read that file first before taking any action. It defines the repo structure, taxonomy, tier system, table schema, report quality standards, and commit convention.

Then execute the **Daily Update Task** described in AGENTS.md (Steps 1–6):
  1. Discover new autonomous-research repos and papers (last 7 days)
  2. Filter for qualifying additions (≥100 stars or top-venue publication, research automation focus)
  3. Update README.md — add table rows and Capability Matrix entries for new systems
  4. Generate full 10-section reports in reports/ for newly added systems; expand any thin existing reports
  5. Run audit: python3 ${REPO_DIR}/scripts/audit_reports.py — fix any failures before committing
  6. Commit and push using the vYYYY.MM.DD.N convention via: bash ${REPO_DIR}/scripts/next_version.sh

If nothing changed (no new qualifying systems, all reports already complete), do NOT commit — just log a summary of what you searched and why nothing was added.

Work directory: ${REPO_DIR}
Git user: Peizheng Li <edwardleelpz@gmail.com>"

# ─── 调用 ACP ─────────────────────────────────────────────────────────────────
export DELEGATE_TIMEOUT="$TIMEOUT"
export COPILOT_MODEL="$MODEL"
export DELEGATE_CWD="$REPO_DIR"

bash "$ACP_SCRIPT" "$TASK" "$CHAT_ID" "awesome-ar" "daily-update"
EXIT_CODE=$?

echo "[daily_update] ===== 结束，exit=$EXIT_CODE ====="
exit $EXIT_CODE
