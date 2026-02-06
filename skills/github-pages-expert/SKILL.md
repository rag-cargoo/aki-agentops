---
name: github-pages-expert
description: |
  GitHub Pages(Docsify) 기술 문서 구조화 및 시각 표준 전문 스킬.
  데이터 유실 0% 보장 및 YAML형 시각적 위계 적용을 강제합니다.
  (최신 업데이트: 2026-02-07 20:05:15 | 실시간 버전 증명 및 YAML 깊은 들여쓰기 표준)
---

# 깃헙 페이지스 기술 문서 전문가 (GitHub Pages Expert)

GitHub Pages와 Docsify를 활용하여 기술 지식을 고품질 웹 문서로 변환하고 관리합니다.

## 1. 핵심 미션
- 무손실 정책: 리팩토링 중 라인 수 및 바이트 수를 물리적으로 검증하여 데이터 유실 차단.
- 시각 표준화: Docsify Alert 박스와 다크 테마 코드 블록을 사용하여 가독성 극대화.
- 들여쓰기 표준: 중첩 리스트에 대해 YAML 스타일의 깊은 들여쓰기 강제 적용.

## 2. 가이드라인
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
