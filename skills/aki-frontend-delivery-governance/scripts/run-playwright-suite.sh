#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage:
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --list
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope <smoke|nav|contract|realtime|all|@tag> [-- <extra args>]

Examples:
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root workspace/apps/frontend/ticket-web-client --list
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root workspace/apps/frontend/ticket-web-client --scope smoke
  ./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root workspace/apps/frontend/ticket-web-client --scope @critical -- --headed
USAGE
}

project_root=""
scope=""
list_only="false"
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
  contract|contracts)
    cmd=(npm run e2e:contract --)
    ;;
  realtime)
    cmd=(npm run e2e:realtime --)
    ;;
  all)
    cmd=(npm run e2e:all --)
    ;;
  @*)
    cmd=(npx playwright test --grep "$scope")
    ;;
  *)
    echo "error: unsupported scope '$scope'" >&2
    echo "supported: smoke, nav, contract, realtime, all, @tag" >&2
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

{
  echo "service=$service_name"
  echo "project_root=$project_abs"
  echo "scope=$scope"
  echo "started_at=$(date '+%Y-%m-%d %H:%M:%S')"
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
echo "finished_at=$(date '+%Y-%m-%d %H:%M:%S')" >> "$summary_file"

ln -sfn "$out_dir" "$out_root/latest"

echo
echo "[Playwright Run Result]"
echo "- scope: $scope"
echo "- exit_code: $exit_code"
echo "- summary: $summary_file"
echo "- log: $log_file"
echo "- test_results: $project_abs/test-results"
echo "- report: $project_abs/playwright-report/index.html"
echo "- latest: $out_root/latest"

exit "$exit_code"
