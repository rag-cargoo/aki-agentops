#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: run-skill-hooks.sh [--engine <path>]

Runs skill hooks declared in engine.yaml and writes a JSON report.

Options:
  --engine <path>  Engine config path (default: skills/aki-codex-session-reload/scripts/runtime_orchestrator/engine.yaml)
  -h, --help       Show help
EOF
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

strip_quotes() {
  local value
  value="$(trim "$1")"
  if [[ "${#value}" -ge 2 ]]; then
    local first_char="${value:0:1}"
    local last_char="${value: -1}"
    if [[ "$first_char" == "\"" && "$last_char" == "\"" ]]; then
      value="${value:1:${#value}-2}"
    elif [[ "$first_char" == "'" && "$last_char" == "'" ]]; then
      value="${value:1:${#value}-2}"
    fi
  fi
  printf '%s' "$value"
}

json_escape() {
  printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g'
}

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

epoch_ms() {
  local ms
  ms="$(date +%s%3N 2>/dev/null || true)"
  if [[ -n "$ms" ]]; then
    printf '%s' "$ms"
  else
    printf '%s' "$(( $(date +%s) * 1000 ))"
  fi
}

engine_path="skills/aki-codex-session-reload/scripts/runtime_orchestrator/engine.yaml"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine)
      if [[ $# -lt 2 ]]; then
        echo "[skill-hooks] --engine requires a path" >&2
        usage
        exit 1
      fi
      engine_path="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[skill-hooks] unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ ! -f "$engine_path" ]]; then
  echo "[skill-hooks] engine file not found: $engine_path" >&2
  exit 1
fi

engine_version="$(awk '/^[[:space:]]*version:[[:space:]]*/ {sub(/^[[:space:]]*version:[[:space:]]*/, "", $0); print $0; exit}' "$engine_path")"
engine_version="$(strip_quotes "${engine_version:-}")"
if [[ -z "$engine_version" ]]; then
  echo "[skill-hooks] invalid engine: missing version in $engine_path" >&2
  exit 1
fi
if [[ "$engine_version" != "1" ]]; then
  echo "[skill-hooks] unsupported engine version: $engine_version (expected: 1)" >&2
  exit 1
fi

report_output="$(awk '
  /^[[:space:]]*report:[[:space:]]*$/ {in_report=1; next}
  in_report && /^[[:space:]]*hooks:[[:space:]]*$/ {in_report=0}
  in_report && /^[[:space:]]*output:[[:space:]]*/ {
    sub(/^[[:space:]]*output:[[:space:]]*/, "", $0)
    print $0
    exit
  }
' "$engine_path")"

report_output="$(strip_quotes "${report_output:-}")"
if [[ -z "$report_output" ]]; then
  report_output=".codex/runtime/skill-hooks-report.json"
fi

declare -a hook_ids=()
declare -a hook_commands=()
declare -a hook_fail_modes=()

current_id=""
current_command=""
current_fail_mode="fail_fast"

flush_hook() {
  if [[ -z "$current_id" ]]; then
    return
  fi

  if [[ -z "$current_command" ]]; then
    echo "[skill-hooks] invalid engine: hook '$current_id' missing run command in $engine_path" >&2
    exit 1
  fi

  hook_ids+=("$current_id")
  hook_commands+=("$current_command")
  hook_fail_modes+=("$current_fail_mode")

  current_id=""
  current_command=""
  current_fail_mode="fail_fast"
}

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[[:space:]]*-[[:space:]]id:[[:space:]]*(.+)$ ]]; then
    flush_hook
    current_id="$(strip_quotes "${BASH_REMATCH[1]}")"
    continue
  fi

  if [[ -n "$current_id" && "$line" =~ ^[[:space:]]*run:[[:space:]]*(.+)$ ]]; then
    current_command="$(strip_quotes "${BASH_REMATCH[1]}")"
    continue
  fi

  if [[ -n "$current_id" && "$line" =~ ^[[:space:]]*on_fail:[[:space:]]*(.+)$ ]]; then
    current_fail_mode="$(strip_quotes "${BASH_REMATCH[1]}")"
    continue
  fi
done < "$engine_path"

flush_hook

hook_count="${#hook_ids[@]}"
if [[ "$hook_count" -eq 0 ]]; then
  echo "[skill-hooks] invalid engine: no hooks found in $engine_path" >&2
  exit 1
fi

for idx in "${!hook_fail_modes[@]}"; do
  case "${hook_fail_modes[$idx]}" in
    fail_fast|continue) ;;
    *)
      echo "[skill-hooks] invalid on_fail value '${hook_fail_modes[$idx]}' in hook '${hook_ids[$idx]}'" >&2
      echo "[skill-hooks] allowed values: fail_fast, continue" >&2
      exit 1
      ;;
  esac
