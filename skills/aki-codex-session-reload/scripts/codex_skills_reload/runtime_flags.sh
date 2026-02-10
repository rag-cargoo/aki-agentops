#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  runtime_flags.sh sync [--quiet]
  runtime_flags.sh status
  runtime_flags.sh alerts
  runtime_flags.sh paths

Commands:
  sync    Refresh .codex/state/runtime_flags.yaml and .codex/runtime/current_status.txt
  status  Refresh runtime status and print fixed-width table
  alerts  Refresh runtime status and print alerts section only
  paths   Print managed runtime file paths
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi

runtime_dir="$repo_root/.codex/runtime"
state_dir="$repo_root/.codex/state"
flags_file="$state_dir/runtime_flags.yaml"
status_file="$runtime_dir/current_status.txt"
workflow_mark_file="$state_dir/workflow_marks.tsv"
workflow_mark_file_label=".codex/state/workflow_marks.tsv"
project_snapshot="$runtime_dir/codex_project_reload.md"
handoff_file="$repo_root/mcp/runtime/SESSION_HANDOFF.md"
mode_file="$runtime_dir/precommit_mode"
validate_env_entry="$script_dir/validate_env.sh"
codex_home="${CODEX_HOME:-$HOME/.codex}"
codex_config_file="$codex_home/config.toml"
github_toolsets_default="${GITHUB_MCP_DEFAULT_TOOLSETS:-context,repos,issues,projects,pull_requests,labels}"
declare -a managed_skill_names=()
declare -a delegated_skill_names=()
declare -a mcp_server_names=()
declare -A mcp_server_runtime=()
declare -A mcp_server_status=()
declare -A mcp_server_detail=()
declare -a workflow_names=()
declare -A workflow_ready=()
declare -A workflow_last=()
declare -A workflow_detail=()
declare -A workflow_mark_status=()
declare -A workflow_mark_updated=()
declare -A workflow_mark_source=()
declare -A workflow_mark_detail=()
declare -a alert_entries=()

extract_kv() {
  local key="$1"
  local payload="$2"
  while IFS= read -r line; do
    if [[ "$line" == "$key="* ]]; then
      echo "${line#*=}"
      return 0
    fi
  done <<< "$payload"
  return 1
}

get_mcp_section_value() {
  local server_name="$1"
  local key_name="$2"
  if [[ ! -f "$codex_config_file" ]]; then
    return 0
  fi
  awk -v section="[mcp_servers.${server_name}]" -v key="${key_name}" '
    $0 == section { in_section=1; next }
    in_section && /^\[/ { exit }
    in_section && $1 == key {
      line=$0
      sub(/^[^=]+=[[:space:]]*/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      print line
      exit
    }
  ' "$codex_config_file"
}

extract_first_docker_image() {
  local args_value="$1"
  printf '%s\n' "$args_value" \
    | grep -oE '[A-Za-z0-9._-]+/[A-Za-z0-9._/-]+' \
    | head -n 1 || true
}

strip_wrapped_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  echo "$value"
}

add_alert() {
  local item="$1"
  local value="$2"
  local status="$3"
  local reason="$4"
  alert_entries+=("${item}|${value}|${status}|${reason}")
}

join_csv() {
  if [[ "$#" -eq 0 ]]; then
    echo "none"
    return
  fi
  local joined=""
  local item=""
  for item in "$@"; do
    if [[ -z "$joined" ]]; then
      joined="$item"
    else
      joined="${joined},${item}"
    fi
  done
  echo "$joined"
}

format_missing_detail() {
  if [[ "$#" -eq 0 ]]; then
    echo "none"
    return
  fi
  echo "missing:$(join_csv "$@")"
}

set_workflow_state() {
  local workflow_name="$1"
  local ready_state="$2"
  local last_state="$3"
  local detail_state="$4"
  local marked_status=""
  local marked_updated=""
  local marked_source=""
  local marked_detail=""
  local mark_meta=""
  if [[ -n "${workflow_mark_status[$workflow_name]:-}" ]]; then
    marked_status="${workflow_mark_status[$workflow_name]}"
    marked_updated="${workflow_mark_updated[$workflow_name]:-unknown}"
    marked_source="${workflow_mark_source[$workflow_name]:-manual}"
    marked_detail="${workflow_mark_detail[$workflow_name]:-none}"
    last_state="$marked_status"
    mark_meta="mark:${marked_source}@${marked_updated}"
    if [[ -n "$marked_detail" && "$marked_detail" != "none" ]]; then
      mark_meta="${mark_meta};${marked_detail}"
    fi
    if [[ -z "$detail_state" || "$detail_state" == "none" ]]; then
      detail_state="$mark_meta"
    else
      detail_state="${detail_state};${mark_meta}"
    fi
  fi
  workflow_names+=("$workflow_name")
  workflow_ready["$workflow_name"]="$ready_state"
  workflow_last["$workflow_name"]="$last_state"
  workflow_detail["$workflow_name"]="$detail_state"
}

map_hook_status() {
  local hook_status="${1:-}"
  case "$hook_status" in
    passed) echo "PASS" ;;
    failed) echo "FAIL" ;;
    skipped) echo "SKIP" ;;
    *) echo "UNVERIFIED" ;;
  esac
}

