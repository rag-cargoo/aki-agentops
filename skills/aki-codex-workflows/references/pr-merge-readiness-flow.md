# PR Merge Readiness Flow

## When
- PR 리뷰/체크가 완료되어 머지 판단이 필요한 시점
- 머지 직전 최종 품질 게이트 확인이 필요한 시점

## Why
- 머지 직전 회귀/누락을 줄이고 릴리즈 안정성을 확보한다.
- PR 상태를 주관 판단이 아닌 표준 체크리스트로 판정한다.

## Order
1. 변경 범위/리스크 분류
   - Owner Skill: `aki-codex-workflows`
   - 문서/런타임/정책 변경 여부와 영향 범위를 분류한다.
2. pre-commit 최종 점검
   - Owner Skill: `aki-codex-precommit`
   - 필요 시 `strict`로 체인 검증을 수행한다.
3. 세션/런타임 무결성 점검
   - Owner Skill: `aki-codex-session-reload`
   - `session_start.sh` 기준 스냅샷/무결성 상태를 확인한다.
4. 추적 동기화 점검
   - Owner Skill: `aki-codex-workflows`
   - `task.md`와 GitHub Issue 상태 드리프트 여부를 확인한다.
5. 머지 판정/보고
   - Owner Skill: `aki-codex-workflows`
   - `Go` 또는 `No-Go`를 근거와 함께 보고한다.

## Condition
- `strict` 필수 조건:
  - 정책/런타임/구조 대변경, 릴리즈 직전, 다수 스킬 변경
- 실패 정책:
  - 기본 `Stop-first`
  - 수정 후 동일 절차로 재검증
- 추적 드리프트 발견 시:
  - SoT(GitHub Issue) 기준으로 먼저 정렬 후 머지 판단

## Done
- Completion:
  - 머지 전 체크 절차를 표준 순서로 완료함
- Verification:
  - pre-commit 통과 + 세션 무결성 정상 + 추적 드리프트 해소
- Evidence:
  - 검증 실행 로그
  - 이슈/PR 상태 링크
  - 최종 Go/No-Go 판정
