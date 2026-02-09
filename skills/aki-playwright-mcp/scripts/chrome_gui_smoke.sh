#!/usr/bin/env bash
set -euo pipefail

URL="${1:-https://www.google.com}"
LOG_FILE="${LOG_FILE:-/tmp/aki-playwright-mcp-chrome-gui.log}"
PREFERRED_BROWSER="${MCP_BROWSER_BIN:-}"

if [ -n "${PREFERRED_BROWSER}" ] && command -v "${PREFERRED_BROWSER}" >/dev/null 2>&1; then
  BROWSER_CMD="${PREFERRED_BROWSER}"
elif command -v google-chrome >/dev/null 2>&1; then
  BROWSER_CMD="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER_CMD="chromium"
elif command -v chromium-browser >/dev/null 2>&1; then
  BROWSER_CMD="chromium-browser"
elif command -v microsoft-edge-stable >/dev/null 2>&1; then
  BROWSER_CMD="microsoft-edge-stable"
else
  echo "no_browser_found"
  echo "tip=set MCP_BROWSER_BIN to an existing browser binary"
  exit 1
fi

echo "browser=${BROWSER_CMD}"
echo "url=${URL}"
echo "log=${LOG_FILE}"

nohup "${BROWSER_CMD}" --new-window "${URL}" --no-first-run >"${LOG_FILE}" 2>&1 < /dev/null &
PID=$!

sleep 2
if ps -p "${PID}" >/dev/null 2>&1; then
  echo "launcher_pid_alive=${PID}"
  echo "result=gui_launch_requested"
  exit 0
fi

echo "result=launcher_exited_early"
echo "tip=check ${LOG_FILE}"
tail -n 40 "${LOG_FILE}" || true
exit 2
