#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi
workspace_dir="$repo_root/workspace"
active_file="$workspace_dir/.active_project"
runtime_dir="$repo_root/.codex/runtime"
output_file="$runtime_dir/codex_project_reload.md"
project_map_file="$repo_root/prj-docs/projects/project-map.yaml"

version="$(date +%Y%m%d-%H%M%S)"
updated_at="$(date '+%Y-%m-%d %H:%M:%S')"

if [[ ! -d "$workspace_dir" ]]; then
  echo "error: workspace directory not found: $workspace_dir" >&2
  exit 1
fi
mkdir -p "$runtime_dir"

strip_quotes() {
  local value="$1"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s' "$value"
}

declare -A map_project_id_by_code=()
declare -A map_docs_root_by_code=()
load_project_map() {
  [[ -f "$project_map_file" ]] || return 0

  local current_id=""
  local current_code=""
  local current_docs=""
  local raw_line=""
  local line=""
  local parsed=""
  while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
    line="${raw_line#"${raw_line%%[![:space:]]*}"}"
    case "$line" in
      -\ project_id:*)
        if [[ -n "$current_code" ]]; then
          map_project_id_by_code["$current_code"]="$current_id"
          map_docs_root_by_code["$current_code"]="${current_docs:-$current_code/prj-docs}"
        fi
        parsed="${line#- project_id:}"
        parsed="$(strip_quotes "$parsed")"
        current_id="$(echo "$parsed" | xargs)"
        current_code=""
        current_docs=""
        ;;
      code_root:*)
        parsed="${line#code_root:}"
        parsed="$(strip_quotes "$parsed")"
        current_code="$(echo "$parsed" | xargs)"
        ;;
      docs_root:*)
        parsed="${line#docs_root:}"
        parsed="$(strip_quotes "$parsed")"
        current_docs="$(echo "$parsed" | xargs)"
        ;;
    esac
  done < "$project_map_file"

  if [[ -n "$current_code" ]]; then
    map_project_id_by_code["$current_code"]="$current_id"
    map_docs_root_by_code["$current_code"]="${current_docs:-$current_code/prj-docs}"
  fi
}

load_project_map

declare -A project_task_by_root=()
declare -A project_docs_root_by_root=()
declare -A project_source_by_root=()

register_project() {
  local root_rel="$1"
  local docs_root_rel="$2"
  local task_rel="$3"
  local source_tag="$4"
  if [[ -z "$root_rel" || -z "$docs_root_rel" ]]; then
    return 0
  fi
  project_docs_root_by_root["$root_rel"]="$docs_root_rel"
  if [[ -n "$task_rel" ]]; then
    project_task_by_root["$root_rel"]="$task_rel"
  fi
  if [[ -n "${project_source_by_root[$root_rel]:-}" ]]; then
    if [[ "${project_source_by_root[$root_rel]}" != *"$source_tag"* ]]; then
      project_source_by_root["$root_rel"]="${project_source_by_root[$root_rel]},$source_tag"
    fi
  else
    project_source_by_root["$root_rel"]="$source_tag"
  fi
}

mapfile -t legacy_task_files < <(find "$workspace_dir" -type f -path "*/prj-docs/task.md" 2>/dev/null | sort || true)
for task_file in "${legacy_task_files[@]}"; do
  task_rel="${task_file#$repo_root/}"
  root_rel="$(dirname "$(dirname "$task_rel")")"
  docs_rel="$root_rel/prj-docs"
  register_project "$root_rel" "$docs_rel" "$task_rel" "legacy"
done

for code_root in "${!map_docs_root_by_code[@]}"; do
  docs_rel="${map_docs_root_by_code[$code_root]}"
  task_rel=""
  if [[ -f "$repo_root/$docs_rel/task.md" ]]; then
    task_rel="$docs_rel/task.md"
  fi
  register_project "$code_root" "$docs_rel" "$task_rel" "map"
done

declare -a project_roots=()
for root_rel in "${!project_docs_root_by_root[@]}"; do
  task_rel="${project_task_by_root[$root_rel]:-}"
  if [[ -n "$task_rel" ]]; then
    project_roots+=("$root_rel")
  fi
done
if [[ "${#project_roots[@]}" -gt 0 ]]; then
  mapfile -t project_roots < <(printf '%s\n' "${project_roots[@]}" | sort -u)
fi
project_count="${#project_roots[@]}"

resolve_docs_root_for_project() {
  local root_rel="$1"
  if [[ -n "${project_docs_root_by_root[$root_rel]:-}" ]]; then
    printf '%s\n' "${project_docs_root_by_root[$root_rel]}"
  else
    printf '%s\n' "$root_rel/prj-docs"
  fi
}

active_project=""
if [[ -f "$active_file" ]]; then
  active_project="$(head -n 1 "$active_file" | tr -d '\r' | xargs)"
fi
active_project="${active_project%/}"
if [[ "$active_project" == "$repo_root"* ]]; then
  active_project="${active_project#$repo_root/}"
fi

