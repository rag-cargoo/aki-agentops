#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../../.." && pwd)"
fi

template_file="$repo_root/skills/workspace-governance/references/templates/PROJECT_AGENT_TEMPLATE.md"

usage() {
  cat <<'EOF'
Usage:
  ./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh <project-root> [options]

Options:
  --service-name <name>   Override default service name (basename of project-root)
  --force                 Overwrite existing files
  --dry-run               Print planned changes without writing files
  -h, --help              Show this help

Examples:
  ./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh workspace/agent-skills/codex-runtime-engine
  ./skills/aki-codex-session-reload/scripts/codex_skills_reload/init_project_docs.sh workspace/agent-skills/codex-runtime-engine --service-name "Codex Runtime Engine" --force
EOF
}

target_path=""
service_name=""
force="false"
dry_run="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --service-name)
      if [[ $# -lt 2 ]]; then
        echo "error: --service-name requires a value" >&2
        exit 1
      fi
      service_name="$2"
      shift 2
      ;;
    --force)
      force="true"
      shift
      ;;
    --dry-run)
      dry_run="true"
      shift
      ;;
    --*)
      echo "error: unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -n "$target_path" ]]; then
        echo "error: multiple project paths provided" >&2
        usage
        exit 1
      fi
      target_path="${1%/}"
      shift
      ;;
  esac
done

if [[ -z "$target_path" ]]; then
  usage
  exit 1
fi

if [[ "$target_path" == "$repo_root"* ]]; then
  target_path="${target_path#$repo_root/}"
fi

if [[ ! "$target_path" =~ ^workspace/[^[:space:]]+$ ]]; then
  echo "error: project-root must be under workspace/: $target_path" >&2
  exit 1
fi

project_abs="$repo_root/$target_path"
project_base="$(basename "$target_path")"
if [[ -z "$service_name" ]]; then
  service_name="$project_base"
fi

if [[ ! -f "$template_file" ]]; then
  echo "error: template not found: ${template_file#$repo_root/}" >&2
  exit 1
fi

declare -a changed=()
declare -a skipped=()

ensure_dir() {
  local dir_path="$1"
  local rel_path="${dir_path#$repo_root/}"
  if [[ -d "$dir_path" ]]; then
    return 0
  fi
  if [[ "$dry_run" == "true" ]]; then
    changed+=("$rel_path/ (mkdir)")
    return 0
  fi
  mkdir -p "$dir_path"
  changed+=("$rel_path/ (mkdir)")
}

write_file() {
  local file_path="$1"
  local content="$2"
  local rel_path="${file_path#$repo_root/}"
  if [[ -f "$file_path" && "$force" != "true" ]]; then
    skipped+=("$rel_path")
    return 0
  fi
  if [[ "$dry_run" == "true" ]]; then
    changed+=("$rel_path (write)")
    return 0
  fi
  mkdir -p "$(dirname "$file_path")"
  printf '%s\n' "$content" > "$file_path"
  changed+=("$rel_path (write)")
}

ensure_dir "$project_abs"
ensure_dir "$project_abs/prj-docs"
ensure_dir "$project_abs/prj-docs/rules"
ensure_dir "$project_abs/prj-docs/meeting-notes"
ensure_dir "$project_abs/prj-docs/knowledge"
ensure_dir "$project_abs/prj-docs/troubleshooting"

project_agent_content="$(cat "$template_file")"
project_agent_content="${project_agent_content//<Service Name>/$service_name}"
project_agent_content="${project_agent_content//<project-root>/$target_path}"

task_content="# Task Board ($service_name)

## Active Target
- Status: TODO
- Goal: define the first deliverable scope

## Notes
- Record implementation decisions in this document.
"

meeting_notes_index_content="# Meeting Notes ($service_name)

## Purpose
- Store official meeting notes for this project.
- Keep kickoff/decision/action logs in dated markdown files.

## Naming
- Use: YYYY-MM-DD-topic.md

## First Note
- Create the first note file before major design/implementation changes.

## Template
\`\`\`md
# Meeting Notes: <title>

## 안건 1: <주제>
- Created At: YYYY-MM-DD HH:MM:SS
- Updated At: YYYY-MM-DD HH:MM:SS
- Status: TODO | DOING | DONE
- 결정사항:
- 후속작업:
  - 담당:
  - 기한:
  - 상태: TODO | DOING | DONE

## 안건 2: <주제>
- Created At: YYYY-MM-DD HH:MM:SS
- Updated At: YYYY-MM-DD HH:MM:SS
- Status: TODO | DOING | DONE
- 결정사항:
- 후속작업:
  - 담당:
  - 기한:
  - 상태: TODO | DOING | DONE
\`\`\`
"

readme_content="# $service_name README

## Overview
- Status: TODO
- Summary: describe project purpose, scope, and boundaries.

## Run
- Add local run instructions for this project.

## Docs
- Project Agent: $target_path/prj-docs/PROJECT_AGENT.md
- Task Dashboard: $target_path/prj-docs/task.md
- Meeting Notes: $target_path/prj-docs/meeting-notes/README.md
"

write_file "$project_abs/README.md" "$readme_content"
write_file "$project_abs/prj-docs/PROJECT_AGENT.md" "$project_agent_content"
write_file "$project_abs/prj-docs/task.md" "$task_content"
write_file "$project_abs/prj-docs/meeting-notes/README.md" "$meeting_notes_index_content"
write_file "$project_abs/prj-docs/rules/.gitkeep" ""

echo "project-root: $target_path"
echo "service-name: $service_name"
echo "dry-run: $dry_run"
echo "force: $force"
echo
echo "changed:"
if [[ "${#changed[@]}" -eq 0 ]]; then
  echo "- (none)"
else
  for line in "${changed[@]}"; do
    echo "- $line"
  done
fi
echo
echo "skipped:"
if [[ "${#skipped[@]}" -eq 0 ]]; then
  echo "- (none)"
else
  for line in "${skipped[@]}"; do
    echo "- $line"
  done
fi
echo
echo "next:"
echo "- ./skills/aki-codex-session-reload/scripts/codex_skills_reload/set_active_project.sh $target_path"
echo "- ./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh"
