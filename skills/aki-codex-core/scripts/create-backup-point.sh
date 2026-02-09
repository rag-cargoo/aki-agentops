#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  create-backup-point.sh [label] [--push]
  create-backup-point.sh --label <label> [--push]

Options:
  --label, -l   Backup label text (default: stable)
  --push        Push created branch and tag to origin
  --help, -h    Show this help

Examples:
  ./skills/aki-codex-core/scripts/create-backup-point.sh
  ./skills/aki-codex-core/scripts/create-backup-point.sh pre-pages-check
  ./skills/aki-codex-core/scripts/create-backup-point.sh --label pre-hotfix --push
EOF
}

label="stable"
push_to_origin="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --label|-l)
      if [[ $# -lt 2 ]]; then
        echo "error: --label requires a value" >&2
        exit 1
      fi
      label="$2"
      shift 2
      ;;
    --push)
      push_to_origin="true"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      label="$1"
      shift
      ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: run this inside a git repository" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

normalized_label="$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"
if [[ -z "$normalized_label" ]]; then
  normalized_label="stable"
fi

stamp="$(date +%Y%m%d-%H%M%S)"
short_head="$(git rev-parse --short HEAD)"

backup_branch="backup/${stamp}-${normalized_label}-${short_head}"
backup_tag="stable-${stamp}-${normalized_label}-${short_head}"

if git show-ref --verify --quiet "refs/heads/$backup_branch"; then
  echo "error: backup branch already exists: $backup_branch" >&2
  exit 1
fi

if git rev-parse --verify --quiet "refs/tags/$backup_tag" >/dev/null; then
  echo "error: backup tag already exists: $backup_tag" >&2
  exit 1
fi

git branch "$backup_branch"
git tag -a "$backup_tag" -m "stable backup point ${short_head} (${stamp}, ${normalized_label})"

echo "created branch: $backup_branch"
echo "created tag:    $backup_tag"
echo "points to:      $(git rev-parse --short HEAD)"

if [[ "$push_to_origin" == "true" ]]; then
  git push origin "$backup_branch" "$backup_tag"
  echo "pushed to origin"
fi

cat <<EOF

restore command:
  git switch main
  git reset --hard $backup_tag
  git push --force-with-lease origin main
EOF
