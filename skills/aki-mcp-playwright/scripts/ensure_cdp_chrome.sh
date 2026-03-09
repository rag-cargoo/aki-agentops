#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ensure_cdp_chrome.sh [start_url]

Environment variables:
  CDP_PORT                Default: 9222
  CDP_ENDPOINT            Default: http://127.0.0.1:${CDP_PORT}
  MCP_BROWSER_BIN         Optional browser binary override
  MCP_CHROME_PROFILE_DIR  Default: /tmp/chrome-mcp-profile
  LOG_FILE                Default: /tmp/playwright_chrome.log
  WAIT_SECONDS            Default: 10
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

start_url="${1:-about:blank}"
cdp_port="${CDP_PORT:-9222}"
cdp_endpoint="${CDP_ENDPOINT:-http://127.0.0.1:${cdp_port}}"
profile_dir="${MCP_CHROME_PROFILE_DIR:-/tmp/chrome-mcp-profile}"
log_file="${LOG_FILE:-/tmp/playwright_chrome.log}"
wait_seconds="${WAIT_SECONDS:-10}"
preferred_browser="${MCP_BROWSER_BIN:-}"

probe_cdp() {
  curl -sS --max-time 2 "${cdp_endpoint}/json/version" >/dev/null 2>&1
}

resolve_browser() {
  if [[ -n "$preferred_browser" ]] && command -v "$preferred_browser" >/dev/null 2>&1; then
    echo "$preferred_browser"
    return 0
  fi
  local candidate=""
  for candidate in google-chrome chromium microsoft-edge-stable; do
    if command -v "$candidate" >/dev/null 2>&1; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

if probe_cdp; then
  echo "status=up"
  echo "cdp_endpoint=${cdp_endpoint}"
  echo "started=false"
  exit 0
fi

browser_cmd="$(resolve_browser || true)"
if [[ -z "$browser_cmd" ]]; then
  echo "status=down"
  echo "reason=no_browser_found"
  exit 1
fi

mkdir -p "$profile_dir"
setsid "$browser_cmd" \
  --remote-debugging-port="$cdp_port" \
  --user-data-dir="$profile_dir" \
  --no-first-run \
  --no-default-browser-check \
  "$start_url" >"$log_file" 2>&1 < /dev/null &

for ((i=0; i<wait_seconds; i++)); do
  if probe_cdp; then
    echo "status=up"
    echo "cdp_endpoint=${cdp_endpoint}"
    echo "started=true"
    echo "browser=${browser_cmd}"
    echo "log=${log_file}"
    exit 0
  fi
  sleep 1
done

echo "status=down"
echo "cdp_endpoint=${cdp_endpoint}"
echo "started=true"
echo "browser=${browser_cmd}"
echo "log=${log_file}"
exit 1

