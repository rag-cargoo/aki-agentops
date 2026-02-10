#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

refs_dir="skills/aki-codex-workflows/references"
if [[ ! -d "$refs_dir" ]]; then
  echo "[owner-skill-lint] missing references dir: $refs_dir" >&2
  exit 1
fi

declare -A known_skills=()
while IFS= read -r skill_dir; do
  known_skills["$skill_dir"]="1"
done < <(find skills -maxdepth 1 -type d -name 'aki-*' -printf '%f\n' | sort)

status=0

while IFS= read -r -d '' file_path; do
  line_no=0
  owner_count=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))
    [[ "$line" == *"Owner Skill:"* ]] || continue
    owner_count=$((owner_count + 1))

    while IFS= read -r token; do
      skill_name="${token#\`}"
      skill_name="${skill_name%\`}"
      [[ "$skill_name" == aki-* ]] || continue
      if [[ -z "${known_skills[$skill_name]:-}" ]]; then
        echo "[owner-skill-lint] unknown skill: $skill_name ($file_path:$line_no)" >&2
        status=1
      fi
    done < <(printf '%s\n' "$line" | grep -oE '\`[^`]+\`' || true)
  done < "$file_path"

  if [[ "$owner_count" -eq 0 ]]; then
    echo "[owner-skill-lint] missing Owner Skill entry: $file_path" >&2
    status=1
  fi
done < <(find "$refs_dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

echo "[owner-skill-lint] check passed"
