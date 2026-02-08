#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../.." && pwd)"
fi

manifest_file="$repo_root/mcp/manifest/mcp-manifest.sh"
policy="${MCP_INSTALL_POLICY:-forbid}"
write_handoff="${MCP_WRITE_HANDOFF:-yes}"
target_name=""

usage() {
  cat <<'EOF'
Usage: mcp_sync.sh [--manifest <path>] [--name <mcp-name>] [--policy forbid|prompt|allow] [--write-handoff yes|no]

Environment:
  MCP_INSTALL_POLICY   forbid|prompt|allow (default: forbid)
  MCP_WRITE_HANDOFF    yes|no (default: yes)
EOF
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

to_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest)
      manifest_file="$2"
      shift 2
      ;;
    --name)
      target_name="$2"
      shift 2
      ;;
    --policy)
      policy="$2"
      shift 2
      ;;
    --write-handoff)
      write_handoff="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

policy="$(to_lower "$(trim "$policy")")"
write_handoff="$(to_lower "$(trim "$write_handoff")")"

if [[ "$policy" != "forbid" && "$policy" != "prompt" && "$policy" != "allow" ]]; then
  echo "error: invalid policy: $policy (use forbid|prompt|allow)" >&2
  exit 2
fi
if [[ "$write_handoff" != "yes" && "$write_handoff" != "no" ]]; then
  echo "error: invalid --write-handoff: $write_handoff (use yes|no)" >&2
  exit 2
fi

