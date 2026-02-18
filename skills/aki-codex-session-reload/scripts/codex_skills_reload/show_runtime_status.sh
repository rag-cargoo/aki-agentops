#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  show_runtime_status.sh
  show_runtime_status.sh --alerts-only
  show_runtime_status.sh --with-progress

Options:
  --alerts-only   Print alerts section only.
  --with-progress Print development progress checklist after runtime status.
EOF
}

alerts_only="false"
with_progress="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --alerts-only)
      alerts_only="true"
      shift
      ;;
    --with-progress)
      with_progress="true"
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
progress_script="$repo_root/skills/aki-codex-session-reload/scripts/codex_skills_reload/show_dev_progress.sh"
workflow_mark_script="$repo_root/skills/aki-codex-workflows/scripts/workflow_mark.sh"

print_progress_and_mark() {
  local progress_output=""
  local task_doc_from_output=""
  local mark_detail="mode=with-progress;reason=show_dev_progress_failed"
  local mark_status="FAIL"

  echo
  if progress_output="$(bash "$progress_script" 2>&1)"; then
    printf '%s\n' "$progress_output"
    mark_status="PASS"
    task_doc_from_output="$(awk -F': ' '/^Task Doc:/ {print $2; exit}' <<< "$progress_output" || true)"
    mark_detail="mode=with-progress;task_doc=${task_doc_from_output:-unknown}"
  else
    printf '%s\n' "$progress_output" >&2
  fi

  if [[ -x "$workflow_mark_script" ]]; then
    bash "$workflow_mark_script" set \
      --workflow development_progress_visibility \
      --status "$mark_status" \
      --source show_runtime_status.sh \
      --detail "$mark_detail" >/dev/null 2>&1 || true
  fi

  if [[ "$mark_status" != "PASS" ]]; then
    return 1
  fi
}

bash "$runtime_flags_script" sync --quiet >/dev/null
if [[ "$alerts_only" == "true" ]]; then
  bash "$runtime_flags_script" alerts
  if [[ "$with_progress" == "true" ]]; then
    print_progress_and_mark
  fi
  exit 0
fi

bash "$runtime_flags_script" status
bash "$runtime_flags_script" alerts
if [[ "$with_progress" == "true" ]]; then
  print_progress_and_mark
fi
