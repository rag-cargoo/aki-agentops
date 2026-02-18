#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  preflight_callback_health.sh <callback-url> [health-url]

Examples:
  preflight_callback_health.sh "http://localhost:8080/login/oauth2/code/kakao"
  preflight_callback_health.sh "http://localhost:8080/login/oauth2/code/kakao" "http://127.0.0.1:8080/api/concerts"
EOF
}

callback_url="${1:-}"
health_url="${2:-${PLAYWRIGHT_AUTH_HEALTH_URL:-http://127.0.0.1:8080/api/concerts}}"

if [[ -z "$callback_url" ]]; then
  usage
  exit 2
fi

readarray -t parsed < <(python3 - "$callback_url" <<'PY'
import sys
from urllib.parse import urlparse

u = urlparse(sys.argv[1])
host = u.hostname or ""
port = u.port
scheme = u.scheme
if not port:
    if scheme == "https":
        port = 443
    elif scheme == "http":
        port = 80
    else:
        port = 0
print(host)
print(port)
print(scheme)
PY
)

callback_host="${parsed[0]}"
callback_port="${parsed[1]}"
callback_scheme="${parsed[2]}"

if [[ -z "$callback_host" || -z "$callback_scheme" || "$callback_port" == "0" ]]; then
  echo "[preflight] invalid callback url: $callback_url"
  exit 1
fi

echo "[preflight] callback: ${callback_scheme}://${callback_host}:${callback_port}"

if [[ "$callback_host" != "localhost" && "$callback_host" != "127.0.0.1" ]]; then
  echo "[preflight] callback host is non-local (${callback_host}), port liveness check skipped"
  echo "[preflight] PASS"
  exit 0
fi

if ! ss -ltn | rg -q "[:.]${callback_port}\\s"; then
  echo "[preflight] FAIL: local callback port ${callback_port} is not listening"
  echo "[preflight] action: start backend before opening auth page"
  exit 1
fi

status="$(curl -sS -o /tmp/playwright_callback_health.out -w '%{http_code}' --max-time 3 "$health_url" || true)"
if [[ ! "$status" =~ ^2[0-9][0-9]$ ]]; then
  echo "[preflight] FAIL: health check returned ${status:-N/A} (${health_url})"
  echo "[preflight] action: recover backend and retry"
  exit 1
fi

echo "[preflight] health ok: ${health_url} (${status})"
echo "[preflight] PASS"
