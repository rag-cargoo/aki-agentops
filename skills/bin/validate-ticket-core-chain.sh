#!/usr/bin/env bash
set -euo pipefail

echo "[chain-check] deprecated entrypoint: forwarding to validate-precommit-chain.sh"
exec bash skills/bin/validate-precommit-chain.sh "$@"
