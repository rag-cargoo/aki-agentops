#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

declare -a allowed_names=(
  "java-spring-boot"
  "find-skills"
  "skill-creator"
  "skill-installer"
)

if [[ -n "${SKILL_NAMING_ALLOW:-}" ]]; then
  IFS=',' read -r -a extra_allowed <<< "${SKILL_NAMING_ALLOW}"
  for name in "${extra_allowed[@]}"; do
    trimmed="$(echo "$name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$trimmed" ]] && continue
    allowed_names+=("$trimmed")
  done
fi

is_allowed_name() {
  local skill_name="$1"
  local item
  for item in "${allowed_names[@]}"; do
    if [[ "$skill_name" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

mapfile -t skill_files < <(find skills -mindepth 2 -maxdepth 2 -type f -name "SKILL.md" | sort)
if [[ "${#skill_files[@]}" -eq 0 ]]; then
  echo "[skill-naming] no local skill files found"
  exit 0
fi

violations=()
for skill_file in "${skill_files[@]}"; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"

  if [[ "$skill_name" == aki-* ]]; then
    continue
  fi

  if is_allowed_name "$skill_name"; then
    continue
  fi

  violations+=("$skill_name")
done

if [[ "${#violations[@]}" -gt 0 ]]; then
  echo "[skill-naming] invalid skill names detected (missing aki- prefix):"
  for item in "${violations[@]}"; do
    echo "  - $item"
  done
  echo "[skill-naming] allowed exceptions: ${allowed_names[*]}"
  exit 1
fi

echo "[skill-naming] policy check passed"
