#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

exec bash skills/workspace-governance/scripts/run-project-api-script-tests.sh "$@"
