---
name: github-pages-expert
description: |
  GitHub Pages(Docsify) 기술 문서 구조화 및 시각 표준 전문 스킬.
  데이터 무결성 사수(replace 필수) 및 STRUCTURE.md 5번 지식 문서 표준을 강제합니다.
  (최신 업데이트: 2026-02-07 00:10:57 | 실시간 버전 증명 및 거버넌스 원칙 동기화)
---

# 깃헙 페이지스 기술 문서 전문가 (GitHub Pages Expert)

GitHub Pages와 Docsify를 활용하여 기술 지식을 고품질 웹 문서로 변환하고 관리합니다.

## 1. 핵심 미션
- 데이터 무결성: 기존 문서 수정 시 반드시 replace 도구 사용. (데이터 유실 시 즉시 롤백)
- 시각 표준화: Docsify Alert 박스(H3+구분선) 및 YAML 스타일의 깊은 들여쓰기 적용.
- 지식 콘텐츠 표준: [STRUCTURE.md 5번] 지침에 따라 "학습 가능한 고품질 문서" 작성.

## 🚨 2. 에이전트 강제 체크리스트 (Mandatory Checklist)
모든 기술 문서 작업 완료 전, 에이전트는 반드시 아래 항목을 스스로 검증하고 사용자에게 보고해야 한다.

1. **[Failure-First]**: 기존 방식의 한계와 기술적 함정(Trap)이 서두에 명시되었는가?
2. **[Before & After]**: 개선 전/후의 코드가 주석과 함께 직접 대조되어 있는가? (생략 금지)
3. **[Execution Log]**: 실제 테스트 스크립트 실행 결과(Raw Log)가 박제되었는가?
4. **[6-Step API]**: API 명세의 경우 6단계(Endpoint ~ Response Example) 규격을 준수했는가?
5. **[No Emojis]**: 모든 이모티콘이 제거되고 공학적 신뢰도가 확보되었는가?

## 3. 완료 정의 (Definition of Done)
- "구현 완료"는 [코드 수정 + 테스트 검증 + 지식 문서화 + API 명세 현행화]가 패키지로 끝났음을 의미한다. 하나라도 누락 시 작업을 종료하지 마라.

## 4. 가이드라인
- 이모티콘 금지: 기술 문서의 신뢰도를 위해 모든 유니코드 이모티콘 사용을 절대 금지.
- 위계 구조: H2 구분선 -> 박스(>) 테두리 -> H3 구분선 -> 2칸 단위 들여쓰기.
- 기계적 검증: 커밋 전 반드시 scripts/docsify_validator.py를 실행하여 통과 확인.

## 3. 작업 워크플로우
- 1단계: wc -l 명령어로 원본 파일의 라인 수를 먼저 기록.
- 2단계: 박스(>) 태그 내부에 시각적 위계에 맞춰 텍스트 재배치.
- 3단계: scripts/check_data_loss.py를 실행하여 원본 대비 유실 없음을 증명.

## 4. 전용 도구 세트
- scripts/docsify_validator.py (스타일 검사)
- scripts/check_data_loss.py (무결성 검사)
