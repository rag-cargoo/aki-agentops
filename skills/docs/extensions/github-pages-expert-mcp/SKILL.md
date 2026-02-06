---
name: github-pages-expert-mcp
description: |
  [EXT-MCP] GitHub Pages 및 Docsify 기술 문서 배포 전문 자동화 엔진.
  원자적 빌드(Atomic Build) 및 물리적 바이트 검증을 통해 100% 무결성을 보장합니다.
---

# 🛡️ GitHub Pages Expert MCP

이 스킬은 GitHub Pages 환경에서 **문서의 기술적 무결성**과 **시각적 일관성**을 기계적으로 강제하는 외부 확장 지침입니다.

## ⚖️ 핵심 조립 규격 (Assembly Specs)

1.  **원자적 섹션 조립 (Atomic Assembly)**: 모든 리팩토링은 '조각(Section)' 단위로 독립 빌드한 뒤 병합한다. 덮어쓰기는 시스템 에러로 간주한다.
2.  **물리적 무결성 레이어 (Physical Integrity Layer)**:
    - 수정 전/후 파일 크기를 바이트 단위로 체크하여 편차가 5% 이상일 경우(데이터 소실 의심) 강제 롤백한다.
    - `grep`을 통해 원본의 코드 시그니처가 유지되는지 자동 검증한다.
3.  **Docsify 렌더링 최적화**: 
    - Alert 박스(`[!태그]`) 문법의 100% 정합성을 보장한다.
    - 중복 인용구(`> >`)나 깨진 마크다운 태그를 기계적으로 필터링한다.

## 🛠️ 엔진 도구
- `mcp-docs-validator`: 마크다운 문법 정적 분석
- `atomic-merger`: 물리적 텍스트 병합기
