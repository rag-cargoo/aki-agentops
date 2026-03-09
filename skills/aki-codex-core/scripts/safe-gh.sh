#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  safe-gh.sh --repo <owner/repo> <gh-args...>

Examples:
  ./skills/aki-codex-core/scripts/safe-gh.sh --repo rag-cargoo/aki-agentops issue list --state open
  ./skills/aki-codex-core/scripts/safe-gh.sh --repo rag-cargoo/ticket-core-service pr list
EOF
}

repo_slug=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo|-R|-r)
      if [[ $# -lt 2 ]]; then
        echo "[safe-gh] --repo requires an owner/repo value" >&2
        usage
        exit 1
      fi
      repo_slug="$2"
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

if [[ -z "$repo_slug" ]]; then
  echo "[safe-gh] repository slug is required" >&2
  usage
  exit 1
fi

if [[ $# -eq 0 ]]; then
  echo "[safe-gh] gh arguments are required" >&2
  usage
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "[safe-gh] gh CLI is required" >&2
  exit 1
fi

if [[ ! "$repo_slug" =~ ^[^/]+/[^/]+$ ]]; then
  echo "[safe-gh] invalid repo slug: $repo_slug (expected owner/repo)" >&2
  exit 1
fi

exec gh -R "$repo_slug" "$@"
