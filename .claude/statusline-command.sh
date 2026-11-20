#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Gruvbox dark palette (24-bit)
AQUA='\033[38;2;142;192;124m'; GREEN='\033[38;2;184;187;38m'; YELLOW='\033[38;2;250;189;47m'
RED='\033[38;2;251;73;52m'; DARK_YELLOW='\033[38;2;215;153;33m'; BLUE='\033[38;2;131;165;152m'
PURPLE='\033[38;2;211;134;155m'; GRAY='\033[38;2;146;131;116m'; RESET='\033[0m'
SEP="${GRAY} | ${RESET}"

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git --no-optional-locks rev-parse --git-dir > /dev/null 2>&1 && BRANCH="${SEP}🌿 ${PURPLE}$(git --no-optional-locks branch --show-current 2>/dev/null)${RESET}"

COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${AQUA}[$MODEL]${RESET} 📁 ${BLUE}${DIR##*/}${RESET}${BRANCH}${SEP}${BAR_COLOR}${BAR} ${PCT}%${RESET}${SEP}${DARK_YELLOW}${COST_FMT}${RESET}${SEP}⏱️ ${MINS}m ${SECS}s"
