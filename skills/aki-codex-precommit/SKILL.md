---
name: aki-codex-precommit
description: |
  pre-commit 품질 게이트 운영 스킬.
  `precommit_mode.sh`, `validate-precommit-chain.sh`, `skills/aki-codex-precommit/policies/*.sh`를 기준으로 quick/strict 검증 체인을 관리한다.
  스킬 변경이 있는 커밋에서는 `check-skill-naming.sh`를 자동 호출해 `aki-` 네이밍 정책 위반을 차단한다.
  커밋 전에 정책 커버리지, strict 차단 조건, 프로젝트별 precommit-policy 적용 여부를 확인해야 할 때 사용한다.
---

# Aki Codex Precommit

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-09 17:53:22`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 운영 대상
> - 모드 정책
> - 실행 절차
> - strict 차단 규칙
> - 참고 문서
<!-- DOC_TOC_END -->

## 목표
- 커밋 전에 정책 위반을 자동 탐지해 품질 회귀를 차단한다.
- 일상 커밋 속도(`quick`)와 중요 커밋 강검증(`strict`)을 분리 운영한다.
- 프로젝트별 precommit-policy와 전역 정책을 체인으로 통합한다.

## 운영 대상
- 소스 스크립트:
  - `skills/aki-codex-precommit/scripts/precommit_mode.sh`
  - `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh`
- `skills/aki-codex-precommit/policies/*.sh`
- `<project-root>/prj-docs/precommit-policy.sh`

## 모드 정책
1. `quick`:
   - 일상 커밋 기본 모드
   - 경량 검증/경고 중심
2. `strict`:
   - 마일스톤/릴리즈/대규모 리팩토링 완료 시 사용
   - 정책 미커버 경로 및 강검증 규칙 위반 시 차단

## 실행 절차
1. 현재 모드 확인:
   - `./skills/aki-codex-precommit/scripts/precommit_mode.sh status`
2. 필요 모드 전환:
   - `./skills/aki-codex-precommit/scripts/precommit_mode.sh quick|strict`
3. 수동 정책 실행:
   - `./skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick|strict`
4. 최종 커밋:
   - `git commit -m "..."`

## strict 차단 규칙
- 정책 미커버 staged 경로가 있으면 커밋 차단
- 프로젝트 정책에서 요구하는 문서/API/리포트 동기화가 없으면 차단
- 산출물/임시 파일 staged 금지 규칙 위반 시 차단
- 스킬 변경 시 네이밍 정책(`./skills/aki-codex-core/scripts/check-skill-naming.sh`) 위반이면 차단
- 네이밍 검사의 소스 스크립트는 `skills/aki-codex-core/scripts/check-skill-naming.sh`를 사용

## 참고 문서
- pre-commit 시작 가이드: `references/precommit-runbook.md`
