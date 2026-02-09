---
name: aki-codex-core
description: |
  사용자 제작 코어 스킬 허브. 전역 원칙, 완료 정의, 스킬 분해/중복 처리 기준을 관리한다.
  코어 구조를 설계하거나 스킬 책임 경계를 정리할 때 사용한다.
  세션 리로드와 pre-commit 상세 실행은 `aki-codex-session-reload`, `aki-codex-precommit`으로 위임한다.
  (최신 업데이트: 2026-02-09 09:43:13 | 책임 매트릭스 공존/이관 계획 + aki- 네이밍 정책 연결)
---

# Aki Codex Core

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-09 17:38:06`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 책임 범위
> - 분해/통합 기준
> - 완료 정의
> - 위임 규칙
> - 네이밍 규칙
> - 참고 문서
<!-- DOC_TOC_END -->

## 목표
- 사용자 제작 코어 스킬 체계를 안정적으로 유지한다.
- 책임 경계가 모호한 스킬을 분리하거나 통합하는 기준을 제공한다.
- 코어 운영 규칙 변경 시 영향 범위를 사전에 드러낸다.

## 책임 범위
- 이 스킬이 담당:
  - 전역 원칙(무결성, 문서 추적성, 완료 정의)
  - 코어 스킬 경계 관리(누가 무엇을 담당하는지)
  - 중복 탐지/통합 판단 기준
- 이 스킬이 직접 담당하지 않음:
  - 세션 리로드 실행 상세
  - pre-commit 모드/검증 상세

## 분해/통합 기준
1. **분리**
   - 트리거가 다르고 출력 산출물이 다르면 분리한다.
   - 실패 시 영향 범위가 다르면 분리한다.
2. **통합**
   - 트리거/출력/도구셋이 같고 반복되는 경우 통합한다.
3. **레퍼런스 분리**
   - 실행 로직은 같고 예시/규칙만 늘어나는 경우 `references/`로 분리한다.
4. **과분화 방지**
   - 스킬 수를 늘리기보다 "책임 1개" 원칙으로 유지한다.

## 완료 정의
- 코어 스킬 변경은 아래가 모두 충족되어야 완료로 본다.
  1. 역할 경계 문서가 업데이트됨
  2. 관련 사이드바/세션 스냅샷 링크가 동기화됨
  3. `./skills/aki-codex-core/scripts/check-skill-naming.sh`(소스: `skills/aki-codex-core/scripts/check-skill-naming.sh`) 및 문서 스타일 검증이 통과됨

## 위임 규칙
1. 세션 시작/리로드 체인 작업:
   - `aki-codex-session-reload` 사용
2. pre-commit 모드/검증 체인 작업:
   - `aki-codex-precommit` 사용
3. 문서 렌더링/무손실 점검:
   - `aki-github-pages-expert` 사용
4. 백업 포인트 생성 실행:
   - 호환 명령: `./skills/bin/create-backup-point.sh`
   - 소스 스크립트: `skills/aki-codex-core/scripts/create-backup-point.sh`

## 네이밍 규칙
1. 사용자 제작 스킬은 `aki-` prefix를 기본값으로 사용한다.
2. 외부/시스템 스킬(`find-skills`, `skill-creator`, `skill-installer`)은 예외로 유지한다.
3. 스킬 추가/리네임 후 `./skills/aki-codex-core/scripts/check-skill-naming.sh`로 자동 점검한다.
4. 구현 스크립트는 `skills/aki-codex-core/scripts/check-skill-naming.sh`에 유지한다.

## 참고 문서
- 책임 매트릭스: `references/core-responsibility-matrix.md`
- 스킬 네이밍 정책: `references/skill-naming-policy.md`
- bin 소유 매핑: `references/bin-script-ownership-map.md`
- bin 폐기 인벤토리: `references/bin-wrapper-deprecation-inventory.md`
- bin 폐기 체크리스트: `references/bin-wrapper-deprecation-checklist.md`
