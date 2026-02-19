#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: probe_figma_mcp.sh [--server figma|figma-desktop|all] [--quiet]

Options:
  --server  Target endpoint (default: all)
  --quiet   Suppress human-readable logs (key=value output only)
USAGE
}

server_target="all"
quiet_mode="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server)
      server_target="$2"
      shift 2
      ;;
    --quiet)
      quiet_mode="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[figma-probe] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

case "$server_target" in
  figma|figma-desktop|all) ;;
  *)
    echo "[figma-probe] invalid --server: $server_target" >&2
    exit 1
    ;;
esac

figma_endpoint="${FIGMA_MCP_URL:-https://mcp.figma.com/mcp}"
figma_desktop_endpoint="${FIGMA_DESKTOP_MCP_URL:-http://127.0.0.1:3845/mcp}"

probe_endpoint() {
  local url="$1"
  local code=""
  code="$(curl -sS -o /dev/null -m 3 -w '%{http_code}' "$url" 2>/dev/null || true)"
  if [[ -z "$code" ]]; then
    code="000"
  fi
  if [[ "$code" == "000" ]]; then
    echo "UNREACHABLE|$code"
  else
    echo "REACHABLE|$code"
  fi
}

figma_status="SKIPPED"
figma_code="-"
if [[ "$server_target" == "all" || "$server_target" == "figma" ]]; then
  figma_result="$(probe_endpoint "$figma_endpoint")"
  figma_status="${figma_result%%|*}"
  figma_code="${figma_result##*|}"
fi

figma_desktop_status="SKIPPED"
figma_desktop_code="-"
if [[ "$server_target" == "all" || "$server_target" == "figma-desktop" ]]; then
  figma_desktop_result="$(probe_endpoint "$figma_desktop_endpoint")"
  figma_desktop_status="${figma_desktop_result%%|*}"
  figma_desktop_code="${figma_desktop_result##*|}"
fi

overall_status="OK"
if [[ "$server_target" == "figma" && "$figma_status" != "REACHABLE" ]]; then
  overall_status="WARN"
elif [[ "$server_target" == "figma-desktop" && "$figma_desktop_status" != "REACHABLE" ]]; then
  overall_status="WARN"
elif [[ "$server_target" == "all" ]]; then
  if [[ "$figma_status" != "REACHABLE" || "$figma_desktop_status" != "REACHABLE" ]]; then
    overall_status="WARN"
  fi
fi

action="none"
if [[ "$overall_status" != "OK" ]]; then
  action="open_skills/aki-mcp-figma/references/troubleshooting.md"
fi

if [[ "$quiet_mode" != "true" ]]; then
  echo "[figma-probe] target=$server_target"
  if [[ "$figma_status" != "SKIPPED" ]]; then
    echo "[figma-probe] figma status=$figma_status http_code=$figma_code endpoint=$figma_endpoint"
  fi
  if [[ "$figma_desktop_status" != "SKIPPED" ]]; then
    echo "[figma-probe] figma-desktop status=$figma_desktop_status http_code=$figma_desktop_code endpoint=$figma_desktop_endpoint"
  fi
  echo "[figma-probe] overall=$overall_status"
  if [[ "$action" != "none" ]]; then
    echo "[figma-probe] action=$action"
  fi
fi

echo "FIGMA_PROBE_STATUS=$overall_status"
echo "FIGMA_PROBE_TARGET=$server_target"
echo "FIGMA_MCP_ENDPOINT=$figma_endpoint"
echo "FIGMA_MCP_STATUS=$figma_status"
echo "FIGMA_MCP_HTTP_CODE=$figma_code"
echo "FIGMA_DESKTOP_MCP_ENDPOINT=$figma_desktop_endpoint"
echo "FIGMA_DESKTOP_MCP_STATUS=$figma_desktop_status"
echo "FIGMA_DESKTOP_MCP_HTTP_CODE=$figma_desktop_code"
echo "ACTION=$action"
