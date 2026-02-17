#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: check-target-surface-governance.sh [--scope staged|all]

Checks:
  1) Target/Surface metadata validation for markdown docs with DOC_META blocks
  2) Public sidebar exposure guard for AGENT-only document paths

Scope:
  staged (default): files from git diff --cached --name-only
  all:              files from git ls-files

Rules:
  - staged scope:
    - markdown files containing DOC_META_START must include both Target and Surface.
  - all scope:
    - if either Target or Surface exists, both must exist.
    - docs missing both fields are currently tolerated for gradual rollout.
  - enum validation:
    - Target: HUMAN | AGENT | BOTH | FUTURE:<group>
    - Surface: PUBLIC_NAV | AGENT_NAV | HIDDEN
  - conflict:
    - Target=AGENT and Surface=PUBLIC_NAV is invalid.
  - sidebar guard:
    - sidebar-manifest.md must not directly expose AGENT docs
      (/skills/*, /AGENTS.md, /workspace/agent-skills/*)
EOF
}

scope="staged"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)
      if [[ $# -lt 2 ]]; then
        echo "[target-surface] --scope requires a value" >&2
        usage
        exit 1
      fi
      scope="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[target-surface] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

case "$scope" in
  staged|all) ;;
  *)
    echo "[target-surface] invalid scope: $scope (allowed: staged, all)" >&2
    exit 1
    ;;
esac

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ "$scope" == "all" ]]; then
  files="$(git -c core.quotePath=false ls-files || true)"
else
  files="$(git -c core.quotePath=false diff --cached --name-only || true)"
fi

if [[ -z "$files" ]]; then
  echo "[target-surface] no files to check (scope=$scope)"
  exit 0
fi

extract_meta_value() {
  local file="$1"
  local field="$2"

  awk -v field="$field" '
    $0 ~ "^> - \\*\\*" field "\\*\\*:" {
      if (match($0, /`[^`]+`/)) {
        val=substr($0, RSTART+1, RLENGTH-2)
        print val
        exit
      }
    }
  ' "$file"
}

errors=()

while IFS= read -r file_path; do
  [[ -z "$file_path" ]] && continue
  [[ "$file_path" != *.md ]] && continue
  [[ ! -f "$file_path" ]] && continue

  if ! grep -q "DOC_META_START" "$file_path"; then
    continue
  fi

  target="$(extract_meta_value "$file_path" "Target" || true)"
  surface="$(extract_meta_value "$file_path" "Surface" || true)"

  if [[ -n "$target" && -z "$surface" ]]; then
    errors+=("$file_path: Surface is missing while Target is present")
    continue
  fi
  if [[ -z "$target" && -n "$surface" ]]; then
    errors+=("$file_path: Target is missing while Surface is present")
    continue
  fi

  if [[ "$scope" == "staged" ]]; then
    if [[ -z "$target" || -z "$surface" ]]; then
      errors+=("$file_path: staged DOC_META doc must include both Target and Surface")
      continue
    fi
  fi

  if [[ -n "$target" ]]; then
    if [[ ! "$target" =~ ^(HUMAN|AGENT|BOTH|FUTURE:[A-Za-z0-9._-]+)$ ]]; then
      errors+=("$file_path: invalid Target '$target'")
    fi
  fi

  if [[ -n "$surface" ]]; then
    if [[ ! "$surface" =~ ^(PUBLIC_NAV|AGENT_NAV|HIDDEN)$ ]]; then
      errors+=("$file_path: invalid Surface '$surface'")
    fi
  fi

  if [[ "$target" == "AGENT" && "$surface" == "PUBLIC_NAV" ]]; then
    errors+=("$file_path: Target=AGENT cannot use Surface=PUBLIC_NAV")
  fi
done <<< "$files"

if [[ -f "sidebar-manifest.md" ]]; then
  mapfile -t bad_public_links < <(grep -nE '\]\(/skills/|\]\(/AGENTS\.md\)|\]\(/workspace/agent-skills/' sidebar-manifest.md || true)
  if [[ "${#bad_public_links[@]}" -gt 0 ]]; then
    errors+=("sidebar-manifest.md: contains AGENT-only direct links")
    for line in "${bad_public_links[@]}"; do
      errors+=("sidebar-manifest.md:$line")
    done
  fi
fi

if [[ -f "index.html" ]]; then
  if ! grep -q "sidebar-agent-manifest.md" index.html; then
    errors+=("index.html: missing sidebar-agent-manifest.md routing")
  fi
fi

if [[ "${#errors[@]}" -gt 0 ]]; then
  echo "[target-surface] validation failed (scope=$scope)"
  for item in "${errors[@]}"; do
    echo "  - $item"
  done
  exit 1
fi

echo "[target-surface] validation ok (scope=$scope)"
