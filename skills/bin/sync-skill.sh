#!/bin/bash
# [Skill Link Tool v3] 통합된 전문 스킬 구조를 런타임에 연결합니다.

SOURCE_ROOT="/home/aki/2602/skills"
TARGET_ROOT="/home/aki/2602/.gemini/skills"

echo ">>>> 🔗 통합 전문 스킬 심볼릭 링크 연결 시작..."

# 타겟 루트 디렉토리 생성
mkdir -p "$TARGET_ROOT"

# skills/ 하위의 각 스킬 디렉토리를 순회하며 링크 생성
find "$SOURCE_ROOT" -maxdepth 1 -mindepth 1 -type d | while read -r skill_dir; do
    skill_name=$(basename "$skill_dir")
    target_path="$TARGET_ROOT/$skill_name"

    rm -rf "$target_path"
    ln -s "$skill_dir" "$target_path"
    echo "  - [LINKED] $skill_name"
done

echo ">>>> [SUCCESS] 모든 스킬이 통합 및 연결되었습니다."