#!/usr/bin/env python3

import argparse
import re
import subprocess
import sys
from pathlib import Path

META_START = "<!-- DOC_META_START -->"
META_END = "<!-- DOC_META_END -->"
TOC_START = "<!-- DOC_TOC_START -->"
TOC_END = "<!-- DOC_TOC_END -->"

EXCLUDED_FILES = {
    "sidebar-manifest.md",
    "sidebar-agent-manifest.md",
    "github-pages/sidebar-manifest.md",
    "github-pages/sidebar-agent-manifest.md",
    "workspace/apps/backend/ticket-core-service/prj-docs/api-test/latest.md",
}
EXCLUDED_PREFIXES = (
    ".codex/runtime/",
    ".gemini/",
)

FORCE_MANAGED_FILES = {
    "AGENTS.md",
    "github-pages/HOME.md",
    "README.md",
}


def is_excluded(file_path: str) -> bool:
    normalized = file_path.replace("\\", "/")
    if normalized in EXCLUDED_FILES:
        return True
    for prefix in EXCLUDED_PREFIXES:
        if normalized.startswith(prefix):
            return True
    return False


def is_markdown(file_path: str) -> bool:
    return file_path.replace("\\", "/").endswith(".md")


def is_managed_docsify_file(file_path: str, content: str) -> bool:
    normalized = file_path.replace("\\", "/")
    if is_excluded(normalized) or not is_markdown(normalized):
        return False
    if normalized in FORCE_MANAGED_FILES:
        return True
    return META_START in content or TOC_START in content


def list_all_managed_docs() -> list[str]:
    raw = subprocess.check_output(
        ["git", "-c", "core.quotePath=false", "ls-files", "*.md"],
        text=True,
    )
    targets = []
    for path in raw.splitlines():
        if not path:
            continue
        if is_excluded(path):
            continue
        try:
            content = Path(path).read_text(encoding="utf-8")
        except FileNotFoundError:
            continue
        if is_managed_docsify_file(path, content):
            targets.append(path)
    return targets


def validate_docsify(file_path: str) -> list[str]:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    errors = []
    managed = is_managed_docsify_file(file_path, content)

    # 1. 이모티콘 검사
    if managed:
        emoji_pattern = re.compile(r"[\U00010000-\U0010ffff\u2600-\u27bf]")
        if emoji_pattern.search(content):
            errors.append("❌ 이모티콘 발견!")

    # 2. Alert 박스 검사
    if managed and content.count("## ") > 0 and "[!" not in content:
        errors.append("❌ Alert 박스(태그) 누락!")

    # 3. 문서 메타/목차 블록 검사
    if managed:
        if META_START not in content or META_END not in content:
            errors.append("❌ 문서 메타 블록 누락(DOC_META_START/END)")
        if TOC_START not in content or TOC_END not in content:
            errors.append("❌ 문서 목차 블록 누락(DOC_TOC_START/END)")

        if not re.search(r"\*\*Created At\*\*:\s*`[^`]+`", content):
            errors.append("❌ Created At 누락")
        if not re.search(r"\*\*Updated At\*\*:\s*`[^`]+`", content):
            errors.append("❌ Updated At 누락")

    return errors


def iter_markdown_targets(raw_targets: list[str]) -> list[str]:
    targets: list[str] = []
    seen: set[str] = set()
    for raw in raw_targets:
        path = Path(raw)
        if path.is_dir():
            for candidate in sorted(path.rglob("*.md")):
                normalized = str(candidate).replace("\\", "/")
                if normalized in seen:
                    continue
                seen.add(normalized)
                targets.append(normalized)
            continue
        normalized = str(path).replace("\\", "/")
        if normalized in seen:
            continue
        seen.add(normalized)
        targets.append(normalized)
    return targets


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate docsify managed markdown style/meta/toc rules.",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="One or more markdown files/directories to validate",
    )
    parser.add_argument(
        "--all-managed",
        action="store_true",
        help="Validate all tracked managed markdown files",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    targets: list[str]
    if args.all_managed:
        targets = list_all_managed_docs()
    else:
        targets = iter_markdown_targets(args.paths)

    if not targets:
        print("[docsify-validator] no targets")
        return 1

    total = 0
    failed = 0
    for file_path in targets:
        if not is_markdown(file_path):
            continue
        total += 1
        try:
            errs = validate_docsify(file_path)
        except FileNotFoundError:
            failed += 1
            print(f"[docsify-validator] missing file: {file_path}")
            continue

        if errs:
            failed += 1
            print(f"[docsify-validator] FAIL: {file_path}")
            for err in errs:
                print(err)

    if total == 0:
        print("[docsify-validator] no markdown targets")
        return 1

    if failed > 0:
        print(f"[docsify-validator] failed: {failed}/{total}")
        return 1

    print("✅ 스타일 검증 통과!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
