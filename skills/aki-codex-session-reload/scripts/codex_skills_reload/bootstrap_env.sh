#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap_env.sh [--skip-session-start]

Bootstraps local runtime environment idempotently:
1) fix hooks path/permissions/runtime directory
2) sync MCP config template into ~/.codex/config.toml
3) validate environment status
4) (default) regenerate session snapshot
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi
mcp_config_sync_entry="$script_dir/sync_mcp_config.sh"

skip_session_start="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-session-start)
      skip_session_start="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[bootstrap-env] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

cd "$repo_root"

echo "[bootstrap-env] applying environment fixes"
"$script_dir/validate_env.sh" --fix --quiet >/dev/null

if [[ -x "$mcp_config_sync_entry" ]]; then
  echo "[bootstrap-env] syncing MCP config template"
  "$mcp_config_sync_entry" --mode apply --quiet >/dev/null
else
  echo "[bootstrap-env] MCP config sync skipped (script missing)"
fi

echo "[bootstrap-env] validating environment"
"$script_dir/validate_env.sh"

echo "[bootstrap-env] syncing runtime flags"
"$script_dir/runtime_flags.sh" sync --quiet >/dev/null

if [[ "$skip_session_start" != "true" ]]; then
  echo "[bootstrap-env] regenerating session snapshot"
  "$script_dir/session_start.sh"
fi

echo "[bootstrap-env] done"
