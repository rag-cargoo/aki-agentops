#!/usr/bin/env python3
"""Sync markdown metadata (Created/Updated) and top-level index blocks."""

from __future__ import annotations

import argparse
import datetime as dt
import re
import subprocess
from pathlib import Path

META_START = "<!-- DOC_META_START -->"
META_END = "<!-- DOC_META_END -->"
TOC_START = "<!-- DOC_TOC_START -->"
TOC_END = "<!-- DOC_TOC_END -->"

EXCLUDED_FILES = {
    "sidebar-manifest.md",
    "workspace/apps/backend/ticket-core-service/prj-docs/api-test/latest.md",
}
EXCLUDED_PREFIXES = (
    ".codex/runtime/",
    ".gemini/",
)


def run(cmd: list[str]) -> str:
    return subprocess.check_output(cmd, text=True)


def list_managed_markdown_files() -> list[str]:
    tracked = run(["git", "-c", "core.quotePath=false", "ls-files"]).splitlines()
    md_files = [p for p in tracked if p.endswith(".md")]
    return [p for p in md_files if not is_excluded(p)]


def is_excluded(path: str) -> bool:
    if path in EXCLUDED_FILES:
        return True
    return any(path.startswith(prefix) for prefix in EXCLUDED_PREFIXES)


def remove_marker_block(lines: list[str], start: str, end: str) -> list[str]:
    out: list[str] = []
    in_block = False
    for line in lines:
        if line.strip() == start:
            in_block = True
            continue
        if in_block and line.strip() == end:
            in_block = False
            continue
        if not in_block:
            out.append(line)
    return out


def extract_created_at(raw: str) -> str | None:
    match = re.search(r"\*\*Created At\*\*:\s*`([^`]+)`", raw)
    if not match:
        return None
    return match.group(1).strip()


STEP_PREFIX = r"Step\s*\d+(?:\s*[-~]\s*\d+)?"
HEADING_STEP_RE = re.compile(
    rf"^\s*(?:>\s*)?#{{2,6}}\s+({STEP_PREFIX}[^\n#]*)$",
    re.IGNORECASE,
)
BULLET_STEP_RE = re.compile(
    rf"^\s*(?:>\s*)?[-*]\s*(?:\[[ xX]\]\s*)?(?:\*\*)?({STEP_PREFIX}(?:\s*[:\-]\s*|\s*\().+)$",
    re.IGNORECASE,
)
LINK_WHOLE_RE = re.compile(r"^\[([^\]]+)\]\([^)]+\)$")
CODE_FENCE_RE = re.compile(r"^\s*(?:>\s*)?```")


def normalize_step_entry(raw_entry: str) -> str:
    entry = raw_entry.strip()
    link_match = LINK_WHOLE_RE.match(entry)
    if link_match:
        entry = link_match.group(1).strip()

    entry = entry.replace("**", "").replace("`", "")
    entry = re.sub(r"</?[^>]+>", "", entry)
    entry = re.sub(r"\s+", " ", entry).strip(" -")
    entry = entry.rstrip(".,;")
    if len(entry) > 160:
        entry = entry[:157].rstrip() + "..."
    return entry


def extract_step_key(entry: str) -> str | None:
    match = re.match(r"(?i)^Step\s*(\d+(?:\s*[-~]\s*\d+)?)", entry)
    if not match:
        return None
    key = re.sub(r"\s+", "", match.group(1))
    return key.lower()


def collect_step_entries(lines: list[str], pattern: re.Pattern[str]) -> list[str]:
    entries: list[str] = []
    seen_entries: set[str] = set()
    seen_step_keys: set[str] = set()
    in_code = False

    for line in lines:
        stripped = line.rstrip("\n")
        if CODE_FENCE_RE.match(stripped):
            in_code = not in_code
            continue
        if in_code:
            continue

        match = pattern.match(stripped)
        if not match:
            continue
        entry = normalize_step_entry(match.group(1))
        key = extract_step_key(entry) if entry else None
        if (
            entry
            and entry not in seen_entries
            and (key is None or key not in seen_step_keys)
        ):
            seen_entries.add(entry)
            if key is not None:
                seen_step_keys.add(key)
            entries.append(entry)

    return entries


