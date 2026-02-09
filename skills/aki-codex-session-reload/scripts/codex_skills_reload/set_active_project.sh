#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../.." && pwd)"
fi
workspace_dir="$repo_root/workspace"
active_file="$workspace_dir/.active_project"

usage() {
  cat <<'EOF'
Usage:
  ./skills/bin/codex_skills_reload/set_active_project.sh <project-root>
  ./skills/bin/codex_skills_reload/set_active_project.sh --list

Examples:
  ./skills/bin/codex_skills_reload/set_active_project.sh workspace/<category>/<project>
  ./skills/bin/codex_skills_reload/set_active_project.sh --list
EOF
}

list_projects() {
  mapfile -t task_files < <(find "$workspace_dir" -type f -path "*/prj-docs/task.md" 2>/dev/null | sort || true)
  if [[ "${#task_files[@]}" -eq 0 ]]; then
    echo "no projects found under workspace"
    return 0
  fi
  echo "detected projects:"
  for task_file in "${task_files[@]}"; do
    project_root="$(dirname "$(dirname "$task_file")")"
    echo "- ${project_root#$repo_root/}"
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
required_files=(
  "$project_abs/README.md"
  "$project_abs/prj-docs/PROJECT_AGENT.md"
  "$project_abs/prj-docs/task.md"
  "$project_abs/prj-docs/meeting-notes/README.md"
)
required_dirs=(
  "$project_abs/prj-docs/rules"
)

if [[ ! -d "$project_abs" ]]; then
  echo "error: project root not found: $input_path" >&2
  exit 1
fi

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
  echo "hint: run ./skills/bin/codex_skills_reload/init_project_docs.sh $input_path" >&2
  exit 1
fi

printf '%s\n' "$input_path" > "$active_file"
echo "active project set: $input_path"

"$script_dir/project_reload.sh"
