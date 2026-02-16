# Pre-commit Flow

## When
- 커밋 직전
- 릴리즈/마일스톤/대규모 리팩터링 전후 품질 게이트가 필요한 시점

## Why
- 커밋 전에 정책 위반과 회귀를 차단한다.
- quick/strict 모드를 상황에 맞게 적용해 속도와 안전을 균형화한다.

## Order
1. 변경 범위/리스크 파악
   - Owner Skill: `aki-codex-workflows`
   - 일반 변경은 quick, 고위험 변경은 strict 후보로 분류한다.
   - 작업 시작 시 임시 산출물 경로를 먼저 확정한다: `.codex/tmp/<tool>/<run-id>/`
2. 모드 확인/전환
   - Owner Skill: `aki-codex-precommit`
   - `precommit_mode.sh status|quick|strict` 실행
3. 체인 검증 실행
   - Owner Skill: `aki-codex-precommit`
   - `validate-precommit-chain.sh --mode quick|strict` 실행
   - 원격 상태 동기화까지 확인할 때: `validate-precommit-chain.sh --mode strict --all --strict-remote`
4. 결과 판정
   - Owner Skill: `aki-codex-workflows`
   - 실패면 커밋 중단, 성공이면 커밋 진행

## Condition
- `strict` 강제 조건:
  - 중요 커밋(정책/런타임/워크플로우/훅 변경)
  - PR 머지 직전 최종 검증
  - 릴리즈 직전
  - 대규모 리팩터링 완료 시점
- 비용 최적화:
  - 기본은 `quick`
  - 세션 시작 시 환경 검증은 1회(`validate_env.sh`)만 수행
  - `strict`는 이벤트 기반으로만 수행(항상 실행 금지)
- 실패 정책:
  - 기본 `Stop`
  - 원인/수정 포인트 보고 후 재실행(`Retry`)

## Done
- Completion:
  - 선택한 모드의 체인 검증이 실행됨
- Verification:
  - 검증 명령 exit code `0`
  - strict 차단 규칙 위반 없음
- Evidence:
  - 실행 명령/모드
  - 핵심 출력 요약(pass/fail)