if [[ "$manifest_file" != /* ]]; then
  manifest_file="$repo_root/$manifest_file"
fi
if [[ ! -f "$manifest_file" ]]; then
  echo "error: manifest not found: $manifest_file" >&2
  exit 2
fi

declare -a names=()
declare -a enableds=()
declare -a checks=()
declare -a installs=()
declare -a restarts=()
declare -a notes=()

mcp_register() {
  names+=("$1")
  enableds+=("$2")
  checks+=("$3")
  installs+=("$4")
  restarts+=("$5")
  notes+=("$6")
}

# shellcheck source=/dev/null
source "$manifest_file"

if [[ "${#names[@]}" -eq 0 ]]; then
  echo "error: no MCP entries in manifest: $manifest_file" >&2
  exit 2
fi

ask_user_install() {
  local name="$1"
  if [[ ! -t 0 ]]; then
    return 2
  fi
  local answer
  read -r -p "[mcp-sync] install missing entry '$name'? [y/N] " answer
  answer="$(to_lower "$(trim "$answer")")"
  [[ "$answer" == "y" || "$answer" == "yes" ]]
}

run_check() {
  local cmd="$1"
  bash -lc "$cmd" >/dev/null 2>&1
}

run_install() {
  local cmd="$1"
  local log_file="$2"
  bash -lc "$cmd" >"$log_file" 2>&1
}

declare -a present_entries=()
declare -a installed_entries=()
declare -a blocked_entries=()
declare -a failed_entries=()
declare -a no_recipe_entries=()
declare -a restart_entries=()

processed=0
for i in "${!names[@]}"; do
  name="$(trim "${names[$i]}")"
  enabled="$(to_lower "$(trim "${enableds[$i]}")")"
  check_cmd="$(trim "${checks[$i]}")"
  install_cmd="$(trim "${installs[$i]}")"
  restart_required="$(to_lower "$(trim "${restarts[$i]}")")"
  note="$(trim "${notes[$i]}")"

  [[ -z "$name" ]] && continue
  if [[ -n "$target_name" && "$name" != "$target_name" ]]; then
    continue
  fi
  if [[ "$enabled" != "yes" ]]; then
    echo "[mcp-sync] skip name=$name reason=disabled"
    continue
  fi
  processed=$((processed + 1))

  if [[ -z "$check_cmd" ]]; then
    echo "[mcp-sync] name=$name status=invalid reason=empty_check_cmd"
    failed_entries+=("$name")
    continue
  fi

  if run_check "$check_cmd"; then
    echo "[mcp-sync] name=$name status=present"
    present_entries+=("$name")
    continue
  fi

  echo "[mcp-sync] name=$name status=missing note=\"$note\""
  if [[ -z "$install_cmd" || "$install_cmd" == "-" ]]; then
    echo "[mcp-sync] name=$name action=no_install_recipe"
    no_recipe_entries+=("$name")
    continue
  fi

  should_install="no"
  case "$policy" in
    allow)
      should_install="yes"
      ;;
    prompt)
      if ask_user_install "$name"; then
        should_install="yes"
      else
        if [[ -t 0 ]]; then
          echo "[mcp-sync] name=$name action=blocked_by_user"
        else
          echo "[mcp-sync] name=$name action=blocked_prompt_non_tty"
        fi
        blocked_entries+=("$name")
      fi
      ;;
    forbid)
      echo "[mcp-sync] name=$name action=blocked_by_policy"
      blocked_entries+=("$name")
      ;;
  esac

  if [[ "$should_install" != "yes" ]]; then
    continue
  fi

  safe_name="$(printf '%s' "$name" | tr -c 'a-zA-Z0-9_.-' '_')"
  install_log="/tmp/mcp-sync-${safe_name}.log"
  echo "[mcp-sync] name=$name action=install start"
  if run_install "$install_cmd" "$install_log"; then
    if run_check "$check_cmd"; then
      echo "[mcp-sync] name=$name action=install success"
      installed_entries+=("$name")
      if [[ "$restart_required" == "yes" ]]; then
        restart_entries+=("$name")
      fi
    else
      echo "[mcp-sync] name=$name action=install failed reason=check_still_missing"
      echo "[mcp-sync] name=$name log=$install_log"
      failed_entries+=("$name")
    fi
  else
    echo "[mcp-sync] name=$name action=install failed reason=command_error"
    echo "[mcp-sync] name=$name log=$install_log"
    tail -n 20 "$install_log" || true
    failed_entries+=("$name")
  fi
done

if [[ "$processed" -eq 0 ]]; then
  if [[ -n "$target_name" ]]; then
    echo "[mcp-sync] no enabled entry matched: $target_name"
  else
    echo "[mcp-sync] no enabled entries to process"
  fi
  exit 0
fi

present_count="${#present_entries[@]}"
installed_count="${#installed_entries[@]}"
blocked_count="${#blocked_entries[@]}"
failed_count="${#failed_entries[@]}"
no_recipe_count="${#no_recipe_entries[@]}"
restart_count="${#restart_entries[@]}"

echo "[mcp-sync] summary present=$present_count installed=$installed_count blocked=$blocked_count failed=$failed_count no_recipe=$no_recipe_count restart_required=$restart_count"
if [[ "$restart_count" -gt 0 ]]; then
  echo "[mcp-sync] restart_targets=$(IFS=,; echo "${restart_entries[*]}")"
fi

if [[ "$restart_count" -gt 0 && "$installed_count" -gt 0 && "$write_handoff" == "yes" ]]; then
  handoff_script="$repo_root/mcp/scripts/write_session_handoff.sh"
  if [[ -x "$handoff_script" ]]; then
    installed_csv="$(IFS=', '; echo "${installed_entries[*]}")"
    restart_csv="$(IFS=', '; echo "${restart_entries[*]}")"
    "$handoff_script" \
      --reason "MCP install/update가 반영되어 새 세션 재시작이 필요함" \
      --done "mcp_sync policy=${policy}" \
      --done "installed: ${installed_csv}" \
      --next "현재 세션을 종료하고 새 세션을 시작" \
      --next "첫 메시지로 AGENTS.md 시작 문구를 사용한 뒤 SESSION_HANDOFF.md를 우선 반영" \
      --ref "${manifest_file#$repo_root/}" \
      --ref "mcp/runtime/SESSION_HANDOFF.md" \
      --restart-required "yes" >/dev/null
    echo "[mcp-sync] handoff_written=mcp/runtime/SESSION_HANDOFF.md restart_targets=${restart_csv}"
  else
    echo "[mcp-sync] handoff_script_missing=$handoff_script"
  fi
fi

if [[ "$failed_count" -gt 0 ]]; then
  exit 20
fi
if [[ "$blocked_count" -gt 0 || "$no_recipe_count" -gt 0 ]]; then
  exit 10
fi
exit 0
