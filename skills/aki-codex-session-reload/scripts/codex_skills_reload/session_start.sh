#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi
reload_entry="./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh"
set_active_entry="./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh"
bootstrap_env_entry="./skills/aki-codex-session-reload/scripts/codex_skills_reload/bootstrap_env.sh"
runtime_flags_entry="./skills/aki-codex-session-reload/scripts/codex_skills_reload/runtime_flags.sh"
workflow_mark_entry="./skills/aki-codex-workflows/scripts/workflow_mark.sh"
workflow_mark_script="$repo_root/skills/aki-codex-workflows/scripts/workflow_mark.sh"

runtime_dir="$repo_root/.codex/runtime"
runtime_status_file="$runtime_dir/current_status.txt"
runtime_flags_file="$repo_root/.codex/state/runtime_flags.yaml"
workflow_marks_file="$repo_root/.codex/state/workflow_marks.tsv"
skills_snapshot="$runtime_dir/codex_skills_reload.md"
project_snapshot="$runtime_dir/codex_project_reload.md"
session_snapshot="$runtime_dir/codex_session_start.md"
handoff_file="$repo_root/mcp/runtime/SESSION_HANDOFF.md"
codex_home="${CODEX_HOME:-$HOME/.codex}"
codex_config_file="$codex_home/config.toml"
github_toolsets_default="${GITHUB_MCP_DEFAULT_TOOLSETS:-context,repos,issues,projects,pull_requests,labels}"

"$script_dir/skills_reload.sh" >/dev/null
"$script_dir/project_reload.sh" >/dev/null
mkdir -p "$runtime_dir"

mapfile -t loaded_skills < <(find "$repo_root/skills" -mindepth 2 -maxdepth 2 -type f -name "SKILL.md" | sort)
declare -a managed_skills=()
declare -a delegated_skills=()
for abs_path in "${loaded_skills[@]}"; do
  rel_path="${abs_path#$repo_root/}"
  skill_name="$(basename "$(dirname "$abs_path")")"
  if [[ "$skill_name" == aki-* ]]; then
    managed_skills+=("$rel_path")
  else
    delegated_skills+=("$rel_path")
  fi
done

active_project=""
active_readme=""
active_task=""
active_agent=""
active_meeting_notes=""
if [[ -f "$project_snapshot" ]]; then
  active_project="$(grep -E '^- Project Root:' "$project_snapshot" | sed -E 's/^- Project Root: `([^`]+)`/\1/' || true)"
  active_readme="$(grep -E '^- Project README:' "$project_snapshot" | sed -E 's/^- Project README: `([^`]+)`/\1/' || true)"
  active_task="$(grep -E '^- Task Doc:' "$project_snapshot" | sed -E 's/^- Task Doc: `([^`]+)`/\1/' || true)"
  active_agent="$(grep -E '^- Project Agent:' "$project_snapshot" | sed -E 's/^- Project Agent: `([^`]+)`/\1/' || true)"
  active_meeting_notes="$(grep -E '^- Meeting Notes:' "$project_snapshot" | sed -E 's/^- Meeting Notes: `([^`]+)`/\1/' || true)"
fi

default_work_branch="${CODEX_DEFAULT_WORK_BRANCH:-main}"
git_current_branch="$(git -C "$repo_root" branch --show-current 2>/dev/null || true)"
git_head_short="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || true)"
git_tracking_branch="$(git -C "$repo_root" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"

[[ -z "$git_current_branch" ]] && git_current_branch="(detached HEAD)"
[[ -z "$git_head_short" ]] && git_head_short="(unknown)"
[[ -z "$git_tracking_branch" ]] && git_tracking_branch="(none)"

branch_guard="ON_MAIN"
branch_guard_action="none"
if [[ "$git_current_branch" != "$default_work_branch" ]]; then
  branch_guard="OFF_DEFAULT"
  branch_guard_action="사용자 명시 요청이 없다면 \`git checkout ${default_work_branch}\` 후 진행"
fi

