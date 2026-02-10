# Precommit Runbook

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-10 06:54:11`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 모드 운용
> - strict 트리거 기준
> - 비용 최적화
> - 수동 검증
> - strict 차단 대응
<!-- DOC_TOC_END -->

> [!NOTE]
> pre-commit 검증 체인을 빠르게 점검/운영하기 위한 실무 런북.

## 모드 운용
1. 현재 모드 확인:
   - `./skills/aki-codex-precommit/scripts/precommit_mode.sh status`
2. 기본 모드 전환:
   - `./skills/aki-codex-precommit/scripts/precommit_mode.sh quick`
   - `./skills/aki-codex-precommit/scripts/precommit_mode.sh strict`
   - 모드 전환 시 `runtime_flags.yaml`/`current_status.txt`가 자동 동기화된다.
3. 1회성 strict:
   - `CHAIN_VALIDATION_MODE=strict git commit -m "..."`

## strict 트리거 기준
1. 중요 커밋:
   - 정책/런타임/워크플로우/훅 변경
2. PR 머지 직전 최종 점검
3. 릴리즈 직전
4. 대규모 리팩터링 완료 시점

## 비용 최적화
1. 기본 커밋은 `quick` 유지
2. `strict`는 트리거 조건 충족 시에만 실행
3. 세션 시작 환경 점검은 `session-reload`의 `validate_env.sh` 1회로 분리
4. 항상 strict를 강제하지 않는다(처리시간/토큰/운영비용 절감)

## 수동 검증
1. `./skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode quick`
2. `./skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode strict`
3. 정책 파일 확인:
   - 전역: `skills/aki-codex-precommit/policies/*.sh`
   - 프로젝트: `<project-root>/prj-docs/precommit-policy.sh`
4. 스킬 변경 시 네이밍 정책 점검:
   - `./skills/aki-codex-core/scripts/check-skill-naming.sh`

## 소스 경로
1. pre-commit 모드 스크립트: `skills/aki-codex-precommit/scripts/precommit_mode.sh`
2. 체인 검증 스크립트: `skills/aki-codex-precommit/scripts/validate-precommit-chain.sh`
3. 네이밍 검증 스크립트: `skills/aki-codex-core/scripts/check-skill-naming.sh`
4. 모든 실행 경로는 각 스킬의 `scripts/` 소스 경로를 기준으로 사용한다.

## strict 차단 대응
1. 정책 미커버 경로가 있으면 정책 루트에 staged 경로를 포함시킨다.
2. 프로젝트 strict 요구 문서/API 리포트가 누락되면 함께 staged한다.
3. 산출물(`build/`, `.gradle/` 등) staged를 제거한다.
