#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  show_runtime_status.sh
  show_runtime_status.sh --alerts-only

Options:
  --alerts-only   Print alerts section only.
EOF
}

alerts_only="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --alerts-only)
      alerts_only="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[show-runtime-status] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel)"
runtime_flags_script="$repo_root/skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh"

bash "$runtime_flags_script" sync --quiet >/dev/null
if [[ "$alerts_only" == "true" ]]; then
  bash "$runtime_flags_script" alerts
  exit 0
fi

bash "$runtime_flags_script" status
bash "$runtime_flags_script" alerts
