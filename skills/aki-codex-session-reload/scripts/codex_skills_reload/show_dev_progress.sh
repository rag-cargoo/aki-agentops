#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  show_dev_progress.sh
  show_dev_progress.sh --task <task.md path>

Options:
  --task <path>   Task dashboard path (repo-root relative or absolute)
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi

task_doc_arg=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      task_doc_arg="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[show-dev-progress] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

project_snapshot="$repo_root/.codex/runtime/codex_project_reload.md"
default_task_doc="prj-docs/task.md"
task_doc_rel=""
task_doc_abs=""

resolve_task_doc_from_snapshot() {
  local line=""
  if [[ ! -f "$project_snapshot" ]]; then
    return 0
  fi
  line="$(grep -E '^- Task Doc:' "$project_snapshot" | head -n 1 || true)"
  if [[ -z "$line" ]]; then
    return 0
  fi
  sed -E 's/^- Task Doc: `([^`]+)`/\1/' <<<"$line"
}

if [[ -n "$task_doc_arg" ]]; then
  task_doc_rel="$task_doc_arg"
else
  task_doc_rel="$(resolve_task_doc_from_snapshot)"
  if [[ -z "$task_doc_rel" || "$task_doc_rel" == "- Task Doc:"* ]]; then
    task_doc_rel="$default_task_doc"
  fi
fi

if [[ "$task_doc_rel" = /* ]]; then
  task_doc_abs="$task_doc_rel"
  task_doc_rel="${task_doc_abs#$repo_root/}"
else
  task_doc_abs="$repo_root/$task_doc_rel"
fi

if [[ ! -f "$task_doc_abs" ]]; then
  echo "[show-dev-progress] task doc not found: $task_doc_abs" >&2
  exit 1
fi

task_updated_at="$(grep -E '\*\*Updated At\*\*' "$task_doc_abs" | head -n 1 | sed -E 's/.*`([^`]+)`.*/\1/' || true)"

declare -a item_titles=()
declare -a item_statuses=()

in_current_items="false"
current_index="-1"

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^##[[:space:]]+Current[[:space:]]+Items ]]; then
    in_current_items="true"
    continue
  fi
  if [[ "$in_current_items" == "true" && "$line" =~ ^##[[:space:]]+ ]]; then
    break
  fi
  if [[ "$in_current_items" != "true" ]]; then
    continue
  fi

  if [[ "$line" =~ ^-[[:space:]]+(.+) ]]; then
    item_titles+=("${BASH_REMATCH[1]}")
    item_statuses+=("UNSET")
    current_index="$((${#item_titles[@]} - 1))"
    continue
  fi

  if [[ "$current_index" -ge 0 && "$line" =~ ^[[:space:]]+-[[:space:]]Status:[[:space:]]*([A-Za-z_[:space:]-]+)$ ]]; then
    raw_status="${BASH_REMATCH[1]}"
    normalized_status="$(echo "$raw_status" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]')"
    item_statuses[$current_index]="$normalized_status"
  fi
done < "$task_doc_abs"

done_count=0
todo_count=0
doing_count=0
blocked_count=0
other_count=0

status_to_mark() {
  local status="$1"
  case "$status" in
    DONE|PASS|COMPLETED) echo "[x]" ;;
    TODO|NOT_STARTED|NOTSTARTED) echo "[ ]" ;;
    DOING|IN_PROGRESS|INPROGRESS|WIP) echo "[~]" ;;
    BLOCKED|ON_HOLD|ONHOLD|HOLD) echo "[!]" ;;
    *) echo "[?]" ;;
  esac
}

accumulate_count() {
  local status="$1"
  case "$status" in
    DONE|PASS|COMPLETED) done_count=$((done_count + 1)) ;;
    TODO|NOT_STARTED|NOTSTARTED) todo_count=$((todo_count + 1)) ;;
    DOING|IN_PROGRESS|INPROGRESS|WIP) doing_count=$((doing_count + 1)) ;;
    BLOCKED|ON_HOLD|ONHOLD|HOLD) blocked_count=$((blocked_count + 1)) ;;
    *) other_count=$((other_count + 1)) ;;
  esac
}

echo "[Development Progress]"
echo "Task Doc: ${task_doc_rel}"
if [[ -n "$task_updated_at" ]]; then
  echo "Task Updated At: ${task_updated_at}"
fi
echo ""

if [[ "${#item_titles[@]}" -eq 0 ]]; then
  echo "Current Items: none"
  exit 0
fi

echo "Current Items:"
for idx in "${!item_titles[@]}"; do
  status="${item_statuses[$idx]}"
  mark="$(status_to_mark "$status")"
  accumulate_count "$status"
  echo "${mark} ${item_titles[$idx]} (Status: ${status})"
done

echo ""
echo "Summary: total=${#item_titles[@]} done=${done_count} todo=${todo_count} doing=${doing_count} blocked=${blocked_count} other=${other_count}"
