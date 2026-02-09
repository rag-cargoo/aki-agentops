#!/usr/bin/env bash
set -euo pipefail

INSTALL_POLICY="${MCP_INSTALL_POLICY:-forbid}"
PREFERRED_BROWSER="${MCP_BROWSER_BIN:-}"

echo "== Playwright MCP Environment Diagnose =="
echo "timestamp: $(date -Iseconds)"
echo "kernel: $(uname -srmo 2>/dev/null || uname -a)"
echo "install_policy=${INSTALL_POLICY}"
echo "preferred_browser=${PREFERRED_BROWSER:-unset}"

if [ "${INSTALL_POLICY}" != "forbid" ] && [ "${INSTALL_POLICY}" != "allow" ]; then
  echo "invalid_install_policy=${INSTALL_POLICY}"
  echo "tip=set MCP_INSTALL_POLICY=forbid or allow"
  exit 2
fi

if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
  echo "wsl: yes"
else
  echo "wsl: no"
fi

echo "DISPLAY=${DISPLAY:-}"
echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-}"
echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-}"

for bin in google-chrome chromium chromium-browser microsoft-edge-stable; do
  if command -v "${bin}" >/dev/null 2>&1; then
    printf "bin:%s=%s\n" "${bin}" "$(command -v "${bin}")"
  fi
done

if [ -n "${PREFERRED_BROWSER}" ] && command -v "${PREFERRED_BROWSER}" >/dev/null 2>&1; then
  SELECTED_BROWSER="${PREFERRED_BROWSER}"
elif command -v google-chrome >/dev/null 2>&1; then
  SELECTED_BROWSER="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
  SELECTED_BROWSER="chromium"
elif command -v chromium-browser >/dev/null 2>&1; then
  SELECTED_BROWSER="chromium-browser"
elif command -v microsoft-edge-stable >/dev/null 2>&1; then
  SELECTED_BROWSER="microsoft-edge-stable"
else
  SELECTED_BROWSER=""
fi

if [ -n "${SELECTED_BROWSER}" ]; then
  echo "selected_browser=${SELECTED_BROWSER}"
  echo "selected_browser_version: $("${SELECTED_BROWSER}" --version 2>/dev/null || true)"
else
  echo "selected_browser=none"
  if [ "${INSTALL_POLICY}" = "forbid" ]; then
    echo "action=install_blocked_by_policy"
    echo "next=provide_existing_browser_or_set_MCP_BROWSER_BIN"
  else
    echo "action=install_allowed_if_user_requested"
    echo "next=run_install_recipe_from_setup_doc"
  fi
fi

if [ -d /mnt/wslg ]; then
  echo "wslg_mount: present"
else
  echo "wslg_mount: missing"
fi

echo "== Diagnose Completed =="
