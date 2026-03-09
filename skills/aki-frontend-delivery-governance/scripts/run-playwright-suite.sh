#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage:
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --list
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope <smoke|nav|queue|contract|auth|realtime|admin|all|@tag> [--history-file <path>] [--no-history] [-- <extra args>]

Examples:
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root workspace/apps/frontend/ticket-web-client --list
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root workspace/apps/frontend/ticket-web-client --scope smoke
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root workspace/apps/frontend/ticket-web-client --scope auth --history-file prj-docs/projects/ticket-web-client/testing/playwright-execution-history.md
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root workspace/apps/frontend/ticket-web-client --scope @critical -- --headed
USAGE
}

project_root=""
scope=""
list_only="false"
history_enabled="true"
history_file=""
extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --project-root)
      project_root="${2:-}"
      shift 2
      ;;
    --scope)
      scope="${2:-}"
      shift 2
      ;;
    --history-file)
      history_file="${2:-}"
      shift 2
      ;;
    --no-history)
      history_enabled="false"
      shift
      ;;
    --list)
      list_only="true"
      shift
      ;;
    --)
      shift
      extra_args=("$@")
      break
      ;;
    *)
      echo "error: unknown argument '$1'" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$project_root" ]]; then
  echo "error: --project-root is required" >&2
  usage
  exit 1
fi

if [[ "$project_root" == /* ]]; then
  project_abs="$project_root"
else
  project_abs="$repo_root/$project_root"
fi

if [[ ! -d "$project_abs" ]]; then
  echo "error: project root not found: $project_abs" >&2
  exit 1
fi
if [[ ! -f "$project_abs/package.json" ]]; then
  echo "error: package.json not found under project root: $project_abs" >&2
  exit 1
fi

if [[ "$list_only" == "true" ]]; then
  echo "[Playwright Scope List]"
  (
    cd "$project_abs"
    if npm run -s e2e:list >/dev/null 2>&1; then
      npm run -s e2e:list
    else
      echo "- e2e:list script not found. fallback: scan tests/e2e"
      if [[ -d "tests/e2e" ]]; then
        find tests/e2e -type f -name "*.spec.ts" | sort
      else
        echo "- tests/e2e directory not found"
      fi
    fi
  )
  exit 0
fi

if [[ -z "$scope" ]]; then
  echo "error: --scope is required for run mode" >&2
  usage
  exit 1
fi

cmd=()
case "$scope" in
  smoke)
    cmd=(npm run e2e:smoke --)
    ;;
  nav|navigation)
    cmd=(npm run e2e:nav --)
    ;;
  queue)
    cmd=(npm run e2e:queue --)
    ;;
  contract|contracts)
    cmd=(npm run e2e:contract --)
    ;;
  auth)
    cmd=(npm run e2e:auth --)
    ;;
  realtime)
    cmd=(npm run e2e:realtime --)
    ;;
  admin)
    cmd=(npm run e2e:admin --)
    ;;
  all)
    cmd=(npm run e2e:all --)
    ;;
  @*)
    cmd=(npx playwright test --grep "$scope")
    ;;
  *)
    echo "error: unsupported scope '$scope'" >&2
    echo "supported: smoke, nav, queue, contract, auth, realtime, admin, all, @tag" >&2
    exit 1
    ;;
esac

service_name="$(basename "$project_abs")"
run_id="$(date +%Y%m%d-%H%M%S)-$$"
out_root="$repo_root/.codex/tmp/frontend-playwright/$service_name"
out_dir="$out_root/$run_id"
mkdir -p "$out_dir"

summary_file="$out_dir/summary.txt"
log_file="$out_dir/run.log"
started_at="$(date '+%Y-%m-%d %H:%M:%S')"

{
  echo "service=$service_name"
  echo "project_root=$project_abs"
  echo "scope=$scope"
  echo "started_at=$started_at"
  echo "command=${cmd[*]} ${extra_args[*]}"
  echo "test_results_dir=$project_abs/test-results"
  echo "playwright_report_dir=$project_abs/playwright-report"
} > "$summary_file"

set +e
(
  cd "$project_abs"
  "${cmd[@]}" "${extra_args[@]}"
) 2>&1 | tee "$log_file"
exit_code=${PIPESTATUS[0]}
set -e

echo "exit_code=$exit_code" >> "$summary_file"
finished_at="$(date '+%Y-%m-%d %H:%M:%S')"
echo "finished_at=$finished_at" >> "$summary_file"

ln -sfn "$out_dir" "$out_root/latest"

if [[ "$history_enabled" == "true" ]]; then
  if [[ -z "$history_file" ]]; then
    history_abs="$repo_root/prj-docs/projects/$service_name/testing/playwright-execution-history.md"
  elif [[ "$history_file" == /* ]]; then
    history_abs="$history_file"
  else
    history_abs="$repo_root/$history_file"
  fi

  mkdir -p "$(dirname "$history_abs")"
  if [[ ! -f "$history_abs" ]]; then
    cat > "$history_abs" <<EOF
# Playwright Execution History ($service_name)

이 문서는 \`run-playwright-suite.sh\` 실행 결과를 누적 기록한다.

## Run Ledger
| Executed At | Scope | Result | Run ID | Summary | Log |
| --- | --- | --- | --- | --- | --- |
EOF
  fi

  summary_ref="$summary_file"
  log_ref="$log_file"
  if [[ "$summary_ref" == "$repo_root/"* ]]; then
    summary_ref="${summary_ref#$repo_root/}"
  fi
  if [[ "$log_ref" == "$repo_root/"* ]]; then
    log_ref="${log_ref#$repo_root/}"
  fi

  run_result="PASS"
  if [[ "$exit_code" -ne 0 ]]; then
    run_result="FAIL($exit_code)"
  fi

  printf '| %s | `%s` | `%s` | `%s` | `%s` | `%s` |\n' \
    "$finished_at" "$scope" "$run_result" "$run_id" "$summary_ref" "$log_ref" >> "$history_abs"
fi

echo
echo "[Playwright Run Result]"
echo "- scope: $scope"
echo "- exit_code: $exit_code"
echo "- summary: $summary_file"
echo "- log: $log_file"
echo "- test_results: $project_abs/test-results"
echo "- report: $project_abs/playwright-report/index.html"
echo "- latest: $out_root/latest"
if [[ "$history_enabled" == "true" ]]; then
  echo "- history: $history_abs"
fi

exit "$exit_code"