load_workflow_marks() {
  workflow_mark_status=()
  workflow_mark_updated=()
  workflow_mark_source=()
  workflow_mark_detail=()
  workflow_marks_count="0"

  if [[ ! -f "$workflow_mark_file" ]]; then
    return
  fi

  while IFS=$'\t' read -r workflow_name mark_status mark_updated mark_source mark_detail || [[ -n "$workflow_name" ]]; do
    [[ -z "$workflow_name" ]] && continue
    [[ "$workflow_name" == \#* ]] && continue
    [[ -z "$mark_status" ]] && continue
    workflow_mark_status["$workflow_name"]="$mark_status"
    workflow_mark_updated["$workflow_name"]="${mark_updated:-unknown}"
    workflow_mark_source["$workflow_name"]="${mark_source:-manual}"
    workflow_mark_detail["$workflow_name"]="${mark_detail:-none}"
  done < "$workflow_mark_file"

  workflow_marks_count="${#workflow_mark_status[@]}"
}

build_alerts() {
  alert_entries=()

  if [[ "$active_project_state" != "SELECTED" ]]; then
    add_alert "active_project" "$active_project_label" "WARN" "active_project_unselected"
  fi
  if [[ "$github_mcp_state" != "CONFIGURED" ]]; then
    add_alert "github_mcp" "$github_mcp" "WARN" "github_mcp_not_configured"
  fi
  if [[ "$env_bootstrap_state" != "OK" ]]; then
    add_alert "env_bootstrap" "$env_bootstrap" "WARN" "env_bootstrap_not_ready"
  fi
  if [[ "$hooks_path_state" != "MATCH" ]]; then
    add_alert "hooks_path" "$hooks_path" "WARN" "hooks_path_mismatch"
  fi
  if [[ "$pages_skill_state" != "PRESENT" ]]; then
    add_alert "pages_skill" "$pages_skill" "WARN" "pages_skill_missing"
  fi
  if [[ "$pages_docsify_validator_state" != "AVAILABLE" ]]; then
    add_alert "pages_docsify_validator" "$pages_docsify_validator" "WARN" "docsify_validator_missing"
  fi
  if [[ "$pages_release_flow_state" != "LINKED" ]]; then
    add_alert "pages_release_flow" "$pages_release_flow" "WARN" "pages_release_flow_missing"
  fi
  if [[ "$docsify_precommit_guard_state" != "ENABLED" ]]; then
    add_alert "docsify_precommit_guard" "$docsify_precommit_guard" "WARN" "docsify_precommit_guard_missing"
  fi
  if [[ "$owner_skill_lint_guard_state" != "ENABLED" ]]; then
    add_alert "owner_skill_lint_guard" "$owner_skill_lint_guard" "WARN" "owner_skill_lint_guard_missing"
  fi
  if [[ "$skill_naming_guard_state" != "ENABLED" ]]; then
    add_alert "skill_naming_guard" "$skill_naming_guard" "WARN" "skill_naming_guard_missing"
  fi
  if [[ "$mcp_servers_total" == "0" ]]; then
    add_alert "mcp_servers_total" "$mcp_servers_total" "WARN" "no_mcp_servers_configured"
  fi

  for server_name in "${mcp_server_names[@]}"; do
    server_status="${mcp_server_status[$server_name]}"
    case "$server_status" in
      RUNNING) ;;
      IDLE)
        add_alert "mcp:${server_name}" "${mcp_server_runtime[$server_name]}" "WARN" "mcp_server_idle"
        ;;
      *)
        add_alert "mcp:${server_name}" "${mcp_server_runtime[$server_name]}" "WARN" "mcp_server_unknown"
        ;;
    esac
  done

  for workflow_name in "${workflow_names[@]}"; do
    workflow_ready_state="${workflow_ready[$workflow_name]}"
    workflow_last_state="${workflow_last[$workflow_name]}"
    if [[ "$workflow_ready_state" != "READY" ]]; then
      add_alert "workflow:${workflow_name}" "$workflow_ready_state" "WARN" "workflow_not_ready"
      continue
    fi
    case "$workflow_last_state" in
      FAIL|WARN|BLOCKED)
        add_alert "workflow_last:${workflow_name}" "$workflow_last_state" "WARN" "workflow_last_not_ok"
        ;;
      *)
        ;;
    esac
  done

  alert_count="${#alert_entries[@]}"
  alert_summary_parts=()
  alert_detail_parts=()
  if [[ "$alert_count" -eq 0 ]]; then
    alerts_summary="all_clear"
    alerts_detail="none"
    return
  fi

  for entry in "${alert_entries[@]}"; do
    IFS='|' read -r item value status reason <<< "$entry"
    alert_summary_parts+=("${item}:${status}")
    alert_detail_parts+=("${item}|${status}|${reason}")
  done
  alerts_summary="$(IFS=','; echo "${alert_summary_parts[*]}")"
  alerts_detail="$(IFS=','; echo "${alert_detail_parts[*]}")"
}

print_alerts_section() {
  echo "[Alerts]"
  printf '%-32s %-28s %-10s %s\n' "item" "value" "status" "reason"
  printf '%-32s %-28s %-10s %s\n' "--------------------------------" "----------------------------" "----------" "------------------------------"
  if [[ "$alert_count" -eq 0 ]]; then
    printf '%-32s %-28s %-10s %s\n' "runtime" "all_clear" "OK" "none"
    return
  fi
  for entry in "${alert_entries[@]}"; do
    IFS='|' read -r item value status reason <<< "$entry"
    printf '%-32s %-28s %-10s %s\n' "$item" "$value" "$status" "$reason"
  done
}