handoff_status="NONE"
handoff_created=""
handoff_reason=""
if [[ -s "$handoff_file" ]]; then
  handoff_status="PENDING"
  handoff_created="$(grep -E '^- Created At:' "$handoff_file" | head -n 1 | sed -E 's/^- Created At: `([^`]+)`/\1/' || true)"
  handoff_reason="$(grep -E '^- Reason:' "$handoff_file" | head -n 1 | sed -E 's/^- Reason: ?//' || true)"
fi

github_mcp_status="NOT_CONFIGURED"
if [[ -f "$codex_config_file" ]] && grep -Eq '^\[mcp_servers\.github\]' "$codex_config_file"; then
  github_mcp_status="CONFIGURED"
fi

skills_status="OK"
project_status="OK"
runtime_status="OK"

workflow_mark_recorded="false"
record_session_reload_mark() {
  local workflow_status="$1"
  local detail=""
  if [[ "$workflow_mark_recorded" == "true" ]]; then
    return 0
  fi
  workflow_mark_recorded="true"
  if [[ ! -x "$workflow_mark_script" ]]; then
    return 0
  fi
  detail="project=${active_project:-none};runtime=${runtime_status:-unknown};flags=${flags_status:-unknown}"
  "$workflow_mark_script" set \
    --workflow "session_reload" \
    --status "$workflow_status" \
    --source "session_start.sh" \
    --detail "$detail" >/dev/null 2>&1 || true
}

on_session_start_exit() {
  local exit_code="$1"
  if [[ "$exit_code" -eq 0 ]]; then
    record_session_reload_mark "PASS"
  else
    record_session_reload_mark "FAIL"
  fi
}

trap 'on_session_start_exit $?' EXIT

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

extract_flag_value() {
  local key="$1"
  if [[ ! -f "$runtime_flags_file" ]]; then
    return 1
  fi
  awk -F': ' -v key="$key" '$1==key {print substr($0, index($0, ": ")+2); exit}' "$runtime_flags_file"
}

count_status_in_workflow_summary() {
  local summary="$1"
  local target="$2"
  local count=0
  local entry=""
  local status=""
  if [[ -z "$summary" || "$summary" == "none" ]]; then
    echo "0"
    return 0
  fi
  IFS=',' read -r -a entries <<< "$summary"
  for entry in "${entries[@]}"; do
    status="${entry##*:}"
    if [[ "$status" == "$target" ]]; then
      count=$((count + 1))
    fi
  done
  echo "$count"
}

get_workflow_mark_status() {
  local workflow_name="$1"
  if [[ ! -f "$workflow_marks_file" ]]; then
    return 1
  fi
  awk -F'\t' -v name="$workflow_name" '$1==name {print $2; exit}' "$workflow_marks_file"
}

seed_github_init_mark_if_missing() {
  local detail="execution=guide_only;server_config=${github_mcp_status}"
  if [[ "$github_mcp_status" != "CONFIGURED" ]]; then
    return 0
  fi
  if [[ ! -x "$workflow_mark_script" ]]; then
    return 0
  fi
  if "$workflow_mark_script" get --workflow "github_mcp_init" >/dev/null 2>&1; then
    return 0
  fi
  "$workflow_mark_script" set \
    --workflow "github_mcp_init" \
    --status "NOT_RUN" \
    --source "session_start.sh" \
    --detail "$detail" >/dev/null 2>&1 || true
}

env_report="$("$script_dir/validate_env.sh" --quiet || true)"
env_status="$(extract_kv "ENV_STATUS" "$env_report" || true)"
env_hooks_current="$(extract_kv "HOOKS_PATH_CURRENT" "$env_report" || true)"
env_hooks_expected="$(extract_kv "HOOKS_PATH_EXPECTED" "$env_report" || true)"
env_missing_files="$(extract_kv "MISSING_FILES" "$env_report" || true)"
env_nonexec_files="$(extract_kv "NONEXEC_FILES" "$env_report" || true)"
env_action="$(extract_kv "ACTION" "$env_report" || true)"