# Auto-select when only one project exists and no active target is set.
if [[ -z "$active_project" && "$project_count" -eq 1 ]]; then
  active_project="${project_roots[0]}"
  printf '%s\n' "$active_project" > "$active_file"
fi

active_task=""
active_agent=""
active_readme=""
active_meeting_notes=""
active_docs_root=""
declare -a active_missing=()
active_is_valid="false"
if [[ -n "$active_project" ]]; then
  active_abs="$repo_root/$active_project"
  docs_root_rel="$(resolve_docs_root_for_project "$active_project")"
  docs_abs="$repo_root/$docs_root_rel"
  candidate_readme="$active_abs/README.md"
  candidate_task="$docs_abs/task.md"
  candidate_agent="$docs_abs/PROJECT_AGENT.md"
  candidate_meeting_notes="$docs_abs/meeting-notes/README.md"
  candidate_rules_dir="$docs_abs/rules"

  if [[ ! -f "$candidate_task" ]]; then
    active_missing+=("${candidate_task#$repo_root/}")
  fi
  if [[ ! -f "$candidate_agent" ]]; then
    active_missing+=("${candidate_agent#$repo_root/}")
  fi
  if [[ ! -f "$candidate_meeting_notes" ]]; then
    active_missing+=("${candidate_meeting_notes#$repo_root/}")
  fi
  if [[ ! -d "$candidate_rules_dir" ]]; then
    active_missing+=("${candidate_rules_dir#$repo_root/}/")
  fi

  if [[ "${#active_missing[@]}" -eq 0 ]]; then
    active_is_valid="true"
    active_docs_root="$docs_root_rel"
    if [[ -f "$candidate_readme" ]]; then
      active_readme="${candidate_readme#$repo_root/}"
    else
      active_readme="(optional missing: ${candidate_readme#$repo_root/})"
    fi
    active_task="${candidate_task#$repo_root/}"
    active_agent="${candidate_agent#$repo_root/}"
    active_meeting_notes="${candidate_meeting_notes#$repo_root/}"
  fi
fi

{
  echo "# Codex Project Reload"
  echo
  echo "- Version: \`$version\`"
  echo "- Updated At: \`$updated_at\`"
  echo "- Generated By: \`skills/aki-codex-session-reload/scripts/codex_skills_reload/project_reload.sh\`"
  echo
  echo "## Active Project"
  if [[ "$active_is_valid" == "true" ]]; then
    echo "- Project Root: \`$active_project\`"
    echo "- Docs Root: \`$active_docs_root\`"
    echo "- Project README: \`$active_readme\`"
    echo "- Task Doc: \`$active_task\`"
    echo "- Project Agent: \`$active_agent\`"
    echo "- Meeting Notes: \`$active_meeting_notes\`"
  else
    echo "- Project Root: \`(not selected)\`"
    if [[ -n "$active_project" && "${#active_missing[@]}" -gt 0 ]]; then
      echo "- Reason: active project is missing baseline files/directories"
      local_missing_idx=1
      for missing_item in "${active_missing[@]}"; do
        echo "  $local_missing_idx) \`$missing_item\`"
        local_missing_idx=$((local_missing_idx + 1))
      done
      echo "- Action: \`./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh $active_project\`"
    elif [[ "$project_count" -gt 1 ]]; then
      echo "- Reason: multiple projects detected. run \`./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>\`"
    elif [[ "$project_count" -eq 0 ]]; then
      echo "- Reason: no task docs detected (legacy \`workspace/**/prj-docs/task.md\` or \`prj-docs/projects/project-map.yaml\`)"
    else
      echo "- Reason: invalid active project path. run \`./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>\`"
    fi
  fi
  echo
  echo "## Detected Projects"
  if [[ "$project_count" -eq 0 ]]; then
    echo "1. \`(none)\`"
  else
    idx=1
    for project_rel in "${project_roots[@]}"; do
      task_rel="${project_task_by_root[$project_rel]:-}"
      docs_rel="$(resolve_docs_root_for_project "$project_rel")"
      source_rel="${project_source_by_root[$project_rel]:-legacy}"
      marker=""
      if [[ "$project_rel" == "$active_project" && "$active_is_valid" == "true" ]]; then
        marker=" [ACTIVE]"
      fi
      echo "$idx. \`$project_rel\`$marker"
      [[ -n "$task_rel" ]] && echo "   - task: \`$task_rel\`"
      echo "   - docs_root: \`$docs_rel\`"
      echo "   - source: \`$source_rel\`"
      idx=$((idx + 1))
    done
  fi
  echo
  echo "## Usage"
  echo "1. 기본 리로드는 \`./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh\` 사용 (권장)"
  echo "2. 신규/다중 프로젝트면 \`./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>\` 실행"
  echo "3. 이 문서를 읽고 Active Project의 \`README.md(optional)\` + \`PROJECT_AGENT.md\` + \`task.md\` + \`meeting-notes/README.md\`를 로드 (Docs Root 기준)"
} > "$output_file"

echo "updated: $output_file"
echo "project_count: $project_count"