print_status_table() {
  echo "[Runtime Status]"
  print_alerts_section
  echo
  echo "[User Controls]"
  printf '%-32s %-36s %s\n' "item" "value" "status"
  printf '%-32s %-36s %s\n' "--------------------------------" "------------------------------------" "--------"
  printf '%-32s %-36s %s\n' "precommit_mode" "$precommit_mode" "$precommit_mode_state"
  printf '%-32s %-36s %s\n' "precommit_strict" "$precommit_strict" "$precommit_strict_state"
  printf '%-32s %-36s %s\n' "active_project" "$active_project_label" "$active_project_state"
  echo
  echo "[Agent Checks]"
  printf '%-32s %-36s %s\n' "item" "value" "status"
  printf '%-32s %-36s %s\n' "--------------------------------" "------------------------------------" "--------"
  printf '%-32s %-36s %s\n' "github_mcp" "$github_mcp" "$github_mcp_state"
  printf '%-32s %-36s %s\n' "env_bootstrap" "$env_bootstrap" "$env_bootstrap_state"
  printf '%-32s %-36s %s\n' "hooks_path" "$hooks_path" "$hooks_path_state"
  printf '%-32s %-36s %s\n' "session_reload_guard" "$session_reload_guard" "$session_reload_guard_state"
  printf '%-32s %-36s %s\n' "session_handoff" "$session_handoff" "$session_handoff_state"
  printf '%-32s %-36s %s\n' "pages_skill" "$pages_skill" "$pages_skill_state"
  printf '%-32s %-36s %s\n' "pages_docsify_validator" "$pages_docsify_validator" "$pages_docsify_validator_state"
  printf '%-32s %-36s %s\n' "pages_release_flow" "$pages_release_flow" "$pages_release_flow_state"
  printf '%-32s %-36s %s\n' "docsify_precommit_guard" "$docsify_precommit_guard" "$docsify_precommit_guard_state"
  printf '%-32s %-36s %s\n' "owner_skill_lint_guard" "$owner_skill_lint_guard" "$owner_skill_lint_guard_state"
  printf '%-32s %-36s %s\n' "skill_naming_guard" "$skill_naming_guard" "$skill_naming_guard_state"
  echo
  echo "[Workflow Health]"
  printf '%-32s %-36s %s\n' "item" "value" "status"
  printf '%-32s %-36s %s\n' "--------------------------------" "------------------------------------" "--------"
  printf '%-32s %-36s %s\n' "workflow_total" "$workflow_total" "COUNT"
  printf '%-32s %-36s %s\n' "workflow_ready_count" "$workflow_ready_count" "COUNT"
  printf '%-32s %-36s %s\n' "workflow_not_ready_count" "$workflow_not_ready_count" "COUNT"
  printf '%-32s %-36s %s\n' "workflow_marks_count" "$workflow_marks_count" "COUNT"
  printf '%-32s %-36s %s\n' "workflow_marks_file" "$workflow_mark_file_label" "PATH"
  printf '%-32s %-36s %s\n' "workflows_ready" "$workflows_ready_list" "LIST"
  printf '%-32s %-36s %s\n' "workflows_not_ready" "$workflows_not_ready_list" "LIST"
  printf '%-32s %-36s %s\n' "workflows_last_summary" "$workflows_last_summary" "LIST"
  if [[ "${#workflow_names[@]}" -eq 0 ]]; then
    printf '%-32s %-36s %s\n' "workflow" "none" "NONE"
  else
    for workflow_name in "${workflow_names[@]}"; do
      printf '%-32s %-36s %s\n' "workflow:${workflow_name}" "${workflow_ready[$workflow_name]}" "${workflow_last[$workflow_name]}"
      printf '%-32s %-36s %s\n' "workflow:${workflow_name}:detail" "${workflow_detail[$workflow_name]}" "DETAIL"
    done
  fi
  echo
  echo "[Skill Inventory]"
  printf '%-32s %-36s %s\n' "item" "value" "status"
  printf '%-32s %-36s %s\n' "--------------------------------" "------------------------------------" "--------"
  printf '%-32s %-36s %s\n' "skills_total" "$all_skill_count" "COUNT"
  printf '%-32s %-36s %s\n' "skills_managed_count" "$managed_skill_count" "COUNT"
  printf '%-32s %-36s %s\n' "skills_delegated_count" "$delegated_skill_count" "COUNT"
  if [[ "${#managed_skill_names[@]}" -eq 0 ]]; then
    printf '%-32s %-36s %s\n' "skill:managed" "none" "NONE"
  else
    for skill_name in "${managed_skill_names[@]}"; do
      printf '%-32s %-36s %s\n' "skill:${skill_name}" "managed" "PRESENT"
    done
  fi
  if [[ "${#delegated_skill_names[@]}" -eq 0 ]]; then
    printf '%-32s %-36s %s\n' "skill:delegated" "none" "NONE"
  else
    for skill_name in "${delegated_skill_names[@]}"; do
      printf '%-32s %-36s %s\n' "skill:${skill_name}" "delegated" "PRESENT"
    done
  fi
  echo
  echo "[MCP Inventory]"
  printf '%-32s %-36s %s\n' "item" "value" "status"
  printf '%-32s %-36s %s\n' "--------------------------------" "------------------------------------" "--------"
  printf '%-32s %-36s %s\n' "mcp_servers_total" "$mcp_servers_total" "COUNT"
  printf '%-32s %-36s %s\n' "mcp_servers_configured" "$mcp_servers_configured_list" "LIST"
  printf '%-32s %-36s %s\n' "mcp_servers_running" "$mcp_servers_running_list" "LIST"
  printf '%-32s %-36s %s\n' "mcp_servers_docker_running" "$mcp_servers_docker_running_list" "LIST"
  if [[ "${#mcp_server_names[@]}" -eq 0 ]]; then
    printf '%-32s %-36s %s\n' "mcp_server" "none" "NONE"
  else
    for server_name in "${mcp_server_names[@]}"; do
      printf '%-32s %-36s %s\n' "mcp:${server_name}" "${mcp_server_runtime[$server_name]}" "${mcp_server_status[$server_name]}"
      printf '%-32s %-36s %s\n' "mcp:${server_name}:detail" "${mcp_server_detail[$server_name]}" "DETAIL"
    done
  fi
}

