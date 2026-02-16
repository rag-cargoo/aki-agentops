#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi
workspace_dir="$repo_root/workspace"
active_file="$workspace_dir/.active_project"
project_map_file="$repo_root/prj-docs/projects/project-map.yaml"

strip_quotes() {
  local value="$1"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s' "$value"
}

declare -A map_docs_root_by_code=()
load_project_map() {
  [[ -f "$project_map_file" ]] || return 0

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
          map_docs_root_by_code["$current_code"]="${current_docs:-$current_code/prj-docs}"
        fi
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
    map_docs_root_by_code["$current_code"]="${current_docs:-$current_code/prj-docs}"
  fi
}

resolve_docs_root_for_project() {
  local project_rel="$1"
  if [[ -n "${map_docs_root_by_code[$project_rel]:-}" ]]; then
    printf '%s\n' "${map_docs_root_by_code[$project_rel]}"
  else
    printf '%s\n' "$project_rel/prj-docs"
  fi
}

load_project_map

usage() {
  cat <<'EOF'
Usage:
  ./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh <project-root>
  ./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh --list

Examples:
  ./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh workspace/<category>/<project>
  ./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh --list
EOF
}

list_projects() {
  declare -A project_roots=()
  local task_file=""
  local task_rel=""
  local project_root=""
  local code_root=""
  local docs_root_rel=""

  mapfile -t task_files < <(find "$workspace_dir" -type f -path "*/prj-docs/task.md" 2>/dev/null | sort || true)
  for task_file in "${task_files[@]}"; do
    task_rel="${task_file#$repo_root/}"
    project_root="$(dirname "$(dirname "$task_rel")")"
    project_roots["$project_root"]="1"
  done

  for code_root in "${!map_docs_root_by_code[@]}"; do
    docs_root_rel="$(resolve_docs_root_for_project "$code_root")"
    if [[ -f "$repo_root/$docs_root_rel/task.md" ]]; then
      project_roots["$code_root"]="1"
    fi
  done

  if [[ "${#project_roots[@]}" -eq 0 ]]; then
    echo "no projects found under workspace"
    return 0
  fi
  echo "detected projects:"
  mapfile -t sorted_roots < <(printf '%s\n' "${!project_roots[@]}" | sort)
  for project_root in "${sorted_roots[@]}"; do
    docs_root_rel="$(resolve_docs_root_for_project "$project_root")"
    echo "- $project_root (docs: $docs_root_rel)"
  done
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--list" || "${1:-}" == "-l" || $# -eq 0 ]]; then
  list_projects
  if [[ $# -eq 0 ]]; then
    echo
    usage
  fi
  exit 0
fi

input_path="${1%/}"
if [[ "$input_path" == "$repo_root"* ]]; then
  input_path="${input_path#$repo_root/}"
fi

project_abs="$repo_root/$input_path"
docs_root_rel="$(resolve_docs_root_for_project "$input_path")"
docs_abs="$repo_root/$docs_root_rel"
has_map_entry="false"
if [[ -n "${map_docs_root_by_code[$input_path]:-}" ]]; then
  has_map_entry="true"
fi

code_root_missing="false"
if [[ ! -d "$project_abs" ]]; then
  if [[ "$has_map_entry" == "true" ]]; then
    code_root_missing="true"
  else
    echo "error: project root not found: $input_path" >&2
    exit 1
  fi
fi

required_files=(
  "$docs_abs/PROJECT_AGENT.md"
  "$docs_abs/task.md"
  "$docs_abs/meeting-notes/README.md"
)
required_dirs=(
  "$docs_abs/rules"
)

missing=()
for req_file in "${required_files[@]}"; do
  if [[ ! -f "$req_file" ]]; then
    missing+=("${req_file#$repo_root/}")
  fi
done
for req_dir in "${required_dirs[@]}"; do
  if [[ ! -d "$req_dir" ]]; then
    missing+=("${req_dir#$repo_root/}/")
  fi
done

if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "error: project baseline requirements are missing:" >&2
  for item in "${missing[@]}"; do
    echo "  - $item" >&2
  done
  if [[ "$docs_root_rel" == "$input_path/prj-docs" ]]; then
    echo "hint: run ./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh $input_path" >&2
  else
    echo "hint: create baseline docs under $docs_root_rel (PROJECT_AGENT.md, task.md, meeting-notes/README.md, rules/)" >&2
  fi
  exit 1
fi

printf '%s\n' "$input_path" > "$active_file"
if [[ "$code_root_missing" == "true" ]]; then
  echo "active project set: $input_path (docs: $docs_root_rel)"
  echo "warning: code_root directory is missing; docs-only mode enabled for this project"
else
  echo "active project set: $input_path (docs: $docs_root_rel)"
fi

"$script_dir/project_reload.sh"