if [[ -z "$env_status" ]]; then
  env_status="WARN"
fi
if [[ -z "$env_action" ]]; then
  env_action="$bootstrap_env_entry"
fi

seed_github_init_mark_if_missing

flags_status="OK"
if [[ -x "$script_dir/runtime_flags.sh" ]]; then
  if ! "$script_dir/runtime_flags.sh" sync --quiet >/dev/null 2>&1; then
    flags_status="WARN"
  fi
else
  flags_status="WARN"
fi

if [[ ! -f "$skills_snapshot" || "${#loaded_skills[@]}" -eq 0 ]]; then
  skills_status="WARN"
fi

if [[ -z "$active_project" || "$active_project" == "(not selected)" ]]; then
  project_status="WARN"
fi

if [[ "$env_status" != "OK" ]]; then
  runtime_status="WARN"
fi
if [[ "$flags_status" != "OK" ]]; then
  runtime_status="WARN"
fi

workflow_total_value="$(extract_flag_value "workflow_total" || true)"
workflow_ready_value="$(extract_flag_value "workflow_ready_count" || true)"
workflow_last_summary_value="$(extract_flag_value "workflows_last_summary" || true)"
workflow_marks_count_value="$(extract_flag_value "workflow_marks_count" || true)"
runtime_alert_count_value="$(extract_flag_value "mcp_alerts_count" || true)"
[[ -z "$workflow_total_value" ]] && workflow_total_value="0"
[[ -z "$workflow_ready_value" ]] && workflow_ready_value="0"
[[ -z "$workflow_last_summary_value" ]] && workflow_last_summary_value="none"
[[ -z "$workflow_marks_count_value" ]] && workflow_marks_count_value="0"
[[ -z "$runtime_alert_count_value" ]] && runtime_alert_count_value="0"
workflow_pass_count="$(count_status_in_workflow_summary "$workflow_last_summary_value" "PASS")"
workflow_fail_count="$(count_status_in_workflow_summary "$workflow_last_summary_value" "FAIL")"
workflow_not_run_count="$(count_status_in_workflow_summary "$workflow_last_summary_value" "NOT_RUN")"
workflow_unverified_count="$(count_status_in_workflow_summary "$workflow_last_summary_value" "UNVERIFIED")"
workflow_blocked_count="$(count_status_in_workflow_summary "$workflow_last_summary_value" "BLOCKED")"
workflow_warn_count="$(count_status_in_workflow_summary "$workflow_last_summary_value" "WARN")"
workflow_summary_extra=""
if [[ "$workflow_blocked_count" != "0" ]]; then
  workflow_summary_extra="${workflow_summary_extra} BLOCKED ${workflow_blocked_count}"
fi
if [[ "$workflow_warn_count" != "0" ]]; then
  workflow_summary_extra="${workflow_summary_extra} WARN ${workflow_warn_count}"
fi
workflow_summary_line="ready ${workflow_ready_value}/${workflow_total_value} | PASS ${workflow_pass_count} FAIL ${workflow_fail_count} NOT_RUN ${workflow_not_run_count} UNVERIFIED ${workflow_unverified_count}${workflow_summary_extra} | marks ${workflow_marks_count_value} alerts ${runtime_alert_count_value}"
github_init_mark_status="$(get_workflow_mark_status "github_mcp_init" || true)"
github_init_execution_status="NOT_EXECUTED"
if [[ -n "$github_init_mark_status" ]]; then
  case "$github_init_mark_status" in
    PASS) github_init_execution_status="COMPLETED" ;;
    FAIL) github_init_execution_status="FAILED" ;;
    BLOCKED) github_init_execution_status="BLOCKED" ;;
    NOT_RUN|UNVERIFIED) github_init_execution_status="NOT_EXECUTED" ;;
    *) github_init_execution_status="$github_init_mark_status" ;;
  esac
fi

now_human="$(date '+%Y-%m-%d %H:%M:%S')"
now_ver="$(date '+%Y%m%d-%H%M%S')"

