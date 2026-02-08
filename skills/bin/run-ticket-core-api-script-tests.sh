#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

project_root="workspace/apps/backend/ticket-core-service"
scripts_root="${project_root}/scripts/api"
report_path="${project_root}/prj-docs/api-test/latest.md"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

health_url="${TICKETRUSH_HEALTH_URL:-http://127.0.0.1:8080/api/concerts}"

declare -a scripts_to_run=()

if [[ "$#" -gt 0 ]]; then
  for script_path in "$@"; do
    script_name="$(basename "$script_path")"
    if [[ "$script_path" != ${scripts_root}/* ]]; then
      continue
    fi
    if [[ ! "$script_name" =~ ^v[0-9].*\.sh$ ]]; then
      continue
    fi
    if [[ ! -f "$script_path" ]]; then
      continue
    fi
    scripts_to_run+=("$script_path")
  done
else
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    scripts_to_run+=("${scripts_root}/${line}")
  done <<'EOF'
v1-optimistic.sh
v2-pessimistic.sh
v3-distributed.sh
v4-polling-test.sh
v5-waiting-queue.sh
v6-throttling-test.sh
v7-sse-rank-push.sh
EOF
fi

if [[ "${#scripts_to_run[@]}" -eq 0 ]]; then
  echo "[script-test] no script selected, skipping"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "[script-test] curl not found"
  exit 1
fi

health_code="$(curl -sS -o /dev/null -w "%{http_code}" --max-time 3 "$health_url" || true)"
if [[ ! "$health_code" =~ ^2[0-9][0-9]$ ]]; then
  mkdir -p "$(dirname "$report_path")"
  cat >"$report_path" <<EOF
# API Script Test Report

- Result: FAIL
- Reason: Backend health check failed
- Health URL: \`${health_url}\`
- Health Status Code: ${health_code:-N/A}

## Troubleshooting

1. 백엔드 앱을 실행 후 재시도하세요. 예: \`cd ${project_root} && ./gradlew bootRun\`
2. 인프라(예: Redis, PostgreSQL) 컨테이너가 필요한 경우 먼저 기동하세요.
EOF
  echo "[script-test] backend health check failed: ${health_url} (status: ${health_code:-N/A})"
  exit 1
fi

mkdir -p "$(dirname "$report_path")"

pass_count=0
fail_count=0
table_rows=""
failure_blocks=""

for script_path in "${scripts_to_run[@]}"; do
  script_name="$(basename "$script_path")"
  log_path="${tmp_root}/${script_name%.sh}.log"

  set +e
  bash "$script_path" >"$log_path" 2>&1
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    result="PASS"
    pass_count=$((pass_count + 1))
  else
    result="FAIL"
    fail_count=$((fail_count + 1))
    failure_blocks+=$'\n'
    failure_blocks+="### ${script_name}"$'\n\n'
    failure_blocks+='```text'$'\n'
    failure_blocks+="$(tail -n 30 "$log_path")"$'\n'
    failure_blocks+='```'$'\n'
  fi

  table_rows+="| \`${script_name}\` | ${result} | ${rc} |"$'\n'
done

overall="PASS"
if [[ "$fail_count" -gt 0 ]]; then
  overall="FAIL"
fi

cat >"$report_path" <<EOF
# API Script Test Report

- Result: ${overall}
- Health URL: \`${health_url}\`
- Passed: ${pass_count}
- Failed: ${fail_count}

## Execution Matrix

| Script | Result | Exit Code |
| --- | --- | --- |
${table_rows}
EOF

if [[ "$fail_count" -gt 0 ]]; then
  cat >>"$report_path" <<EOF

## Troubleshooting Notes
${failure_blocks}
EOF
fi

if [[ "$fail_count" -gt 0 ]]; then
  echo "[script-test] failed (${fail_count})"
  exit 1
fi

echo "[script-test] all passed (${pass_count})"
