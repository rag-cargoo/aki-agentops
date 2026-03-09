#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  safe-git.sh --repo <path> <git-args...>

Examples:
  ./skills/aki-codex-core/scripts/safe-git.sh --repo /home/aki/aki-agentops status --short
  ./skills/aki-codex-core/scripts/safe-git.sh --repo workspace/apps/backend/ticket-core-service rev-parse --short HEAD
EOF
}

repo_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo|-r)
      if [[ $# -lt 2 ]]; then
        echo "[safe-git] --repo requires a path" >&2
        usage
        exit 1
      fi
      repo_path="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [[ -z "$repo_path" ]]; then
  echo "[safe-git] repository path is required" >&2
  usage
  exit 1
fi

if [[ $# -eq 0 ]]; then
  echo "[safe-git] git arguments are required" >&2
  usage
  exit 1
fi

if [[ ! -d "$repo_path" ]]; then
  echo "[safe-git] repository path not found: $repo_path" >&2
  exit 1
fi

repo_abs="$(cd "$repo_path" && pwd)"

if ! git -C "$repo_abs" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[safe-git] not a git repository: $repo_abs" >&2
  exit 1
fi

exec git -C "$repo_abs" "$@"
