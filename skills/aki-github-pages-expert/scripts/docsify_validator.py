import re
import sys

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


def requires_meta_toc(file_path: str) -> bool:
    normalized = file_path.replace("\\", "/")
    if normalized in EXCLUDED_FILES:
        return False
    for prefix in EXCLUDED_PREFIXES:
        if normalized.startswith(prefix):
            return False
    return normalized.endswith(".md")


def validate_docsify(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    errors = []
    
    # 1. 이모티콘 검사
    emoji_pattern = re.compile(r'[\U00010000-\U0010ffff\u2600-\u27bf]')
    if emoji_pattern.search(content):
        errors.append("❌ 이모티콘 발견!")
    
    # 2. Alert 박스 검사
    if content.count('## ') > 0 and '[!' not in content:
        errors.append("❌ Alert 박스(태그) 누락!")

    # 3. 문서 메타/목차 블록 검사
    if requires_meta_toc(file_path):
        if META_START not in content or META_END not in content:
            errors.append("❌ 문서 메타 블록 누락(DOC_META_START/END)")
        if TOC_START not in content or TOC_END not in content:
            errors.append("❌ 문서 목차 블록 누락(DOC_TOC_START/END)")

        if not re.search(r"\*\*Created At\*\*:\s*`[^`]+`", content):
            errors.append("❌ Created At 누락")
        if not re.search(r"\*\*Updated At\*\*:\s*`[^`]+`", content):
            errors.append("❌ Updated At 누락")

    return errors

if __name__ == "__main__":
    if len(sys.argv) < 2: sys.exit(1)
    errs = validate_docsify(sys.argv[1])
    if errs:
        for e in errs: print(e)
        sys.exit(1)
    else:
        print("✅ 스타일 검증 통과!")
        sys.exit(0)
