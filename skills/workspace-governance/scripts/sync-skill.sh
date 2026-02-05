#!/bin/bash
# ==============================================================================
# [Skill Link Tool] 
# 프로젝트 루트의 스킬 소스(skills/*)를 제미나이 런타임(.gemini/skills/*)에 
# 디렉토리 단위 심볼릭 링크로 연결합니다.
# ==============================================================================

SOURCE_ROOT="/home/aki/2602/skills"
TARGET_ROOT="/home/aki/2602/.gemini/skills"

echo ">>>> 🔗 스킬 심볼릭 링크 연결 시작..."

# 타겟 루트 디렉토리 생성
mkdir -p "$TARGET_ROOT"

# skills/ 하위의 각 스킬 디렉토리를 순회하며 링크 생성
for skill_path in "$SOURCE_ROOT"/*; do
    if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        target_path="$TARGET_ROOT/$skill_name"

        # 기존 요소(파일/폴더/깨진 링크) 제거
        rm -rf "$target_path"
        
        # 디렉토리 심볼릭 링크 생성
        ln -s "$skill_path" "$target_path"
        echo "  - [LINKED] $skill_name"
    fi
done

echo ""
echo ">>>> [SUCCESS] 모든 스킬이 실시간 동기화 모드로 연결되었습니다."
echo ">>>> ⚠️  중요: 이제 소스를 수정해도 스크립트 재실행이 필요 없습니다."
echo ">>>> ⚠️  단, 제미나이 창에 '/skills reload'를 입력하여 변경사항을 지식에 반영하세요."