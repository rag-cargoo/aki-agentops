#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  precommit_mode.sh status
  precommit_mode.sh quick
  precommit_mode.sh strict

Notes:
  - This sets the default local mode used by .githooks/pre-commit.
  - One-shot override is also possible:
      CHAIN_VALIDATION_MODE=strict git commit -m "..."
EOF
}

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

mode_file=".codex/runtime/precommit_mode"
runtime_flags_entry="./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh"
mkdir -p "$(dirname "$mode_file")"

command="${1:-status}"

case "$command" in
  status)
    if [[ -f "$mode_file" ]]; then
      current_mode="$(tr -d '[:space:]' < "$mode_file")"
    else
      current_mode="quick"
    fi
    case "$current_mode" in
      quick|strict) ;;
      *)
        echo "[precommit-mode] invalid value in $mode_file: $current_mode" >&2
        exit 1
        ;;
    esac
    echo "[precommit-mode] current default: $current_mode"
    ;;
  quick|strict)
    echo "$command" > "$mode_file"
    if [[ -x "$runtime_flags_entry" ]]; then
      "$runtime_flags_entry" sync --quiet >/dev/null || true
    fi
    echo "[precommit-mode] default set to: $command"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "[precommit-mode] unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