def extract_step_entries(lines: list[str]) -> list[str]:
    heading_entries = collect_step_entries(lines, HEADING_STEP_RE)
    if heading_entries:
        return heading_entries
    return collect_step_entries(lines, BULLET_STEP_RE)


def extract_h2_entries(lines: list[str]) -> list[str]:
    entries: list[str] = []
    seen: set[str] = set()
    for line in lines:
        match = re.match(r"^##\s+(.+)$", line.strip())
        if not match:
            continue
        heading = match.group(1).strip()
        if heading in {"문서 목차 (Quick Index)", "단계 목차 (Step Index)"}:
            continue
        if heading not in seen:
            seen.add(heading)
            entries.append(heading)
    return entries


def build_meta_block(created_at: str, updated_at: str) -> list[str]:
    return [
        META_START,
        "> [!NOTE]",
        f"> - **Created At**: `{created_at}`",
        f"> - **Updated At**: `{updated_at}`",
        META_END,
    ]


def build_toc_block(lines: list[str]) -> list[str]:
    step_entries = extract_step_entries(lines)
    if step_entries:
        header = "## 단계 목차 (Step Index)"
        items = step_entries
    else:
        header = "## 문서 목차 (Quick Index)"
        items = extract_h2_entries(lines)

    if not items:
        items = ["(목차 대상 섹션 없음)"]

    block = [TOC_START, header, "---", "> [!TIP]"]
    block.extend([f"> - {item}" for item in items])
    block.append(TOC_END)
    return block


def find_insert_index(lines: list[str]) -> int:
    for idx, line in enumerate(lines):
        if re.match(r"^#\s+", line.strip()):
            return idx + 1
    return 0


def sync_file(path: str, now: str) -> bool:
    file_path = Path(path)
    raw = file_path.read_text(encoding="utf-8")
    normalized = raw.replace("\r\n", "\n")
    lines = normalized.split("\n")

    created_at = extract_created_at(normalized) or now

    # Remove previous managed blocks before recomputing.
    lines = remove_marker_block(lines, META_START, META_END)
    lines = remove_marker_block(lines, TOC_START, TOC_END)

    insert_idx = find_insert_index(lines)
    meta_block = build_meta_block(created_at, now)
    toc_block = build_toc_block(lines)

    prefix = lines[:insert_idx]
    suffix = lines[insert_idx:]
    while suffix and suffix[0].strip() == "":
        suffix = suffix[1:]

    new_lines: list[str] = []
    new_lines.extend(prefix)
    if not new_lines or new_lines[-1].strip() != "":
        new_lines.append("")
    new_lines.extend(meta_block)
    new_lines.append("")
    new_lines.extend(toc_block)
    if suffix:
        new_lines.append("")
        new_lines.extend(suffix)

    new_text = "\n".join(new_lines).rstrip() + "\n"
    if new_text == normalized:
        return False

    file_path.write_text(new_text, encoding="utf-8")
    return True


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sync Created/Updated metadata and top-of-doc index blocks."
    )
    parser.add_argument("paths", nargs="*", help="Markdown files to update")
    parser.add_argument(
        "--all-managed",
        action="store_true",
        help="Apply to all tracked markdown docs except excluded paths",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if args.all_managed:
        targets = list_managed_markdown_files()
    else:
        targets = [p for p in args.paths if p.endswith(".md") and not is_excluded(p)]

    if not targets:
        print("[doc-meta-toc] no target markdown files")
        return 0

    changed = 0
    for path in targets:
        if sync_file(path, now):
            changed += 1

    print(f"[doc-meta-toc] updated files: {changed}/{len(targets)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
