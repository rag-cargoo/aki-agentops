#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: validate_env.sh [--fix] [--quiet]

Options:
  --fix    Attempt automatic remediation (idempotent)
  --quiet  Suppress human-readable logs (key=value output is always printed)
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi

fix_mode="false"
quiet_mode="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix)
      fix_mode="true"
      shift
      ;;
    --quiet)
      quiet_mode="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[env-validate] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

runtime_dir="$repo_root/.codex/runtime"
state_dir="$repo_root/.codex/state"
hooks_path_expected=".githooks"
hooks_file_rel=".githooks/pre-commit"

required_exec_rel=(
  ".githooks/pre-commit"
  "skills/aki-codex-core/scripts/create-backup-point.sh"
  "skills/aki-codex-core/scripts/check-skill-naming.sh"
  "skills/aki-codex-precommit/scripts/precommit_mode.sh"
  "skills/aki-codex-precommit/scripts/validate-precommit-chain.sh"
  "skills/aki-codex-precommit/scripts/run-project-api-script-tests.sh"
  "skills/aki-codex-session-reload/scripts/sync-skill.sh"
  "skills/aki-codex-session-reload/scripts/run-skill-hooks.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/skills_reload.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/project_reload.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/validate_env.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/sync_mcp_config.sh"
  "skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh"
)

if [[ "$fix_mode" == "true" ]]; then
  mkdir -p "$runtime_dir" "$state_dir"
  git -C "$repo_root" config core.hooksPath "$hooks_path_expected"
  for rel_path in "${required_exec_rel[@]}"; do
    abs_path="$repo_root/$rel_path"
    if [[ -f "$abs_path" ]]; then
      chmod +x "$abs_path"
    fi
  done
fi

hooks_path_current="$(git -C "$repo_root" config --get core.hooksPath || true)"
if [[ -z "$hooks_path_current" ]]; then
  hooks_path_current="(unset)"
fi
runtime_exists="false"
if [[ -d "$runtime_dir" ]]; then
  runtime_exists="true"
fi
state_exists="false"
if [[ -d "$state_dir" ]]; then
  state_exists="true"
fi

declare -a missing_files=()
declare -a nonexec_files=()
for rel_path in "${required_exec_rel[@]}"; do
  abs_path="$repo_root/$rel_path"
  if [[ ! -f "$abs_path" ]]; then
    missing_files+=("$rel_path")
    continue
  fi
  if [[ ! -x "$abs_path" ]]; then
    nonexec_files+=("$rel_path")
  fi
done

status="OK"
if [[ "$hooks_path_current" != "$hooks_path_expected" ]]; then
  status="WARN"
fi
if [[ "$runtime_exists" != "true" ]]; then
  status="WARN"
fi
if [[ "$state_exists" != "true" ]]; then
  status="WARN"
fi
if [[ "${#missing_files[@]}" -gt 0 || "${#nonexec_files[@]}" -gt 0 ]]; then
  status="WARN"
fi

action_cmd="./skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh"

if [[ "$quiet_mode" != "true" ]]; then
  echo "[env-validate] status: $status"
  echo "[env-validate] hooksPath: $hooks_path_current (expected: $hooks_path_expected)"
  if [[ "$runtime_exists" != "true" ]]; then
    echo "[env-validate] missing runtime dir: .codex/runtime"
  fi
  if [[ "$state_exists" != "true" ]]; then
    echo "[env-validate] missing state dir: .codex/state"
  fi
  if [[ "${#missing_files[@]}" -gt 0 ]]; then
    echo "[env-validate] missing files: $(IFS=', '; echo "${missing_files[*]}")"
  fi
  if [[ "${#nonexec_files[@]}" -gt 0 ]]; then
    echo "[env-validate] non-executable files: $(IFS=', '; echo "${nonexec_files[*]}")"
  fi
  if [[ "$status" != "OK" ]]; then
    echo "[env-validate] action: $action_cmd"
  fi
fi

echo "ENV_STATUS=$status"
echo "HOOKS_PATH_CURRENT=$hooks_path_current"
echo "HOOKS_PATH_EXPECTED=$hooks_path_expected"
echo "RUNTIME_DIR_EXISTS=$runtime_exists"
echo "STATE_DIR_EXISTS=$state_exists"
echo "FIX_APPLIED=$fix_mode"
echo "MISSING_COUNT=${#missing_files[@]}"
echo "NONEXEC_COUNT=${#nonexec_files[@]}"
echo "MISSING_FILES=$(IFS=','; echo "${missing_files[*]}")"
echo "NONEXEC_FILES=$(IFS=','; echo "${nonexec_files[*]}")"
echo "ACTION=$action_cmd"
