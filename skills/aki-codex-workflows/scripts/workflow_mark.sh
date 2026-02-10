#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  workflow_mark.sh set --workflow <name> --status <status> [--source <id>] [--detail <text>]
  workflow_mark.sh get --workflow <name>
  workflow_mark.sh list
  workflow_mark.sh clear [--workflow <name>]
  workflow_mark.sh paths

Status values:
  PASS | FAIL | NOT_RUN | UNVERIFIED | WARN | BLOCKED | SKIP
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  repo_root="$(cd "$script_dir/../../.." && pwd)"
fi

state_dir="$repo_root/.codex/state"
marks_file="$state_dir/workflow_marks.tsv"

sanitize_text() {
  local raw="${1:-}"
  raw="${raw//$'\t'/ }"
  raw="${raw//$'\n'/ }"
  raw="${raw//$'\r'/ }"
  echo "$raw"
}

normalize_status() {
  local status="${1:-}"
  status="${status^^}"
  case "$status" in
    PASS|FAIL|NOT_RUN|UNVERIFIED|WARN|BLOCKED|SKIP) echo "$status" ;;
    *)
      echo "[workflow-mark] invalid status: $status" >&2
      exit 1
      ;;
  esac
}

validate_workflow_name() {
  local workflow_name="$1"
  if [[ ! "$workflow_name" =~ ^[a-z0-9_][a-z0-9_-]*$ ]]; then
    echo "[workflow-mark] invalid workflow name: $workflow_name" >&2
    exit 1
  fi
}

