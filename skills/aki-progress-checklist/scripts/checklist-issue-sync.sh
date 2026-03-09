#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  checklist-issue-sync.sh \
    --issue <number> \
    --checklist-file <path> \
    [--repo <owner/repo>] \
    [--summary "<text>"] \
    [--verification-file <path>] \
    [--evidence-file <path>] \
    [--mode upsert|append] \
    [--marker "<!-- aki-progress-checklist:sync -->"]

Behavior:
  - append: always add a new issue comment
  - upsert(default): find my previous comment that includes marker and edit it; create if none

Examples:
  checklist-issue-sync.sh \
    --repo rag-cargoo/ticket-web-app \
    --issue 31 \
    --checklist-file /tmp/checklist.md \
    --summary "Admin form cleanup + OAuth fallback"

  checklist-issue-sync.sh \
    --issue 31 \
    --checklist-file /tmp/checklist.md \
    --verification-file /tmp/verify.md \
    --evidence-file /tmp/evidence.md \
    --mode upsert
USAGE
}

issue_number=""
repo=""
checklist_file=""
summary=""
verification_file=""
evidence_file=""
mode="upsert"
marker="<!-- aki-progress-checklist:sync -->"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --issue)
      issue_number="${2:-}"
      shift 2
      ;;
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --checklist-file)
      checklist_file="${2:-}"
      shift 2
      ;;
    --summary)
      summary="${2:-}"
      shift 2
      ;;
    --verification-file)
      verification_file="${2:-}"
      shift 2
      ;;
    --evidence-file)
      evidence_file="${2:-}"
      shift 2
      ;;
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --marker)
      marker="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[checklist-sync] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$issue_number" || -z "$checklist_file" ]]; then
  echo "[checklist-sync] --issue and --checklist-file are required" >&2
  usage
  exit 1
fi

if [[ ! "$issue_number" =~ ^[0-9]+$ ]]; then
  echo "[checklist-sync] --issue must be a positive number" >&2
  exit 1
fi

if [[ ! -f "$checklist_file" ]]; then
  echo "[checklist-sync] checklist file not found: $checklist_file" >&2
  exit 1
fi

if [[ -n "$verification_file" && ! -f "$verification_file" ]]; then
  echo "[checklist-sync] verification file not found: $verification_file" >&2
  exit 1
fi

if [[ -n "$evidence_file" && ! -f "$evidence_file" ]]; then
  echo "[checklist-sync] evidence file not found: $evidence_file" >&2
  exit 1
fi

if [[ "$mode" != "upsert" && "$mode" != "append" ]]; then
  echo "[checklist-sync] --mode must be upsert or append" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "[checklist-sync] gh CLI not found" >&2
  exit 1
fi

repo_args=()
if [[ -n "$repo" ]]; then
  repo_args=(-R "$repo")
fi

resolved_repo="$repo"
if [[ -z "$resolved_repo" ]]; then
  resolved_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
fi

actor_login="$(gh api user --jq .login)"

tmp_dir="$(mktemp -d)"
body_file="$tmp_dir/comment-body.md"
payload_file="$tmp_dir/comment-payload.json"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

{
  echo "$marker"
  echo "## Progress Checklist Sync"
  echo "- Updated At: \\`$(date '+%Y-%m-%d %H:%M:%S')\\`"
  if [[ -n "$summary" ]]; then
    echo "- Summary: $summary"
  fi
  echo
  echo "### Checklist"
  cat "$checklist_file"

  if [[ -n "$verification_file" ]]; then
    echo
    echo "### Verification"
    cat "$verification_file"
  fi

  if [[ -n "$evidence_file" ]]; then
    echo
    echo "### Evidence"
    cat "$evidence_file"
  fi
} >"$body_file"

if [[ "$mode" == "append" ]]; then
  gh issue comment "$issue_number" "${repo_args[@]}" --body-file "$body_file" >/dev/null
  echo "[checklist-sync] appended comment to issue #$issue_number ($resolved_repo)"
  exit 0
fi

comments_json="$(gh issue view "$issue_number" "${repo_args[@]}" --json comments)"
comment_id="$({
  COMMENTS_JSON="$comments_json" MARKER="$marker" ACTOR="$actor_login" python3 - <<'PY'
import json
import os

comments_data = json.loads(os.environ.get("COMMENTS_JSON", "{}"))
marker = os.environ.get("MARKER", "")
actor = os.environ.get("ACTOR", "")

matched = ""
for comment in comments_data.get("comments", []):
    author = ((comment.get("author") or {}).get("login") or "").strip()
    body = (comment.get("body") or "")
    if marker in body and author == actor:
        matched = str(comment.get("id") or "")

print(matched)
PY
} 2>/dev/null)"

if [[ -n "$comment_id" ]]; then
  BODY_FILE="$body_file" PAYLOAD_FILE="$payload_file" python3 - <<'PY'
import json
import os
from pathlib import Path

body_path = Path(os.environ["BODY_FILE"])
payload_path = Path(os.environ["PAYLOAD_FILE"])
payload_path.write_text(json.dumps({"body": body_path.read_text(encoding="utf-8")}, ensure_ascii=False), encoding="utf-8")
PY

  gh api --method PATCH "repos/$resolved_repo/issues/comments/$comment_id" --input "$payload_file" >/dev/null
  echo "[checklist-sync] updated existing comment(id=$comment_id) on issue #$issue_number ($resolved_repo)"
  exit 0
fi

gh issue comment "$issue_number" "${repo_args[@]}" --body-file "$body_file" >/dev/null
echo "[checklist-sync] created new checklist comment on issue #$issue_number ($resolved_repo)"
