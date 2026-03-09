#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  run-project-api-script-tests.sh <project-root> [script...]

Examples:
  run-project-api-script-tests.sh <project-root>
  run-project-api-script-tests.sh <project-root> v7-sse-rank-push.sh
EOF
}

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

project_root="${1:-}"
if [[ -z "$project_root" ]]; then
  usage
  exit 1
fi
shift || true

project_root="${project_root%/}"
runner_path="${project_root}/scripts/api/run-api-script-tests.sh"
if [[ ! -f "$runner_path" ]]; then
  echo "[script-test] runner not found: $runner_path"
  exit 1
fi

bash "$runner_path" "$@"
