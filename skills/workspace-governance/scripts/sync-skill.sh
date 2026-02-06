#!/bin/bash
# [Skill Link Tool v2] 계층형 스킬 구조를 런타임에 심볼릭 링크로 연결합니다.

SOURCE_ROOT="/home/aki/2602/skills"
TARGET_ROOT="/home/aki/2602/.gemini/skills"

echo ">>>> 🔗 계층형 스킬 심볼릭 링크 작업 시작..."

# 타겟 루트 디렉토리 생성
mkdir -p "$TARGET_ROOT"

# 전체 디렉토리를 순회하며 SKILL.md가 있는 폴더를 찾아 링크
find "$SOURCE_ROOT" -name "SKILL.md" | while read -r skill_file; do
    skill_dir=$(dirname "$skill_file")
    skill_name=$(basename "$skill_dir")
    target_path="$TARGET_ROOT/$skill_name"

    rm -rf "$target_path"
    ln -s "$skill_dir" "$target_path"
    echo "  - [LINKED] $skill_name"
done

# .skill 개별 파일도 링크
find "$SOURCE_ROOT" -name "*.skill" | while read -r skill_file; do
    skill_name=$(basename "$skill_file" .skill)
    target_path="$TARGET_ROOT/$skill_name"
    
    rm -f "$target_path"
    ln -s "$skill_file" "$target_path"
    echo "  - [LINKED] $skill_name (main)"
done

echo ">>>> [SUCCESS] 모든 계층형 스킬이 연결되었습니다."
