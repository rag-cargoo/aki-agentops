#!/usr/bin/env bash
set -euo pipefail

POLICY_ID="core-workspace"
POLICY_ROOTS=(
  "AGENTS.md"
  "HOME.md"
  "README.md"
  ".gitignore"
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

  local has_managed_md_changes="false"
  local managed_docs=()
  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    [[ "$file_path" != *.md ]] && continue
    [[ ! -f "$file_path" ]] && continue
    if grep -qE "DOC_META_START|DOC_TOC_START" "$file_path"; then
      has_managed_md_changes="true"
      managed_docs+=("$file_path")
    fi
  done <<< "$staged_files"

  if [[ "$has_managed_md_changes" == "true" ]]; then
    echo "[chain-check][${POLICY_ID}] running docsify validation"
    python3 skills/aki-github-pages-expert/scripts/docsify_validator.py "${managed_docs[@]}"
  fi

  local has_workflow_ref_changes="false"
  while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue
    if [[ "$file_path" == "skills/aki-codex-workflows/references/"*".md" ]]; then
      has_workflow_ref_changes="true"
      break
    fi
  done <<< "$staged_files"

  if [[ "$has_workflow_ref_changes" == "true" ]]; then
    echo "[chain-check][${POLICY_ID}] checking workflow Owner Skill links"
    bash skills/aki-codex-workflows/scripts/check-owner-skill-links.sh
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
    bash -n skills/aki-codex-session-reload/scripts/codex_skills_reload/*.sh
    ./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh >/dev/null
  fi

  echo "[chain-check][${POLICY_ID}] validation ok (strict)"
}