set_mark() {
  local workflow_name="$1"
  local status="$2"
  local source="$3"
  local detail="$4"
  local now_human=""
  local tmp_file=""
  local existing_workflow=""
  local existing_status=""
  local existing_updated=""
  local existing_source=""
  local existing_detail=""

  validate_workflow_name "$workflow_name"
  status="$(normalize_status "$status")"
  source="$(sanitize_text "$source")"
  detail="$(sanitize_text "$detail")"
  [[ -z "$source" ]] && source="manual"
  [[ -z "$detail" ]] && detail="none"
  now_human="$(date '+%Y-%m-%d %H:%M:%S')"

  mkdir -p "$state_dir"
  tmp_file="$(mktemp)"

  if [[ -f "$marks_file" ]]; then
    while IFS=$'\t' read -r existing_workflow existing_status existing_updated existing_source existing_detail || [[ -n "$existing_workflow" ]]; do
      [[ -z "$existing_workflow" ]] && continue
      [[ "$existing_workflow" == \#* ]] && continue
      if [[ "$existing_workflow" == "$workflow_name" ]]; then
        continue
      fi
      printf '%s\t%s\t%s\t%s\t%s\n' \
        "$existing_workflow" \
        "${existing_status:-UNVERIFIED}" \
        "${existing_updated:-unknown}" \
        "${existing_source:-manual}" \
        "${existing_detail:-none}" >> "$tmp_file"
    done < "$marks_file"
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$workflow_name" \
    "$status" \
    "$now_human" \
    "$source" \
    "$detail" >> "$tmp_file"

  mv "$tmp_file" "$marks_file"
  echo "[workflow-mark] set: $workflow_name -> $status ($source)"
}

get_mark() {
  local workflow_name="$1"
  local row=""
  validate_workflow_name "$workflow_name"
  if [[ ! -f "$marks_file" ]]; then
    echo "[workflow-mark] mark not found: $workflow_name" >&2
    exit 1
  fi
  row="$(awk -F'\t' -v w="$workflow_name" '$1==w {print; found=1} END {if (!found) exit 1}' "$marks_file" || true)"
  if [[ -z "$row" ]]; then
    echo "[workflow-mark] mark not found: $workflow_name" >&2
    exit 1
  fi
  IFS=$'\t' read -r workflow_name status updated_at source detail <<< "$row"
  printf '%-28s %-12s %-19s %-24s %s\n' "workflow" "status" "updated_at" "source" "detail"
  printf '%-28s %-12s %-19s %-24s %s\n' "----------------------------" "------------" "-------------------" "------------------------" "------------------------------"
  printf '%-28s %-12s %-19s %-24s %s\n' "$workflow_name" "$status" "$updated_at" "$source" "${detail:-none}"
}

list_marks() {
  local workflow_name=""
  local status=""
  local updated_at=""
  local source=""
  local detail=""

  printf '%-28s %-12s %-19s %-24s %s\n' "workflow" "status" "updated_at" "source" "detail"
  printf '%-28s %-12s %-19s %-24s %s\n' "----------------------------" "------------" "-------------------" "------------------------" "------------------------------"
  if [[ ! -f "$marks_file" ]]; then
    printf '%-28s %-12s %-19s %-24s %s\n' "none" "none" "none" "none" "none"
    return
  fi
  while IFS=$'\t' read -r workflow_name status updated_at source detail || [[ -n "$workflow_name" ]]; do
    [[ -z "$workflow_name" ]] && continue
    [[ "$workflow_name" == \#* ]] && continue
    printf '%-28s %-12s %-19s %-24s %s\n' \
      "$workflow_name" \
      "${status:-UNVERIFIED}" \
      "${updated_at:-unknown}" \
      "${source:-manual}" \
      "${detail:-none}"
  done < "$marks_file"
}

clear_marks() {
  local workflow_name="${1:-}"
  local tmp_file=""
  local existing_workflow=""
  local existing_status=""
  local existing_updated=""
  local existing_source=""
  local existing_detail=""

  mkdir -p "$state_dir"
  if [[ -z "$workflow_name" ]]; then
    : > "$marks_file"
    echo "[workflow-mark] cleared all marks"
    return
  fi

  validate_workflow_name "$workflow_name"
  tmp_file="$(mktemp)"
  if [[ -f "$marks_file" ]]; then
    while IFS=$'\t' read -r existing_workflow existing_status existing_updated existing_source existing_detail || [[ -n "$existing_workflow" ]]; do
      [[ -z "$existing_workflow" ]] && continue
      [[ "$existing_workflow" == \#* ]] && continue
      if [[ "$existing_workflow" == "$workflow_name" ]]; then
        continue
      fi
      printf '%s\t%s\t%s\t%s\t%s\n' \
        "$existing_workflow" \
        "${existing_status:-UNVERIFIED}" \
        "${existing_updated:-unknown}" \
        "${existing_source:-manual}" \
        "${existing_detail:-none}" >> "$tmp_file"
    done < "$marks_file"
  fi
  mv "$tmp_file" "$marks_file"
  echo "[workflow-mark] cleared: $workflow_name"
}

command="${1:-set}"
if [[ $# -gt 0 ]]; then
  shift
fi

case "$command" in
  set)
    workflow_name=""
    workflow_status=""
    workflow_source="manual"
    workflow_detail="none"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --workflow)
          workflow_name="${2:-}"
          shift 2
          ;;
        --status)
          workflow_status="${2:-}"
          shift 2
          ;;
        --source)
          workflow_source="${2:-}"
          shift 2
          ;;
        --detail)
          workflow_detail="${2:-}"
          shift 2
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          echo "[workflow-mark] unknown arg: $1" >&2
          usage
          exit 1
          ;;
      esac
    done
    if [[ -z "$workflow_name" || -z "$workflow_status" ]]; then
      echo "[workflow-mark] --workflow and --status are required for set" >&2
      usage
      exit 1
    fi
    set_mark "$workflow_name" "$workflow_status" "$workflow_source" "$workflow_detail"
    ;;
  get)
    workflow_name=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --workflow)
          workflow_name="${2:-}"
          shift 2
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          echo "[workflow-mark] unknown arg: $1" >&2
          usage
          exit 1
          ;;
      esac
    done
    if [[ -z "$workflow_name" ]]; then
      echo "[workflow-mark] --workflow is required for get" >&2
      usage
      exit 1
    fi
    get_mark "$workflow_name"
    ;;
  list)
    list_marks
    ;;
  clear)
    workflow_name=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --workflow)
          workflow_name="${2:-}"
          shift 2
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          echo "[workflow-mark] unknown arg: $1" >&2
          usage
          exit 1
          ;;
      esac
    done
    clear_marks "$workflow_name"
    ;;
  paths)
    echo "marks_file=${marks_file#$repo_root/}"
    ;;
  -h|--help)
    usage
    ;;
  *)
    echo "[workflow-mark] unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