done

declare -a hook_status=()
declare -a hook_exit_codes=()
declare -a hook_started_at=()
declare -a hook_finished_at=()
declare -a hook_duration_ms=()

for _ in "${hook_ids[@]}"; do
  hook_status+=("pending")
  hook_exit_codes+=("null")
  hook_started_at+=("")
  hook_finished_at+=("")
  hook_duration_ms+=(0)
done

run_started_ms="$(epoch_ms)"

for idx in "${!hook_ids[@]}"; do
  hook_id="${hook_ids[$idx]}"
  hook_command="${hook_commands[$idx]}"
  hook_fail_mode="${hook_fail_modes[$idx]}"

  hook_started_at[$idx]="$(timestamp_utc)"
  hook_step_started_ms="$(epoch_ms)"

  echo "[skill-hooks] hook $((idx + 1))/$hook_count: $hook_id"
  echo "[skill-hooks] run: $hook_command"

  set +e
  bash -lc "$hook_command"
  exit_code=$?
  set -e

  hook_finished_at[$idx]="$(timestamp_utc)"
  hook_duration_ms[$idx]=$(( $(epoch_ms) - hook_step_started_ms ))
  hook_exit_codes[$idx]="$exit_code"

  if [[ "$exit_code" -eq 0 ]]; then
    hook_status[$idx]="passed"
    continue
  fi

  hook_status[$idx]="failed"
  echo "[skill-hooks] hook failed: $hook_id (exit=$exit_code, on_fail=$hook_fail_mode)" >&2

  if [[ "$hook_fail_mode" == "fail_fast" ]]; then
    for skip_idx in "${!hook_ids[@]}"; do
      if [[ "$skip_idx" -gt "$idx" && "${hook_status[$skip_idx]}" == "pending" ]]; then
        hook_status[$skip_idx]="skipped"
      fi
    done
    break
  fi
done

passed_count=0
failed_count=0
skipped_count=0
for status in "${hook_status[@]}"; do
  case "$status" in
    passed) passed_count=$((passed_count + 1)) ;;
    failed) failed_count=$((failed_count + 1)) ;;
    skipped) skipped_count=$((skipped_count + 1)) ;;
  esac
done

total_duration_ms=$(( $(epoch_ms) - run_started_ms ))

write_report() {
  local output_path="$1"
  local output_dir
  output_dir="$(dirname "$output_path")"
  mkdir -p "$output_dir"

  {
    echo "{"
    printf '  "engine_path": "%s",\n' "$(json_escape "$engine_path")"
    printf '  "generated_at": "%s",\n' "$(timestamp_utc)"
    echo '  "summary": {'
    printf '    "total": %d,\n' "$hook_count"
    printf '    "passed": %d,\n' "$passed_count"
    printf '    "failed": %d,\n' "$failed_count"
    printf '    "skipped": %d,\n' "$skipped_count"
    printf '    "duration_ms": %d\n' "$total_duration_ms"
    echo '  },'
    echo '  "hooks": ['

    for idx in "${!hook_ids[@]}"; do
      echo "    {"
      printf '      "id": "%s",\n' "$(json_escape "${hook_ids[$idx]}")"
      printf '      "run": "%s",\n' "$(json_escape "${hook_commands[$idx]}")"
      printf '      "on_fail": "%s",\n' "$(json_escape "${hook_fail_modes[$idx]}")"
      printf '      "status": "%s",\n' "$(json_escape "${hook_status[$idx]}")"

      if [[ "${hook_exit_codes[$idx]}" == "null" ]]; then
        echo '      "exit_code": null,'
      else
        printf '      "exit_code": %d,\n' "${hook_exit_codes[$idx]}"
      fi

      if [[ -z "${hook_started_at[$idx]}" ]]; then
        echo '      "started_at": null,'
      else
        printf '      "started_at": "%s",\n' "$(json_escape "${hook_started_at[$idx]}")"
      fi

      if [[ -z "${hook_finished_at[$idx]}" ]]; then
        echo '      "finished_at": null,'
      else
        printf '      "finished_at": "%s",\n' "$(json_escape "${hook_finished_at[$idx]}")"
      fi

      printf '      "duration_ms": %d\n' "${hook_duration_ms[$idx]}"
      if [[ "$idx" -eq $((hook_count - 1)) ]]; then
        echo "    }"
      else
        echo "    },"
      fi
    done

    echo '  ]'
    echo "}"
  } > "$output_path"
}

write_report "$report_output"

echo "[skill-hooks] report written: $report_output"
if [[ "$failed_count" -gt 0 ]]; then
  echo "[skill-hooks] completed with failures" >&2
  exit 1
fi

echo "[skill-hooks] all hooks passed"
