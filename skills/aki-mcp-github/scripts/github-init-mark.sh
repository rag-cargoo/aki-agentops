#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  github-init-mark.sh --status <PASS|FAIL|NOT_RUN|WARN|BLOCKED> \
    [--enabled <csv>] [--failed <csv>] [--unsupported <csv>] [--source <id>]

Examples:
  github-init-mark.sh --status PASS \
    --enabled context,repos,issues,projects,pull_requests,labels \
    --failed none --unsupported none

  github-init-mark.sh --status FAIL \
    --enabled context,repos --failed projects --unsupported none
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../.." && pwd)"
fi

workflow_mark_script="$repo_root/skills/aki-codex-workflows/scripts/workflow_mark.sh"

status=""
enabled="none"
failed="none"
unsupported="none"
source_id="aki-mcp-github:init"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status)
      status="${2:-}"
      shift 2
      ;;
    --enabled)
      enabled="${2:-}"
      shift 2
      ;;
    --failed)
      failed="${2:-}"
      shift 2
      ;;
    --unsupported)
      unsupported="${2:-}"
      shift 2
      ;;
    --source)
      source_id="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[github-init-mark] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$status" ]]; then
  echo "[github-init-mark] --status is required" >&2
  usage
  exit 1
fi

status="$(echo "$status" | tr '[:lower:]' '[:upper:]')"
case "$status" in
  PASS|FAIL|NOT_RUN|WARN|BLOCKED) ;;
  *)
    echo "[github-init-mark] invalid --status: $status" >&2
    exit 1
    ;;
esac

if [[ ! -x "$workflow_mark_script" ]]; then
  echo "[github-init-mark] workflow mark script missing: $workflow_mark_script" >&2
  exit 1
fi

detail="enabled=${enabled};failed=${failed};unsupported=${unsupported}"
"$workflow_mark_script" set \
  --workflow "github_mcp_init" \
  --status "$status" \
  --source "$source_id" \
  --detail "$detail"

echo "[github-init-mark] recorded github_mcp_init=$status"

