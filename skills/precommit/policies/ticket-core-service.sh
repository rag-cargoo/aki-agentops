#!/usr/bin/env bash

POLICY_ID="ticket-core-service"
POLICY_ROOTS=(
  "workspace/apps/backend/ticket-core-service"
)

policy_validate() {
  local mode="$1"
  local staged_files="$2"

  local project_root="workspace/apps/backend/ticket-core-service"
  local sidebar_file="sidebar-manifest.md"

  local generated_artifacts=()
  local file_path
  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    if [[ "$file_path" == "${project_root}/build/"* ]] || [[ "$file_path" == "${project_root}/.gradle/"* ]]; then
      generated_artifacts+=("$file_path")
    fi
  done <<< "$staged_files"

  if [[ "${#generated_artifacts[@]}" -gt 0 ]]; then
    if [[ "$mode" == "strict" ]]; then
      echo "[chain-check][${POLICY_ID}] strict validation failed: generated artifacts are staged"
      echo "[chain-check][${POLICY_ID}] unstage build outputs before commit:"
      local artifact
      for artifact in "${generated_artifacts[@]}"; do
        echo "  - $artifact"
      done
      return 1
    fi
    echo "[chain-check][${POLICY_ID}] quick mode warning: generated artifacts are staged"
  fi

  local project_change_patterns=(
    "^${project_root}/src/main/java/.+\\.java$"
    "^${project_root}/src/main/resources/.+\\.ya?ml$"
    "^${project_root}/scripts/api/.+\\.sh$"
  )

  local needs_chain="false"
  local pattern
  for pattern in "${project_change_patterns[@]}"; do
    if grep -Eq "$pattern" <<< "$staged_files"; then
      needs_chain="true"
      break
    fi
  done

  if [[ "$needs_chain" != "true" ]]; then
    if [[ "$mode" == "strict" ]]; then
      echo "[chain-check][${POLICY_ID}] strict mode: chain trigger not detected, skip"
    fi
    return 0
  fi

  local added_docs
  added_docs="$(git diff --cached --name-only --diff-filter=A | grep -E "^${project_root}/prj-docs/.+\\.md$" || true)"
  local sidebar_missing="false"
  if [[ -n "$added_docs" ]] && ! grep -Fxq "$sidebar_file" <<< "$staged_files"; then
    sidebar_missing="true"
  fi

  local has_api_script_change="false"
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

  if [[ "$has_api_script_change" == "true" && "$mode" != "strict" ]]; then
    echo "[chain-check][${POLICY_ID}] quick mode: API script execution test skipped"
    echo "[chain-check][${POLICY_ID}] hint: run strict before milestone commit"
    echo "  - CHAIN_VALIDATION_MODE=strict git commit ..."
  fi

  if [[ "$mode" != "strict" ]]; then
    local quick_hints=()
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
      echo "[chain-check][${POLICY_ID}] quick mode hint: strict mode will require:"
      local hint
      for hint in "${quick_hints[@]}"; do
        echo "  - $hint"
      done
    fi
    if [[ "$sidebar_missing" == "true" ]]; then
      echo "[chain-check][${POLICY_ID}] quick mode hint: update sidebar before strict commit"
      echo "  - ${sidebar_file}"
    fi

    echo "[chain-check][${POLICY_ID}] validation ok (quick)"
    return 0
  fi

  local missing=()
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
    echo "[chain-check][${POLICY_ID}] strict validation failed"
    echo "[chain-check][${POLICY_ID}] 프로젝트 코드/설정/스크립트 변경이 감지됨"
    echo "[chain-check][${POLICY_ID}] 아래 파일군을 함께 stage 해야 커밋 가능:"
    local miss
    for miss in "${missing[@]}"; do
      echo "  - $miss"
    done
    echo
    echo "[chain-check][${POLICY_ID}] staged files:"
    echo "$staged_files" | sed 's/^/  - /'
    return 1
  fi

  if [[ "$sidebar_missing" == "true" ]]; then
    echo "[chain-check][${POLICY_ID}] new project docs detected but sidebar is not updated (strict)"
    echo "[chain-check][${POLICY_ID}] stage this file and commit again:"
    echo "  - ${sidebar_file}"
    echo
    echo "[chain-check][${POLICY_ID}] new docs:"
    echo "$added_docs" | sed 's/^/  - /'
    return 1
  fi

  if [[ "$has_api_script_change" == "true" ]]; then
    echo "[chain-check][${POLICY_ID}] running API script tests"
    bash skills/bin/run-ticket-core-api-script-tests.sh

    local report_file="${project_root}/prj-docs/api-test/latest.md"
    if ! grep -Fxq "$report_file" <<< "$staged_files"; then
      echo "[chain-check][${POLICY_ID}] API script test report is not staged"
      echo "[chain-check][${POLICY_ID}] stage this file and commit again:"
      echo "  - $report_file"
      return 1
    fi
    if ! git diff --quiet -- "$report_file"; then
      echo "[chain-check][${POLICY_ID}] API script test report was updated by test run"
      echo "[chain-check][${POLICY_ID}] re-stage this file and commit again:"
      echo "  - $report_file"
      return 1
    fi
  fi

  echo "[chain-check][${POLICY_ID}] validation ok (strict)"
}
