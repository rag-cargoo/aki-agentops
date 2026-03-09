#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: validate-precommit-chain.sh [--mode quick|strict] [--all] [--strict-remote]

Modes:
  quick   Lightweight checks for routine commits (default)
  strict  Full policy-driven validation. Fails on uncovered target paths.

Scope:
  default  Validate only staged files (git diff --cached --name-only)
  --all    Validate all tracked files (git ls-files)

Remote:
  --strict-remote  Enable remote consistency checks (Issue/PR status vs docs) in strict mode.

Policies:
  Global:  skills/aki-codex-precommit/policies/*.sh
  Project: */prj-docs/precommit-policy.sh
EOF
}

resolve_args() {
  local cli_mode=""
  local parsed_file_scope="staged"
  local parsed_strict_remote="false"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)
        if [[ $# -lt 2 ]]; then
          echo "[chain-check] --mode requires a value" >&2
          usage
          exit 1
        fi
        cli_mode="$2"
        shift 2
        ;;
      --all)
        parsed_file_scope="all"
        shift
        ;;
      --strict-remote)
        parsed_strict_remote="true"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "[chain-check] unknown argument: $1" >&2
        usage
        exit 1
        ;;
    esac
  done

  local parsed_mode="${cli_mode:-${CHAIN_VALIDATION_MODE:-quick}}"
  case "$parsed_mode" in
    quick|strict) ;;
    *)
      echo "[chain-check] invalid mode: $parsed_mode (allowed: quick, strict)" >&2
      exit 1
      ;;
  esac

  mode="$parsed_mode"
  file_scope="$parsed_file_scope"
  strict_remote="$parsed_strict_remote"
}

path_matches_root() {
  local path="$1"
  local root="$2"
  [[ "$path" == "$root" || "$path" == "$root/"* ]]
}

is_temp_like_artifact() {
  local path="$1"
  case "$path" in
    *.log|*.tmp|*.temp|*.pid|*.stackdump)
      return 0
      ;;
    *k6-web-dashboard.html|*k6-dashboard*.png|*playwright*.png)
      return 0
      ;;
  esac
  return 1
}

warn_temp_artifacts_outside_codex_tmp() {
  local staged_files="$1"
  local warnings=()
  local file_path

  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    [[ "$file_path" == ".codex/tmp/"* ]] && continue
    if is_temp_like_artifact "$file_path"; then
      warnings+=("$file_path")
    fi
  done <<< "$staged_files"

  if [[ "${#warnings[@]}" -eq 0 ]]; then
    return 0
  fi

  echo "[chain-check] warning: temp-like artifacts are staged outside .codex/tmp/"
  local warned
  for warned in "${warnings[@]}"; do
    echo "  - $warned"
  done
  echo "[chain-check] recommendation:"
  echo "  - move temp artifacts to .codex/tmp/<tool>/<run-id>/"
  echo "  - keep only evidence docs/json under project docs when needed"
}

has_matching_path_for_roots() {
  local staged_files="$1"
  shift
  local roots=("$@")

  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    local root
    for root in "${roots[@]}"; do
      if path_matches_root "$file_path" "$root"; then
        return 0
      fi
    done
  done <<< "$staged_files"

  return 1
}

is_covered_by_any_root() {
  local file_path="$1"
  shift
  local roots=("$@")

  local root
  for root in "${roots[@]}"; do
    if path_matches_root "$file_path" "$root"; then
      return 0
    fi
  done
  return 1
}

mode=""
file_scope="staged"
strict_remote="false"
resolve_args "$@"

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

workflow_mark_script="$repo_root/skills/aki-codex-workflows/scripts/workflow_mark.sh"
workflow_mark_recorded="false"
record_precommit_mark() {
  local workflow_status="$1"
  local detail="mode=${mode:-unknown}"
  if [[ "$workflow_mark_recorded" == "true" ]]; then
    return 0
  fi
  workflow_mark_recorded="true"
  if [[ ! -x "$workflow_mark_script" ]]; then
    return 0
  fi
  "$workflow_mark_script" set \
    --workflow "precommit" \
    --status "$workflow_status" \
    --source "validate-precommit-chain.sh" \
    --detail "$detail" >/dev/null 2>&1 || true
}

on_precommit_exit() {
  local exit_code="$1"
  if [[ "$exit_code" -eq 0 ]]; then
    record_precommit_mark "PASS"
  else
    record_precommit_mark "FAIL"
  fi
}

trap 'on_precommit_exit $?' EXIT

if [[ "$file_scope" == "all" ]]; then
  target_files="$(git -c core.quotePath=false ls-files || true)"
