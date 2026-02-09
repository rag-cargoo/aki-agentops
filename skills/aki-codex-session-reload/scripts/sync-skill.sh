#!/usr/bin/env bash
set -euo pipefail

# Link local skills/* directories into the runtime skill folder.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../.." && pwd)"
fi
source_root="$repo_root/skills"
target_root="${TARGET_ROOT:-$repo_root/.gemini/skills}"

echo ">>>> skill link start"
echo "source: $source_root"
echo "target: $target_root"

mkdir -p "$target_root"

while IFS= read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  target_path="$target_root/$skill_name"

  rm -rf "$target_path"
  ln -s "$skill_dir" "$target_path"
  echo "  - linked: $skill_name"
done < <(find "$source_root" -mindepth 2 -maxdepth 2 -type f -name "SKILL.md" | sort)

echo ">>>> success"
