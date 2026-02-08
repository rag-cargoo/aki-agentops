#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: validate-ticket-core-chain.sh [--mode quick|strict]

Modes:
  quick   Lightweight checks for routine commits (default)
  strict  Full chain validation for milestone commits
EOF
}

resolve_mode() {
  local cli_mode=""

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

  local mode="${cli_mode:-${CHAIN_VALIDATION_MODE:-quick}}"
  case "$mode" in
    quick|strict) ;;
    *)
      echo "[chain-check] invalid mode: $mode (allowed: quick, strict)" >&2
      exit 1
      ;;
  esac

  echo "$mode"
}

mode="$(resolve_mode "$@")"

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

staged_files="$(git diff --cached --name-only || true)"
if [[ -z "$staged_files" ]]; then
  exit 0
fi

project_root="workspace/apps/backend/ticket-core-service"
sidebar_file="sidebar-manifest.md"

if ! grep -q "^${project_root}/" <<< "$staged_files"; then
  exit 0
fi

project_change_patterns=(
  "^${project_root}/src/main/java/.+\\.java$"
  "^${project_root}/src/main/resources/.+\\.ya?ml$"
  "^${project_root}/scripts/api/.+\\.sh$"
)

needs_chain="false"
for pattern in "${project_change_patterns[@]}"; do
  if grep -Eq "$pattern" <<< "$staged_files"; then
    needs_chain="true"
    break
  fi
done

if [[ "$needs_chain" != "true" ]]; then
  exit 0
fi

added_docs="$(git diff --cached --name-only --diff-filter=A | grep -E "^${project_root}/prj-docs/.+\\.md$" || true)"
sidebar_missing="false"
if [[ -n "$added_docs" ]] && ! grep -Fxq "$sidebar_file" <<< "$staged_files"; then
  sidebar_missing="true"
fi

has_api_script_change="false"
while IFS= read -r file_path; do
  [[ -z "$file_path" ]] && continue
  if [[ "$file_path" == "${project_root}/scripts/api/"*.sh ]]; then
    has_api_script_change="true"
    break
  fi
done <<< "$staged_files"

while IFS= read -r file_path; do
  [[ -z "$file_path" ]] && continue
  if [[ "$file_path" == "${project_root}/scripts/api/"*.sh ]]; then
    bash -n "$file_path"
  fi
done <<< "$staged_files"

if [[ "$has_api_script_change" == "true" ]]; then
  if [[ "$mode" != "strict" ]]; then
    echo "[chain-check] quick mode: API script execution test skipped"
    echo "[chain-check] hint: run strict before milestone commit"
    echo "  - CHAIN_VALIDATION_MODE=strict git commit ..."
  fi
fi

if [[ "$mode" != "strict" ]]; then
  quick_hints=()
  if ! grep -Fxq "${project_root}/prj-docs/task.md" <<< "$staged_files"; then
    quick_hints+=("${project_root}/prj-docs/task.md")
  fi
  if ! grep -Fxq "${project_root}/prj-docs/TODO.md" <<< "$staged_files"; then
    quick_hints+=("${project_root}/prj-docs/TODO.md")
  fi
  if ! grep -Eq "^${project_root}/prj-docs/api-specs/.+\\.md$" <<< "$staged_files"; then
    quick_hints+=("${project_root}/prj-docs/api-specs/*.md")
  fi
  if ! grep -Eq "^${project_root}/prj-docs/knowledge/.+\\.md$" <<< "$staged_files"; then
    quick_hints+=("${project_root}/prj-docs/knowledge/*.md")
  fi
  if ! grep -Eq "^${project_root}/scripts/http/.+\\.http$" <<< "$staged_files"; then
    quick_hints+=("${project_root}/scripts/http/*.http")
  fi
  if ! grep -Eq "^${project_root}/scripts/api/.+\\.sh$" <<< "$staged_files"; then
    quick_hints+=("${project_root}/scripts/api/*.sh")
  fi
  if [[ "${#quick_hints[@]}" -gt 0 ]]; then
    echo "[chain-check] quick mode hint: strict mode will require additional staged files"
    for path in "${quick_hints[@]}"; do
      echo "  - $path"
    done
  fi
  if [[ "$sidebar_missing" == "true" ]]; then
    echo "[chain-check] quick mode hint: new docs detected; update sidebar before strict commit"
    echo "  - ${sidebar_file}"
  fi
  echo "[chain-check] ticket-core-service project chain validation ok (quick)"
  exit 0
fi

missing=()

if ! grep -Fxq "${project_root}/prj-docs/task.md" <<< "$staged_files"; then
  missing+=("${project_root}/prj-docs/task.md")
fi
if ! grep -Fxq "${project_root}/prj-docs/TODO.md" <<< "$staged_files"; then
  missing+=("${project_root}/prj-docs/TODO.md")
fi
if ! grep -Eq "^${project_root}/prj-docs/api-specs/.+\\.md$" <<< "$staged_files"; then
  missing+=("${project_root}/prj-docs/api-specs/*.md (at least one)")
fi
if ! grep -Eq "^${project_root}/prj-docs/knowledge/.+\\.md$" <<< "$staged_files"; then
  missing+=("${project_root}/prj-docs/knowledge/*.md (at least one)")
fi
if ! grep -Eq "^${project_root}/scripts/http/.+\\.http$" <<< "$staged_files"; then
  missing+=("${project_root}/scripts/http/*.http (at least one)")
fi
if ! grep -Eq "^${project_root}/scripts/api/.+\\.sh$" <<< "$staged_files"; then
  missing+=("${project_root}/scripts/api/*.sh (at least one)")
fi

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "[chain-check] ticket-core-service project chain validation failed (strict)"
  echo "[chain-check] 프로젝트 코드/설정/스크립트 변경이 감지됨"
  echo "[chain-check] 아래 파일군을 함께 stage 해야 커밋 가능:"
  for path in "${missing[@]}"; do
    echo "  - $path"
  done
  echo
  echo "[chain-check] staged files:"
  echo "$staged_files" | sed 's/^/  - /'
  exit 1
fi

if [[ "$sidebar_missing" == "true" ]]; then
  echo "[chain-check] new project docs detected but sidebar is not updated (strict)"
  echo "[chain-check] stage this file and commit again:"
  echo "  - ${sidebar_file}"
  echo
  echo "[chain-check] new docs:"
  echo "$added_docs" | sed 's/^/  - /'
  exit 1
fi

if [[ "$has_api_script_change" == "true" ]]; then
  echo "[chain-check] running API script tests"
  bash skills/bin/run-ticket-core-api-script-tests.sh

  report_file="${project_root}/prj-docs/api-test/latest.md"
  if ! grep -Fxq "$report_file" <<< "$staged_files"; then
    echo "[chain-check] API script test report is not staged"
    echo "[chain-check] stage this file and commit again:"
    echo "  - $report_file"
    exit 1
  fi
  if ! git diff --quiet -- "$report_file"; then
    echo "[chain-check] API script test report was updated by test run"
    echo "[chain-check] re-stage this file and commit again:"
    echo "  - $report_file"
    exit 1
  fi
fi

echo "[chain-check] ticket-core-service project chain validation ok (strict)"
