#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

exec bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh "$@"