else
  target_files="$(git -c core.quotePath=false diff --cached --name-only || true)"
fi

if [[ -z "$target_files" ]]; then
  exit 0
fi

warn_temp_artifacts_outside_codex_tmp "$target_files"

global_policy_dir="skills/aki-codex-precommit/policies"
mapfile -t global_policy_files < <(find "$global_policy_dir" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | sort)
mapfile -t project_policy_files < <(find . -type f -path './*/prj-docs/precommit-policy.sh' 2>/dev/null | sort | sed 's#^\./##')

export CHAIN_VALIDATION_SCOPE="$file_scope"
export CHAIN_STRICT_REMOTE="$strict_remote"

policy_files=()
if [[ "${#global_policy_files[@]}" -gt 0 ]]; then
  policy_files+=("${global_policy_files[@]}")
fi
if [[ "${#project_policy_files[@]}" -gt 0 ]]; then
  policy_files+=("${project_policy_files[@]}")
fi

if [[ "${#policy_files[@]}" -eq 0 ]]; then
  if [[ "$mode" == "strict" ]]; then
    echo "[chain-check] strict mode failed: no policy files found"
    echo "  - ${global_policy_dir}/*.sh"
    echo "  - */prj-docs/precommit-policy.sh"
    exit 1
  fi
  echo "[chain-check] quick mode: no policy files found, skip"
  exit 0
fi

all_policy_roots=()
applied_policy_ids=()

for policy_file in "${policy_files[@]}"; do
  unset POLICY_ID POLICY_ROOTS
  unset -f policy_validate || true

  # shellcheck source=/dev/null
  source "$policy_file"

  if [[ -z "${POLICY_ID:-}" ]]; then
    echo "[chain-check] invalid policy: missing POLICY_ID in $policy_file"
    exit 1
  fi
  if ! declare -p POLICY_ROOTS >/dev/null 2>&1; then
    echo "[chain-check] invalid policy: missing POLICY_ROOTS in $policy_file"
    exit 1
  fi
  if [[ "${#POLICY_ROOTS[@]}" -eq 0 ]]; then
    echo "[chain-check] invalid policy: missing POLICY_ROOTS in $policy_file"
    exit 1
  fi
  if ! declare -F policy_validate >/dev/null; then
    echo "[chain-check] invalid policy: missing policy_validate() in $policy_file"
    exit 1
  fi

  for root in "${POLICY_ROOTS[@]}"; do
    all_policy_roots+=("$root")
  done

  if has_matching_path_for_roots "$target_files" "${POLICY_ROOTS[@]}"; then
    echo "[chain-check] applying policy: ${POLICY_ID}"
    policy_validate "$mode" "$target_files"
    applied_policy_ids+=("$POLICY_ID")
  fi
done

if [[ "$mode" == "strict" && "$file_scope" != "all" ]]; then
  uncovered_files=()
  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    if ! is_covered_by_any_root "$file_path" "${all_policy_roots[@]}"; then
      uncovered_files+=("$file_path")
    fi
  done <<< "$target_files"

  if [[ "${#uncovered_files[@]}" -gt 0 ]]; then
    if [[ "$file_scope" == "all" ]]; then
      echo "[chain-check] strict mode failed: uncovered tracked paths detected"
    else
      echo "[chain-check] strict mode failed: uncovered staged paths detected"
    fi
    echo "[chain-check] add/update policy:"
    echo "  - global: ${global_policy_dir}/*.sh"
    echo "  - project: */prj-docs/precommit-policy.sh"
    for path in "${uncovered_files[@]}"; do
      echo "  - $path"
    done
    exit 1
  fi
fi

if [[ "$mode" == "strict" && "$file_scope" == "all" ]]; then
  echo "[chain-check] strict all-scope: uncovered-path guard skipped"
fi

if [[ "${#applied_policy_ids[@]}" -eq 0 ]]; then
  if [[ "$mode" == "strict" ]]; then
    echo "[chain-check] strict mode failed: no policy matched target files"
    if [[ "$file_scope" == "all" ]]; then
      echo "[chain-check] tracked files:"
    else
      echo "[chain-check] staged files:"
    fi
    echo "$target_files" | sed 's/^/  - /'
    exit 1
  fi
  echo "[chain-check] quick mode: no matching policy, skip"
  exit 0
fi

echo "[chain-check] applied policies:"
for policy_id in "${applied_policy_ids[@]}"; do
  echo "  - $policy_id"
done
echo "[chain-check] pre-commit chain validation ok (${mode})"
