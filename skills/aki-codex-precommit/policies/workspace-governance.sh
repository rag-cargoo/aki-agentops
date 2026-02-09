#!/usr/bin/env bash

POLICY_ID="workspace-governance"
POLICY_ROOTS=(
  "AGENTS.md"
  "HOME.md"
  "README.md"
  "index.html"
  ".githooks"
  "skills"
  "sidebar-manifest.md"
  "mcp"
  ".github"
)

policy_validate() {
  local mode="$1"
  local staged_files="$2"

  local has_skill_changes="false"
  local file_path
  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    if [[ "$file_path" == skills/* ]]; then
      has_skill_changes="true"
      break
    fi
  done <<< "$staged_files"

  if [[ "$has_skill_changes" == "true" ]]; then
    echo "[chain-check][${POLICY_ID}] checking skill naming policy"
    bash skills/aki-codex-core/scripts/check-skill-naming.sh
  fi

  if [[ "$mode" != "strict" ]]; then
    echo "[chain-check][${POLICY_ID}] quick mode: deep checks skipped"
    return 0
  fi

  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue

    if [[ "$file_path" == ".githooks/"* ]]; then
      if [[ -f "$file_path" ]]; then
        bash -n "$file_path"
      fi
      continue
    fi

    if [[ "$file_path" == skills/*".sh" ]]; then
      if [[ -f "$file_path" ]]; then
        bash -n "$file_path"
      fi
      continue
    fi

    if [[ "$file_path" == "mcp/manifest/"*".sh" ]]; then
      if [[ -f "$file_path" ]]; then
        bash -n "$file_path"
      fi
      continue
    fi
  done <<< "$staged_files"

  local requires_reload="false"
  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    if [[ "$file_path" == "AGENTS.md" ]]; then
      requires_reload="true"
      break
    fi
    if [[ "$file_path" == skills/* ]]; then
      requires_reload="true"
      break
    fi
    if [[ "$file_path" =~ ^workspace/.+/prj-docs/PROJECT_AGENT\.md$ ]]; then
      requires_reload="true"
      break
    fi
  done <<< "$staged_files"

  if [[ "$requires_reload" == "true" ]]; then
    echo "[chain-check][${POLICY_ID}] strict mode: running codex skills reload validation"
    bash -n skills/bin/codex_skills_reload/*.sh
    ./skills/bin/codex_skills_reload/session_start.sh >/dev/null
  fi

  echo "[chain-check][${POLICY_ID}] validation ok (strict)"
}
