#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../.." && pwd)"
fi
workflow_mark_script="$repo_root/skills/aki-codex-workflows/scripts/workflow_mark.sh"

usage() {
  cat <<'EOF'
Usage:
  issue-upsert.sh --title "<title>" --body-file <file> [--search "<query>"] [--labels "a,b,c"] [--allow-new true|false]

Behavior (reopen-first):
  1) Search existing issues by title query (open+closed).
  2) If matching OPEN issue exists: add progress comment (no new issue).
  3) If matching CLOSED issue exists: reopen + add progress comment.
  4) If none exists: create new issue (unless --allow-new false).

Examples:
  issue-upsert.sh --title "[Core] Foo 개선" --body-file /tmp/body.md --labels "status:todo,area:core"
  issue-upsert.sh --title "[Core] Foo 개선" --body-file /tmp/body.md --search "Foo 개선" --allow-new false
EOF
}

title=""
body_file=""
search_query=""
labels_csv=""
allow_new="true"
lifecycle_action="validate_args"

workflow_mark_recorded="false"
record_issue_lifecycle_mark() {
  local workflow_status="$1"
  local mark_query="${search_query:-none}"
  local mark_detail="action=${lifecycle_action};query=${mark_query};allow_new=${allow_new:-unknown}"
  if [[ "$workflow_mark_recorded" == "true" ]]; then
    return 0
  fi
  workflow_mark_recorded="true"
  if [[ ! -x "$workflow_mark_script" ]]; then
    return 0
  fi
  "$workflow_mark_script" set \
    --workflow "issue_lifecycle_governance" \
    --status "$workflow_status" \
    --source "issue-upsert.sh" \
    --detail "$mark_detail" >/dev/null 2>&1 || true
}

on_issue_upsert_exit() {
  local exit_code="$1"
  if [[ "$exit_code" -eq 0 ]]; then
    record_issue_lifecycle_mark "PASS"
  else
    record_issue_lifecycle_mark "FAIL"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      title="${2:-}"
      shift 2
      ;;
    --body-file)
      body_file="${2:-}"
      shift 2
      ;;
    --search)
      search_query="${2:-}"
      shift 2
      ;;
    --labels)
      labels_csv="${2:-}"
      shift 2
      ;;
    --allow-new)
      allow_new="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[issue-upsert] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$title" || -z "$body_file" ]]; then
  echo "[issue-upsert] --title and --body-file are required" >&2
  usage
  exit 1
fi

if [[ ! -f "$body_file" ]]; then
  echo "[issue-upsert] body file not found: $body_file" >&2
  exit 1
fi

if [[ "$allow_new" != "true" && "$allow_new" != "false" ]]; then
  echo "[issue-upsert] --allow-new must be true or false" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "[issue-upsert] gh CLI not found" >&2
  exit 1
fi

trap 'on_issue_upsert_exit $?' EXIT

if [[ -z "$search_query" ]]; then
  search_query="$title"
fi
lifecycle_action="searched"

search_json="$(gh issue list --state all --search "${search_query} in:title" --limit 100 --json number,title,state,url)"

candidate_line="$(
  SEARCH_JSON="$search_json" python3 - "$title" <<'PY'
import json, sys
import os
target = sys.argv[1].strip().lower()
items = json.loads(os.environ.get("SEARCH_JSON", "[]"))

def exact_priority(item):
    title = (item.get("title") or "").strip().lower()
    if title == target:
        return 0
    if target in title:
        return 1
    return 2

items = sorted(items, key=lambda x: (exact_priority(x), 0 if x.get("state") == "OPEN" else 1, x.get("number", 0)))
for item in items:
    if exact_priority(item) <= 1:
        print(f'{item["number"]}|{item["state"]}|{item["url"]}|{item.get("title","")}')
        break
PY
)"

if [[ -n "$candidate_line" ]]; then
  issue_number="${candidate_line%%|*}"
  rest="${candidate_line#*|}"
  issue_state="${rest%%|*}"
  rest="${rest#*|}"
  issue_url="${rest%%|*}"
  issue_title="${rest#*|}"

  if [[ "$issue_state" == "OPEN" ]]; then
    lifecycle_action="updated_open"
    gh issue comment "$issue_number" --body-file "$body_file" >/dev/null
    echo "[issue-upsert] updated existing OPEN issue: #$issue_number ($issue_title)"
    echo "$issue_url"
    exit 0
  fi

  lifecycle_action="reopened_closed"
  gh issue reopen "$issue_number" >/dev/null
  gh issue comment "$issue_number" --body-file "$body_file" >/dev/null
  echo "[issue-upsert] reopened and updated issue: #$issue_number ($issue_title)"
  echo "$issue_url"
  exit 0
fi

if [[ "$allow_new" == "false" ]]; then
  lifecycle_action="blocked_allow_new_false"
  echo "[issue-upsert] no existing issue found and --allow-new=false" >&2
  exit 1
fi

lifecycle_action="created_new"
create_cmd=(gh issue create --title "$title" --body-file "$body_file")
if [[ -n "$labels_csv" ]]; then
  IFS=',' read -r -a labels <<<"$labels_csv"
  for label in "${labels[@]}"; do
    trimmed="${label#"${label%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
    [[ -z "$trimmed" ]] && continue
    create_cmd+=(--label "$trimmed")
  done
fi

new_url="$("${create_cmd[@]}")"
echo "[issue-upsert] created new issue"
echo "$new_url"