{
  echo "# Codex Session Start"
  echo
  echo "- Version: \`$now_ver\`"
  echo "- Updated At: \`$now_human\`"
  echo "- Generated By: \`skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh\`"
  echo
  echo "## Startup Checks"
  echo "- Skills Snapshot: \`$skills_status\`"
  echo "- Project Snapshot: \`$project_status\`"
  echo "- Skills Runtime Integrity: \`$runtime_status\`"
  echo "- Runtime Flags: \`$flags_status\`"
  if [[ "$runtime_status" == "WARN" ]]; then
    [[ -z "$env_hooks_current" ]] && env_hooks_current="(unknown)"
    [[ -z "$env_hooks_expected" ]] && env_hooks_expected=".githooks"
    [[ -z "$env_missing_files" ]] && env_missing_files="(none)"
    [[ -z "$env_nonexec_files" ]] && env_nonexec_files="(none)"
    echo "- Env Validate: \`$env_status\`"
    echo "- Hooks Path: \`$env_hooks_current\` (expected: \`$env_hooks_expected\`)"
    echo "- Missing Files: \`$env_missing_files\`"
    echo "- Non-Executable Files: \`$env_nonexec_files\`"
    echo "- Action: \`$env_action\`"
    if [[ "$flags_status" != "OK" ]]; then
      echo "- Runtime Flags Action: \`$runtime_flags_entry sync\`"
    fi
  fi
  echo
  echo "## Runtime Status"
  if [[ -f "$runtime_status_file" ]]; then
    echo "\`\`\`text"
    cat "$runtime_status_file"
    echo "\`\`\`"
    echo "- Flags File: \`${runtime_flags_file#$repo_root/}\`"
    echo "- Show Command: \`$runtime_flags_entry status\`"
    echo "- Alerts Command: \`$runtime_flags_entry alerts\`"
    echo "- Workflow Summary: \`$workflow_summary_line\`"
  else
    echo "- Status: \`UNAVAILABLE\`"
    echo "- Action: \`$runtime_flags_entry sync\`"
  fi
  echo
  echo "## Loaded Skills"
  if [[ "${#loaded_skills[@]}" -eq 0 ]]; then
    echo "1. \`(none)\`"
  else
    idx=1
    for abs_path in "${loaded_skills[@]}"; do
      rel_path="${abs_path#$repo_root/}"
      skill_name="$(basename "$(dirname "$abs_path")")"
      scope_tag="delegated"
      if [[ "$skill_name" == aki-* ]]; then
        scope_tag="managed"
      fi
      echo "$idx. [${scope_tag}] \`$rel_path\`"
      idx=$((idx + 1))
    done
  fi
  echo
  echo "## Skill Management Scope"
  echo "- Managed Policy: \`skills/aki-*\`를 전역 관리 대상으로 사용"
  echo "- Delegated Policy: 비-\`aki\` 스킬은 Active Project 요구 시에만 사용"
  echo "- Managed Count: \`${#managed_skills[@]}\`"
  echo "- Delegated Count: \`${#delegated_skills[@]}\`"
  if [[ "${#delegated_skills[@]}" -gt 0 ]]; then
    echo "- Delegated Skills:"
    for skill_path in "${delegated_skills[@]}"; do
      echo "  - \`$skill_path\`"
    done
  fi
  echo
  echo "## Active Project"
  if [[ -n "$active_project" && "$active_project" != "(not selected)" ]]; then
    echo "- Project Root: \`$active_project\`"
    [[ -n "$active_readme" ]] && echo "- Project README: \`$active_readme\`"
    [[ -n "$active_task" ]] && echo "- Task Doc: \`$active_task\`"
    [[ -n "$active_agent" ]] && echo "- Project Agent: \`$active_agent\`"
    [[ -n "$active_meeting_notes" ]] && echo "- Meeting Notes: \`$active_meeting_notes\`"
  else
    echo "- Project Root: \`(not selected)\`"
    echo "- Action: \`$set_active_entry <project-root>\`"
  fi
  echo
  echo "## Git Branch Context"
  echo "- Current Branch: \`$git_current_branch\`"
  echo "- HEAD: \`$git_head_short\`"
  echo "- Tracking Branch: \`$git_tracking_branch\`"
  echo "- Default Branch: \`$default_work_branch\`"
  echo "- Branch Guard: \`$branch_guard\`"
  if [[ "$branch_guard_action" != "none" ]]; then
    echo "- Action: $branch_guard_action"
  fi
  echo
  echo "## Session Handoff"
  if [[ "$handoff_status" == "PENDING" ]]; then
    echo "- Status: \`PENDING\`"
    echo "- File: \`mcp/runtime/SESSION_HANDOFF.md\`"
    [[ -n "$handoff_created" ]] && echo "- Created At: \`$handoff_created\`"
    [[ -n "$handoff_reason" ]] && echo "- Reason: $handoff_reason"
    echo "- Action: \`mcp/runtime/SESSION_HANDOFF.md\`를 먼저 읽고 이어서 진행"
  else
    echo "- Status: \`NONE\`"
  fi
  echo
  echo "## GitHub MCP Init"
  echo "- Init Mode: \`guide_only\`"
  echo "- Server Config: \`$github_mcp_status\`"
  echo "- Default Toolsets: \`$github_toolsets_default\`"
  if [[ "$github_mcp_status" == "CONFIGURED" ]]; then
    echo "- Execution Status: \`$github_init_execution_status\`"
    echo "- Action Guide: \`skills/aki-mcp-github/SKILL.md\`의 init flow로 \`$github_toolsets_default\` enable + 재검증"
    echo "- Report Contract: 실행 후 \`enabled\`/\`failed\`/\`unsupported\` 목록을 세션 보고에 포함"
    echo "- Note: 이 스크립트는 MCP toolset enable을 직접 실행하지 않고 가이드만 출력"
  else
    echo "- Execution Status: \`BLOCKED\`"
    echo "- Action Guide: \`~/.codex/config.toml\`에 \`[mcp_servers.github]\` 등록 후 세션 재시작"
  fi
  echo
  echo "## How It Works"
  echo "1. 전역 규칙은 \`AGENTS.md\` + \`skills/*/SKILL.md\`에서 로드"
  echo "2. 프로젝트 컨텍스트는 Active Project의 \`README.md\` + \`prj-docs/PROJECT_AGENT.md\` + \`prj-docs/meeting-notes/README.md\`에서 로드"
  echo "3. 멀티 프로젝트에서는 Active Project를 명시적으로 전환해서 충돌 방지"
  echo
  echo "## Multi Project Guide"
  echo "1. 프로젝트 목록 확인: \`$set_active_entry --list\`"
  echo "2. 활성 프로젝트 지정: \`$set_active_entry <project-root>\`"
  echo "3. 지정 후 \`$reload_entry\` 재실행"
  echo
  echo "## Quick Remind"
  echo "- 시작 문구: \`AGENTS.md만 읽고 시작해.\`"
  echo "- 세션 상태 문서: \`.codex/runtime/codex_session_start.md\`"
  echo "- 재시작 핸드오프: \`mcp/runtime/SESSION_HANDOFF.md\` (있으면 우선 로드)"
  echo "- 임시 산출물 정책: \`.codex/tmp/<tool>/<run-id>/\` 경로 사용 (로그/대시보드/스크린샷)"
  echo "- 영구 증빙 정책: \`prj-docs/**\`에는 \`.md/.json\` 증빙만 유지"
  echo "- 문제 시 재동기화: \`$reload_entry\`"
  echo
  echo "## Usage"
  echo "1. 세션 시작 시 \`$reload_entry\` 실행"
  echo "2. \`.codex/runtime/codex_session_start.md\` 기준으로 세션 첫 상태를 보고"
} > "$session_snapshot"

echo "updated: ${session_snapshot#$repo_root/}"
echo "skills: ${#loaded_skills[@]} ($skills_status)"
echo "project: ${active_project:-none} ($project_status)"
