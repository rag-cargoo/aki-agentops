#!/usr/bin/env bash
set -euo pipefail

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

if [[ -z "$search_query" ]]; then
  search_query="$title"
fi

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
    gh issue comment "$issue_number" --body-file "$body_file" >/dev/null
    echo "[issue-upsert] updated existing OPEN issue: #$issue_number ($issue_title)"
    echo "$issue_url"
    exit 0
  fi

  gh issue reopen "$issue_number" >/dev/null
  gh issue comment "$issue_number" --body-file "$body_file" >/dev/null
  echo "[issue-upsert] reopened and updated issue: #$issue_number ($issue_title)"
  echo "$issue_url"
  exit 0
fi

if [[ "$allow_new" == "false" ]]; then
  echo "[issue-upsert] no existing issue found and --allow-new=false" >&2
  exit 1
fi

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
