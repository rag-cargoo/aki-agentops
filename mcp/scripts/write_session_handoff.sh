#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi

title="Session Handoff (Ephemeral)"
reason=""
restart_required="yes"
output_file="$repo_root/mcp/runtime/SESSION_HANDOFF.md"

declare -a done_items=()
declare -a next_items=()
declare -a refs=()

usage() {
  cat <<'EOF'
Usage: write_session_handoff.sh --reason <text> [options]

Options:
  --title <text>              Override title
  --reason <text>             Required
  --done <text>               Repeatable completed-item
  --next <text>               Repeatable next-step item
  --ref <path-or-note>        Repeatable reference
  --restart-required yes|no   Default yes
  --out <path>                Default mcp/runtime/SESSION_HANDOFF.md
EOF
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

to_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      title="$2"
      shift 2
      ;;
    --reason)
      reason="$2"
      shift 2
      ;;
    --done)
      done_items+=("$2")
      shift 2
      ;;
    --next)
      next_items+=("$2")
      shift 2
      ;;
    --ref)
      refs+=("$2")
      shift 2
      ;;
    --restart-required)
      restart_required="$2"
      shift 2
      ;;
    --out)
      output_file="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

reason="$(trim "$reason")"
restart_required="$(to_lower "$(trim "$restart_required")")"
if [[ -z "$reason" ]]; then
  echo "error: --reason is required" >&2
  exit 2
fi
if [[ "$restart_required" != "yes" && "$restart_required" != "no" ]]; then
  echo "error: invalid --restart-required: $restart_required (use yes|no)" >&2
  exit 2
fi

if [[ "$output_file" != /* ]]; then
  output_file="$repo_root/$output_file"
fi
runtime_dir="$(dirname "$output_file")"
archive_dir="$runtime_dir/archive"
mkdir -p "$runtime_dir" "$archive_dir"

now_human="$(date '+%Y-%m-%d %H:%M:%S')"
now_id="$(date '+%Y%m%d-%H%M%S')"

{
  echo "# $title"
  echo
  echo "- Created At: \`$now_human\`"
  echo "- Restart Required: \`$restart_required\`"
  echo "- Reason: $reason"
  echo
  echo "## Completed"
  if [[ "${#done_items[@]}" -eq 0 ]]; then
    echo "- (none)"
  else
    for item in "${done_items[@]}"; do
      echo "- $item"
    done
  fi
  echo
  echo "## Next Actions"
  if [[ "${#next_items[@]}" -eq 0 ]]; then
    echo "1. AGENTS.md 시작 절차로 새 세션 시작"
    echo "2. SESSION_HANDOFF.md를 먼저 읽고 기존 흐름 재개"
  else
    idx=1
    for item in "${next_items[@]}"; do
      echo "$idx. $item"
      idx=$((idx + 1))
    done
  fi
  echo
  echo "## References"
  if [[ "${#refs[@]}" -eq 0 ]]; then
    echo "- mcp/manifest/mcp-manifest.sh"
  else
    for ref in "${refs[@]}"; do
      echo "- $ref"
    done
  fi
  echo
  echo "## First Prompt"
  echo "\`AGENTS.md만 읽고 시작해. 그리고 mcp/runtime/SESSION_HANDOFF.md 먼저 읽고 이어서 진행해.\`"
  echo
  echo "## Cleanup"
  echo "- 이어받기 완료 후 \`bash mcp/scripts/clear_session_handoff.sh\` 실행"
} > "$output_file"

archive_file="$archive_dir/SESSION_HANDOFF_$now_id.md"
cp "$output_file" "$archive_file"

echo "written: ${output_file#$repo_root/}"
echo "archived: ${archive_file#$repo_root/}"
