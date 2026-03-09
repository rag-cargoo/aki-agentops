#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi

handoff_file="$repo_root/mcp/runtime/SESSION_HANDOFF.md"

if [[ -f "$handoff_file" ]]; then
  rm -f "$handoff_file"
  echo "cleared: ${handoff_file#$repo_root/}"
else
  echo "no handoff file: ${handoff_file#$repo_root/}"
fi