write_flags_file() {
  {
    cat <<EOF
version: 1
updated_at: $updated_at
precommit_mode: $precommit_mode
precommit_mode_state: $precommit_mode_state
precommit_strict: $precommit_strict
precommit_strict_state: $precommit_strict_state
github_mcp: $github_mcp
github_mcp_state: $github_mcp_state
env_bootstrap: $env_bootstrap
env_bootstrap_state: $env_bootstrap_state
hooks_path: $hooks_path
hooks_path_state: $hooks_path_state
session_reload_guard: $session_reload_guard
session_reload_guard_state: $session_reload_guard_state
active_project: $active_project
active_project_state: $active_project_state
session_handoff: $session_handoff
session_handoff_state: $session_handoff_state
pages_skill: $pages_skill
pages_skill_state: $pages_skill_state
pages_docsify_validator: $pages_docsify_validator
pages_docsify_validator_state: $pages_docsify_validator_state
pages_release_flow: $pages_release_flow
pages_release_flow_state: $pages_release_flow_state
docsify_precommit_guard: $docsify_precommit_guard
docsify_precommit_guard_state: $docsify_precommit_guard_state
owner_skill_lint_guard: $owner_skill_lint_guard
owner_skill_lint_guard_state: $owner_skill_lint_guard_state
skill_naming_guard: $skill_naming_guard
skill_naming_guard_state: $skill_naming_guard_state
skills_total: $all_skill_count
skills_managed_count: $managed_skill_count
skills_delegated_count: $delegated_skill_count
skills_managed: $managed_skill_list
skills_delegated: $delegated_skill_list
workflow_total: $workflow_total
workflow_ready_count: $workflow_ready_count
workflow_not_ready_count: $workflow_not_ready_count
workflow_marks_count: $workflow_marks_count
workflow_marks_file: $workflow_mark_file_label
workflows_ready: $workflows_ready_list
workflows_not_ready: $workflows_not_ready_list
workflows_last_summary: $workflows_last_summary
mcp_servers_total: $mcp_servers_total
mcp_servers_configured: $mcp_servers_configured_list
mcp_servers_running: $mcp_servers_running_list
mcp_servers_docker_running: $mcp_servers_docker_running_list
default_toolsets: $github_toolsets_default
mcp_alerts_count: $alert_count
mcp_alerts_summary: $alerts_summary
mcp_alerts_detail: $alerts_detail
EOF
    for server_name in "${mcp_server_names[@]}"; do
      safe_key="${server_name//-/_}"
      safe_key="${safe_key//./_}"
      echo "mcp_server_${safe_key}_runtime: ${mcp_server_runtime[$server_name]}"
      echo "mcp_server_${safe_key}_status: ${mcp_server_status[$server_name]}"
      echo "mcp_server_${safe_key}_detail: ${mcp_server_detail[$server_name]}"
    done
    for workflow_name in "${workflow_names[@]}"; do
      safe_key="${workflow_name//-/_}"
      safe_key="${safe_key//./_}"
      echo "workflow_${safe_key}_ready: ${workflow_ready[$workflow_name]}"
      echo "workflow_${safe_key}_last: ${workflow_last[$workflow_name]}"
      echo "workflow_${safe_key}_detail: ${workflow_detail[$workflow_name]}"
    done
  } > "$flags_file"
}

write_status_file() {
  print_status_table > "$status_file"
}

