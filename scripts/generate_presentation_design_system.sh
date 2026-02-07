#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SCRIPT="$ROOT_DIR/.agents/skills/ui-ux-pro-max/scripts/search.py"
PROJECT_NAME="Jacsim"
BASE_QUERY="${1:-habit tracker productivity enterprise mobile brand expressive}"
RAW_DIR="$ROOT_DIR/design-system/jacsim/raw"

if [[ ! -f "$SKILL_SCRIPT" ]]; then
  echo "[ERROR] skill script not found: $SKILL_SCRIPT" >&2
  exit 1
fi

mkdir -p "$RAW_DIR/pages"

echo "[1/3] Generating master recommendation (raw)"
python3 "$SKILL_SCRIPT" "$BASE_QUERY" --design-system -p "$PROJECT_NAME" -f markdown > "$RAW_DIR/master-generated.md"

SCREENS=(
  home
  all-task
  calendar
  new-task
  task-update
  task-detail
  task-edit
  setting
  walkthrough
  challenge-create
  main
  app
)

query_for_screen() {
  case "$1" in
    home) echo "jacsim home dashboard hero tasks quick actions" ;;
    all-task) echo "jacsim all tasks list grouped status enterprise" ;;
    calendar) echo "jacsim calendar daily completion timeline" ;;
    new-task) echo "jacsim create challenge form title stage photo alarm" ;;
    task-update) echo "jacsim daily certification update photo memo" ;;
    task-detail) echo "jacsim challenge detail progress stage records" ;;
    task-edit) echo "jacsim edit challenge form notification target" ;;
    setting) echo "jacsim settings theme notification help app info" ;;
    walkthrough) echo "jacsim onboarding walkthrough education permission" ;;
    challenge-create) echo "jacsim challenge create modal flow" ;;
    main) echo "jacsim main container navigation root" ;;
    app) echo "jacsim app shell onboarding main switch" ;;
    *) echo "jacsim $1" ;;
  esac
}

echo "[2/3] Generating page recommendations (raw)"
for screen in "${SCREENS[@]}"; do
  query="$(query_for_screen "$screen")"
  echo "  - $screen"
  python3 "$SKILL_SCRIPT" "$query" --design-system -p "$PROJECT_NAME" -f markdown > "$RAW_DIR/pages/${screen}.md"
done

echo "[3/3] Done"
echo "Output:"
echo "  - $RAW_DIR/master-generated.md"
echo "  - $RAW_DIR/pages/*.md"
echo ""
echo "Note:"
echo "  Curated source of truth remains:"
echo "  - design-system/jacsim/MASTER.md"
echo "  - design-system/jacsim/pages/*.md"
