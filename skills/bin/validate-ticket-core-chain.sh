#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

staged_files="$(git diff --cached --name-only || true)"
if [[ -z "$staged_files" ]]; then
  exit 0
fi

project_root="workspace/apps/backend/ticket-core-service"

if ! grep -q "^${project_root}/" <<< "$staged_files"; then
  exit 0
fi

api_change_patterns=(
  "^${project_root}/src/main/java/com/ticketrush/api/.+\\.java$"
  "^${project_root}/src/main/java/com/ticketrush/domain/waitingqueue/.+\\.java$"
  "^${project_root}/src/main/java/com/ticketrush/global/scheduler/.+\\.java$"
  "^${project_root}/src/main/java/com/ticketrush/global/sse/.+\\.java$"
  "^${project_root}/src/main/java/com/ticketrush/global/interceptor/WaitingQueueInterceptor\\.java$"
  "^${project_root}/src/main/java/com/ticketrush/global/config/WaitingQueueProperties\\.java$"
  "^${project_root}/src/main/resources/application(-local|-docker)?\\.yml$"
)

needs_chain="false"
for pattern in "${api_change_patterns[@]}"; do
  if grep -Eq "$pattern" <<< "$staged_files"; then
    needs_chain="true"
    break
  fi
done

if grep -Eq "^${project_root}/scripts/api/.+\\.sh$" <<< "$staged_files"; then
  needs_chain="true"
fi

if [[ "$needs_chain" != "true" ]]; then
  exit 0
fi

missing=()

if ! grep -Fxq "${project_root}/prj-docs/task.md" <<< "$staged_files"; then
  missing+=("${project_root}/prj-docs/task.md")
fi
if ! grep -Eq "^${project_root}/prj-docs/api-specs/.+\\.md$" <<< "$staged_files"; then
  missing+=("${project_root}/prj-docs/api-specs/*.md (at least one)")
fi
if ! grep -Eq "^${project_root}/scripts/http/.+\\.http$" <<< "$staged_files"; then
  missing+=("${project_root}/scripts/http/*.http (at least one)")
fi
if ! grep -Eq "^${project_root}/scripts/api/.+\\.sh$" <<< "$staged_files"; then
  missing+=("${project_root}/scripts/api/*.sh (at least one)")
fi

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "[chain-check] ticket-core-service API chain validation failed"
  echo "[chain-check] API/queue/SSE/config 변경이 감지됨"
  echo "[chain-check] 아래 파일군을 함께 stage 해야 커밋 가능:"
  for path in "${missing[@]}"; do
    echo "  - $path"
  done
  echo
  echo "[chain-check] staged files:"
  echo "$staged_files" | sed 's/^/  - /'
  exit 1
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

echo "[chain-check] ticket-core-service API chain validation ok"