collect_runtime_state() {
  mkdir -p "$runtime_dir" "$state_dir"

  updated_at="$(date '+%Y-%m-%d %H:%M:%S')"

  precommit_mode="quick"
  if [[ -f "$mode_file" ]]; then
    precommit_mode="$(tr -d '[:space:]' < "$mode_file")"
  fi
  case "$precommit_mode" in
    quick|strict) ;;
    *) precommit_mode="quick" ;;
  esac

  precommit_mode_state="DEFAULT"
  if [[ "$precommit_mode" == "strict" ]]; then
    precommit_strict="true"
    precommit_strict_state="ACTIVE"
  else
    precommit_strict="false"
    precommit_strict_state="INACTIVE"
  fi

  if [[ -f "$codex_config_file" ]] && grep -Eq '^\[mcp_servers\.github\]' "$codex_config_file"; then
    github_mcp="configured"
    github_mcp_state="CONFIGURED"
  else
    github_mcp="not_configured"
    github_mcp_state="MISSING"
  fi

  env_report=""
  if [[ -x "$validate_env_entry" ]]; then
    env_report="$("$validate_env_entry" --quiet || true)"
  fi
  env_status="$(extract_kv "ENV_STATUS" "$env_report" || true)"
  hooks_path="$(extract_kv "HOOKS_PATH_CURRENT" "$env_report" || true)"
  if [[ -z "$env_status" ]]; then
    env_status="WARN"
  fi
  if [[ -z "$hooks_path" ]]; then
    hooks_path="(unknown)"
  fi

  if [[ "$env_status" == "OK" ]]; then
    env_bootstrap="ready"
    env_bootstrap_state="OK"
  else
    env_bootstrap="warn"
    env_bootstrap_state="WARN"
  fi

  if [[ "$hooks_path" == ".githooks" ]]; then
    hooks_path_state="MATCH"
  else
    hooks_path_state="MISMATCH"
  fi

  session_reload_guard="auto"
  session_reload_guard_state="AUTO"

  active_project="none"
  active_project_label="none"
  active_task_doc=""
  if [[ -f "$project_snapshot" ]]; then
    active_project_candidate="$(grep -E '^- Project Root:' "$project_snapshot" | sed -E 's/^- Project Root: `([^`]+)`/\1/' || true)"
    active_task_candidate="$(grep -E '^- Task Doc:' "$project_snapshot" | sed -E 's/^- Task Doc: `([^`]+)`/\1/' || true)"
    if [[ -n "$active_project_candidate" && "$active_project_candidate" != "(not selected)" ]]; then
      active_project="$active_project_candidate"
      active_project_label="$(basename "$active_project_candidate")"
    fi
    if [[ -n "$active_task_candidate" ]]; then
      active_task_doc="$active_task_candidate"
    fi
  fi
  if [[ "$active_project" == "none" ]]; then
    active_project_state="UNSELECTED"
  else
    active_project_state="SELECTED"
  fi

  if [[ -s "$handoff_file" ]]; then
    session_handoff="present"
    session_handoff_state="PRESENT"
  else
    session_handoff="none"
    session_handoff_state="ABSENT"
  fi

  pages_skill_file="$repo_root/skills/aki-github-pages-expert/SKILL.md"
  pages_validator_file="$repo_root/skills/aki-github-pages-expert/scripts/docsify_validator.py"
  pages_release_flow_file="$repo_root/skills/aki-codex-workflows/references/pages-release-verification-flow.md"
  core_policy_file="$repo_root/skills/aki-codex-precommit/policies/core-workspace.sh"
  owner_lint_file="$repo_root/skills/aki-codex-workflows/scripts/check-owner-skill-links.sh"
  skill_naming_file="$repo_root/skills/aki-codex-core/scripts/check-skill-naming.sh"

  if [[ -f "$pages_skill_file" ]]; then
    pages_skill="present"
    pages_skill_state="PRESENT"
  else
    pages_skill="missing"
    pages_skill_state="MISSING"
  fi

  if [[ -f "$pages_validator_file" ]]; then
    pages_docsify_validator="available"
    pages_docsify_validator_state="AVAILABLE"
  else
    pages_docsify_validator="missing"
    pages_docsify_validator_state="MISSING"
  fi

  if [[ -f "$pages_release_flow_file" ]]; then
    pages_release_flow="linked"
    pages_release_flow_state="LINKED"
  else
    pages_release_flow="missing"
    pages_release_flow_state="MISSING"
  fi

  if [[ -f "$core_policy_file" ]] && grep -q "docsify_validator.py" "$core_policy_file"; then
    docsify_precommit_guard="enabled"
    docsify_precommit_guard_state="ENABLED"
  else
    docsify_precommit_guard="missing"
    docsify_precommit_guard_state="MISSING"
  fi

  if [[ -f "$core_policy_file" ]] && grep -q "check-owner-skill-links.sh" "$core_policy_file" && [[ -x "$owner_lint_file" ]]; then
    owner_skill_lint_guard="enabled"
    owner_skill_lint_guard_state="ENABLED"
  else
    owner_skill_lint_guard="missing"
    owner_skill_lint_guard_state="MISSING"
  fi

  if [[ -f "$core_policy_file" ]] && grep -q "check-skill-naming.sh" "$core_policy_file" && [[ -x "$skill_naming_file" ]]; then
    skill_naming_guard="enabled"
    skill_naming_guard_state="ENABLED"
  else
    skill_naming_guard="missing"
    skill_naming_guard_state="MISSING"
  fi

  managed_skill_names=()
  delegated_skill_names=()
  mapfile -t skill_files < <(find "$repo_root/skills" -mindepth 2 -maxdepth 2 -type f -name "SKILL.md" | sort)
  for skill_file in "${skill_files[@]}"; do
    skill_name="$(basename "$(dirname "$skill_file")")"
    if [[ "$skill_name" == aki-* ]]; then
      managed_skill_names+=("$skill_name")
    else
      delegated_skill_names+=("$skill_name")
    fi
  done
  all_skill_count="${#skill_files[@]}"
  managed_skill_count="${#managed_skill_names[@]}"
  delegated_skill_count="${#delegated_skill_names[@]}"
  managed_skill_list="$(IFS=','; echo "${managed_skill_names[*]}")"
  delegated_skill_list="$(IFS=','; echo "${delegated_skill_names[*]}")"

  mcp_server_names=()
  mcp_server_runtime=()
  mcp_server_status=()
  mcp_server_detail=()
  running_mcp_servers=()
  running_mcp_docker_servers=()

  if [[ -f "$codex_config_file" ]]; then
    mapfile -t mcp_server_names < <(grep -E '^\[mcp_servers\.[^.]+\]$' "$codex_config_file" | sed -E 's/^\[mcp_servers\.([^.]+)\]$/\1/' | sort -u)
  fi

  docker_ps_images=""
  docker_probe_status="UNAVAILABLE"
  if command -v docker >/dev/null 2>&1; then
    if docker_ps_images="$(docker ps --format '{{.Image}}' 2>/dev/null)"; then
      docker_probe_status="OK"
    else
      docker_probe_status="RESTRICTED"
      docker_ps_images=""
    fi
  fi

  for server_name in "${mcp_server_names[@]}"; do
    command_value="$(get_mcp_section_value "$server_name" "command" || true)"
    command_value="$(strip_wrapped_quotes "$command_value")"
    args_value="$(get_mcp_section_value "$server_name" "args" || true)"
    runtime_kind="${command_value:-unknown}"
    status_value="UNKNOWN"
    detail_value=""

    case "$runtime_kind" in
      docker)
        docker_image="$(extract_first_docker_image "$args_value")"
        process_probe_pattern="${server_name}-mcp"
        if [[ "$server_name" == "github" ]]; then
          process_probe_pattern="github-mcp-server|${docker_image}"
        fi
        docker_process_running="false"
        if pgrep -fa "$process_probe_pattern" >/dev/null 2>&1; then
          docker_process_running="true"
        fi
        if [[ -n "$docker_image" ]]; then
          docker_container_running="false"
          if [[ "$docker_probe_status" == "OK" ]] && printf '%s\n' "$docker_ps_images" | grep -Fxq "$docker_image"; then
            docker_container_running="true"
          fi
          if [[ "$docker_container_running" == "true" || "$docker_process_running" == "true" ]]; then
            status_value="RUNNING"
            detail_value="docker_image:${docker_image}:UP:probe=${docker_probe_status}"
            running_mcp_servers+=("$server_name")
            running_mcp_docker_servers+=("$server_name")
          else
            if [[ "$docker_probe_status" == "OK" ]]; then
              status_value="IDLE"
              detail_value="docker_image:${docker_image}:DOWN:probe=${docker_probe_status}"
            else
              status_value="UNKNOWN"
              detail_value="docker_image:${docker_image}:probe=${docker_probe_status}"
            fi
          fi
        else
          if [[ "$docker_process_running" == "true" ]]; then
            status_value="RUNNING"
            detail_value="docker_image:unknown:probe=${docker_probe_status}"
            running_mcp_servers+=("$server_name")
            running_mcp_docker_servers+=("$server_name")
          else
            status_value="UNKNOWN"
            detail_value="docker_image:unknown:probe=${docker_probe_status}"
          fi
        fi
        ;;
      npx|node|python|uvx)
        probe_pattern="$server_name"
        if [[ "$server_name" == "playwright" ]]; then
          probe_pattern="@playwright/mcp|playwright-mcp"
        elif [[ "$server_name" == "github" ]]; then
          probe_pattern="github-mcp-server"
        fi
        if pgrep -fa "$probe_pattern" >/dev/null 2>&1; then
          status_value="RUNNING"
          running_mcp_servers+=("$server_name")
        else
          status_value="IDLE"
        fi
        detail_value="runtime:${runtime_kind}"
        ;;
      "")
        status_value="MISSING"
        detail_value="runtime:missing"
        runtime_kind="unknown"
        ;;
      *)
        status_value="UNKNOWN"
        detail_value="runtime:${runtime_kind}"
        ;;
    esac

    mcp_server_runtime["$server_name"]="$runtime_kind"
    mcp_server_status["$server_name"]="$status_value"
    mcp_server_detail["$server_name"]="$detail_value"
  done

  mcp_servers_total="${#mcp_server_names[@]}"
  if [[ "${#mcp_server_names[@]}" -gt 0 ]]; then
    mcp_servers_configured_list="$(IFS=','; echo "${mcp_server_names[*]}")"
  else
    mcp_servers_configured_list="none"
  fi
  if [[ "${#running_mcp_servers[@]}" -gt 0 ]]; then
    mcp_servers_running_list="$(IFS=','; echo "${running_mcp_servers[*]}")"
  else
    mcp_servers_running_list="none"
  fi
  if [[ "${#running_mcp_docker_servers[@]}" -gt 0 ]]; then
    mcp_servers_docker_running_list="$(IFS=','; echo "${running_mcp_docker_servers[*]}")"
  else
    mcp_servers_docker_running_list="none"
  fi

  workflow_names=()
  workflow_ready=()
  workflow_last=()
  workflow_detail=()
  load_workflow_marks

  workflow_refs_dir="$repo_root/skills/aki-codex-workflows/references"
  meeting_flow_ref="$workflow_refs_dir/meeting-notes-flow.md"
  precommit_flow_ref="$workflow_refs_dir/precommit-flow.md"
  session_reload_flow_ref="$workflow_refs_dir/session-reload-flow.md"
  github_mcp_init_flow_ref="$workflow_refs_dir/github-mcp-init-flow.md"
  pages_release_flow_ref="$workflow_refs_dir/pages-release-verification-flow.md"
  pr_merge_flow_ref="$workflow_refs_dir/pr-merge-readiness-flow.md"
  issue_lifecycle_flow_ref="$workflow_refs_dir/issue-lifecycle-governance-flow.md"
  runtime_status_flow_ref="$workflow_refs_dir/runtime-status-flow.md"

  precommit_mode_script="$repo_root/skills/aki-codex-precommit/scripts/precommit_mode.sh"
  precommit_chain_script="$repo_root/skills/aki-codex-precommit/scripts/validate-precommit-chain.sh"
  session_start_script="$repo_root/skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh"
  skills_reload_script="$repo_root/skills/aki-codex-session-reload/scripts/codex_skills_reload/skills_reload.sh"
  project_reload_script="$repo_root/skills/aki-codex-session-reload/scripts/codex_skills_reload/project_reload.sh"
  runtime_flags_script="$repo_root/skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh"
  issue_upsert_script="$repo_root/skills/aki-mcp-github/scripts/issue-upsert.sh"
  meeting_skill_file="$repo_root/skills/aki-meeting-notes-task-sync/SKILL.md"
  mcp_github_skill_file="$repo_root/skills/aki-mcp-github/SKILL.md"
  session_snapshot="$runtime_dir/codex_session_start.md"
  hooks_report_file="$runtime_dir/skill-hooks-report.json"

  precommit_hook_status=""
  session_hook_status=""
  if [[ -f "$hooks_report_file" ]]; then
    precommit_hook_status="$(grep -E '"id": "chain_(quick|strict)"' -A4 "$hooks_report_file" | grep -E '"status": "' | tail -n 1 | sed -E 's/.*"status": "([^"]+)".*/\1/' || true)"
    session_hook_status="$(grep -E '"id": "session_start"' -A4 "$hooks_report_file" | grep -E '"status": "' | tail -n 1 | sed -E 's/.*"status": "([^"]+)".*/\1/' || true)"
  fi

  session_snapshot_ok="false"
  if [[ -f "$session_snapshot" ]] \
    && grep -q 'Skills Snapshot: `OK`' "$session_snapshot" \
    && grep -q 'Project Snapshot: `OK`' "$session_snapshot" \
    && grep -q 'Skills Runtime Integrity: `OK`' "$session_snapshot" \
    && grep -q 'Runtime Flags: `OK`' "$session_snapshot"; then
    session_snapshot_ok="true"
  fi

  meeting_missing=()
  [[ -f "$meeting_flow_ref" ]] || meeting_missing+=("flow_ref")
  [[ -f "$meeting_skill_file" ]] || meeting_missing+=("meeting_skill")
  [[ -f "$mcp_github_skill_file" ]] || meeting_missing+=("github_skill")
  if [[ "$active_project_state" != "SELECTED" ]]; then
    meeting_missing+=("active_project")
  elif [[ -n "$active_task_doc" ]]; then
    if [[ ! -f "$repo_root/$active_task_doc" ]]; then
      meeting_missing+=("task_doc")
    fi
  else
    meeting_missing+=("task_doc")
  fi
  meeting_ready_state="READY"
  if [[ "${#meeting_missing[@]}" -gt 0 ]]; then
    meeting_ready_state="NOT_READY"
  fi
  set_workflow_state "meeting_notes" "$meeting_ready_state" "UNVERIFIED" "$(format_missing_detail "${meeting_missing[@]}")"

  precommit_missing=()
  [[ -f "$precommit_flow_ref" ]] || precommit_missing+=("flow_ref")
  [[ -x "$precommit_mode_script" ]] || precommit_missing+=("precommit_mode_script")
  [[ -x "$precommit_chain_script" ]] || precommit_missing+=("precommit_chain_script")
  precommit_ready_state="READY"
  if [[ "${#precommit_missing[@]}" -gt 0 ]]; then
    precommit_ready_state="NOT_READY"
  fi
  precommit_last_state="$(map_hook_status "$precommit_hook_status")"
  if [[ -z "$precommit_hook_status" ]]; then
    precommit_detail_value="$(format_missing_detail "${precommit_missing[@]}")"
    if [[ "$precommit_detail_value" == "none" ]]; then
      precommit_detail_value="hook:none"
    else
      precommit_detail_value="${precommit_detail_value};hook:none"
    fi
  else
    precommit_detail_value="$(format_missing_detail "${precommit_missing[@]}")"
    if [[ "$precommit_detail_value" == "none" ]]; then
      precommit_detail_value="hook:${precommit_hook_status}"
    else
      precommit_detail_value="${precommit_detail_value};hook:${precommit_hook_status}"
    fi
  fi
  set_workflow_state "precommit" "$precommit_ready_state" "$precommit_last_state" "$precommit_detail_value"

  session_reload_missing=()
  [[ -f "$session_reload_flow_ref" ]] || session_reload_missing+=("flow_ref")
  [[ -x "$session_start_script" ]] || session_reload_missing+=("session_start_script")
  [[ -x "$skills_reload_script" ]] || session_reload_missing+=("skills_reload_script")
  [[ -x "$project_reload_script" ]] || session_reload_missing+=("project_reload_script")
  session_reload_ready_state="READY"
  if [[ "${#session_reload_missing[@]}" -gt 0 ]]; then
    session_reload_ready_state="NOT_READY"
  fi
  session_reload_last_state="UNVERIFIED"
  if [[ "$session_snapshot_ok" == "true" ]]; then
    session_reload_last_state="PASS"
  elif [[ -f "$session_snapshot" ]]; then
    session_reload_last_state="WARN"
  fi
  session_hook_mapped="$(map_hook_status "$session_hook_status")"
  if [[ "$session_hook_mapped" == "FAIL" ]]; then
    session_reload_last_state="FAIL"
  elif [[ "$session_reload_last_state" == "UNVERIFIED" && "$session_hook_mapped" != "UNVERIFIED" ]]; then
    session_reload_last_state="$session_hook_mapped"
  fi
  session_reload_detail_value="$(format_missing_detail "${session_reload_missing[@]}")"
  if [[ "$session_reload_detail_value" == "none" ]]; then
    session_reload_detail_value="snapshot:${session_snapshot_ok};hook:${session_hook_status:-none}"
  else
    session_reload_detail_value="${session_reload_detail_value};snapshot:${session_snapshot_ok};hook:${session_hook_status:-none}"
  fi
  set_workflow_state "session_reload" "$session_reload_ready_state" "$session_reload_last_state" "$session_reload_detail_value"

  github_init_missing=()
  [[ -f "$github_mcp_init_flow_ref" ]] || github_init_missing+=("flow_ref")
  [[ -f "$mcp_github_skill_file" ]] || github_init_missing+=("github_skill")
  if [[ "$github_mcp_state" != "CONFIGURED" ]]; then
    github_init_missing+=("github_mcp")
  fi
  github_init_ready_state="READY"
  if [[ "${#github_init_missing[@]}" -gt 0 ]]; then
    github_init_ready_state="NOT_READY"
  fi
  github_init_exec_status=""
  if [[ -f "$session_snapshot" ]]; then
    github_init_exec_status="$(grep -E '^- Execution Status:' "$session_snapshot" | head -n 1 | sed -E 's/^- Execution Status: `([^`]+)`/\1/' || true)"
  fi
  github_init_last_state="UNVERIFIED"
  if [[ -n "$github_init_exec_status" ]]; then
    case "${github_init_exec_status^^}" in
      NOT_EXECUTED) github_init_last_state="NOT_RUN" ;;
      BLOCKED) github_init_last_state="BLOCKED" ;;
      FAIL|FAILED|ERROR) github_init_last_state="FAIL" ;;
      OK|SUCCESS|ENABLED|COMPLETED) github_init_last_state="PASS" ;;
      *) github_init_last_state="UNVERIFIED" ;;
    esac
  fi
  github_init_detail_value="$(format_missing_detail "${github_init_missing[@]}")"
  if [[ "$github_init_detail_value" == "none" ]]; then
    github_init_detail_value="execution:${github_init_exec_status:-unknown}"
  else
    github_init_detail_value="${github_init_detail_value};execution:${github_init_exec_status:-unknown}"
  fi
  set_workflow_state "github_mcp_init" "$github_init_ready_state" "$github_init_last_state" "$github_init_detail_value"

  pages_release_missing=()
  [[ -f "$pages_release_flow_ref" ]] || pages_release_missing+=("flow_ref")
  [[ -f "$pages_skill_file" ]] || pages_release_missing+=("pages_skill")
  [[ -f "$pages_validator_file" ]] || pages_release_missing+=("docsify_validator")
  pages_release_ready_state="READY"
  if [[ "${#pages_release_missing[@]}" -gt 0 ]]; then
    pages_release_ready_state="NOT_READY"
  fi
  set_workflow_state "pages_release_verification" "$pages_release_ready_state" "UNVERIFIED" "$(format_missing_detail "${pages_release_missing[@]}")"

  pr_merge_missing=()
  [[ -f "$pr_merge_flow_ref" ]] || pr_merge_missing+=("flow_ref")
  [[ -x "$precommit_chain_script" ]] || pr_merge_missing+=("precommit_chain_script")
  [[ -x "$session_start_script" ]] || pr_merge_missing+=("session_start_script")
  pr_merge_ready_state="READY"
  if [[ "${#pr_merge_missing[@]}" -gt 0 ]]; then
    pr_merge_ready_state="NOT_READY"
  fi
  set_workflow_state "pr_merge_readiness" "$pr_merge_ready_state" "UNVERIFIED" "$(format_missing_detail "${pr_merge_missing[@]}")"

  issue_lifecycle_missing=()
  [[ -f "$issue_lifecycle_flow_ref" ]] || issue_lifecycle_missing+=("flow_ref")
  [[ -f "$mcp_github_skill_file" ]] || issue_lifecycle_missing+=("github_skill")
  [[ -x "$issue_upsert_script" ]] || issue_lifecycle_missing+=("issue_upsert_script")
  issue_lifecycle_ready_state="READY"
  if [[ "${#issue_lifecycle_missing[@]}" -gt 0 ]]; then
    issue_lifecycle_ready_state="NOT_READY"
  fi
  set_workflow_state "issue_lifecycle_governance" "$issue_lifecycle_ready_state" "UNVERIFIED" "$(format_missing_detail "${issue_lifecycle_missing[@]}")"

  runtime_status_missing=()
  [[ -f "$runtime_status_flow_ref" ]] || runtime_status_missing+=("flow_ref")
  [[ -x "$runtime_flags_script" ]] || runtime_status_missing+=("runtime_flags_script")
  [[ -w "$runtime_dir" ]] || runtime_status_missing+=("runtime_dir_write")
  [[ -w "$state_dir" ]] || runtime_status_missing+=("state_dir_write")
  runtime_status_ready_state="READY"
  if [[ "${#runtime_status_missing[@]}" -gt 0 ]]; then
    runtime_status_ready_state="NOT_READY"
  fi
  runtime_status_last_state="PASS"
  if [[ "$runtime_status_ready_state" != "READY" ]]; then
    runtime_status_last_state="WARN"
  fi
  set_workflow_state "runtime_status_visibility" "$runtime_status_ready_state" "$runtime_status_last_state" "$(format_missing_detail "${runtime_status_missing[@]}")"

  ready_workflows=()
  not_ready_workflows=()
  workflow_last_parts=()
  for workflow_name in "${workflow_names[@]}"; do
    if [[ "${workflow_ready[$workflow_name]}" == "READY" ]]; then
      ready_workflows+=("$workflow_name")
    else
      not_ready_workflows+=("$workflow_name")
    fi
    workflow_last_parts+=("${workflow_name}:${workflow_last[$workflow_name]}")
  done
  workflow_total="${#workflow_names[@]}"
  workflow_ready_count="${#ready_workflows[@]}"
  workflow_not_ready_count="${#not_ready_workflows[@]}"
  workflows_ready_list="$(join_csv "${ready_workflows[@]}")"
  workflows_not_ready_list="$(join_csv "${not_ready_workflows[@]}")"
  workflows_last_summary="$(join_csv "${workflow_last_parts[@]}")"

  build_alerts
}

command="${1:-sync}"
if [[ $# -gt 0 ]]; then
  shift
fi

quiet_mode="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet)
      quiet_mode="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[runtime-flags] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

case "$command" in
  sync)
    collect_runtime_state
    write_flags_file
    write_status_file
    if [[ "$quiet_mode" != "true" ]]; then
      print_status_table
      echo "[runtime-flags] flags: ${flags_file#$repo_root/}"
      echo "[runtime-flags] status: ${status_file#$repo_root/}"
    fi
    ;;
  status)
    collect_runtime_state
    write_flags_file
    write_status_file
    print_status_table
    ;;
  alerts)
    collect_runtime_state
    write_flags_file
    write_status_file
    print_alerts_section
    ;;
  paths)
    echo "flags_file=${flags_file#$repo_root/}"
    echo "status_file=${status_file#$repo_root/}"
    ;;
  *)
    echo "[runtime-flags] unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
