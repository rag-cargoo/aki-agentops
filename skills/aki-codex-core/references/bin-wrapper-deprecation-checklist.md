# Bin Wrapper Deprecation Checklist

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 17:26:35`
> - **Updated At**: `2026-02-09 17:28:46`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표 상태
> - 단계별 체크리스트
> - 종료 조건
<!-- DOC_TOC_END -->

## 목표 상태
- `skills/bin`은 완전히 제거하거나, 최소한 저장소 표준 경로에서 제외한다.
- 실행 로직은 `skills/<skill>/scripts/`만 단일 소스로 유지한다.

## 단계별 체크리스트
1. 인벤토리 확정
   - [x] `skills/bin/` 참조 전수 수집
   - [x] 분류(A/B/C) 및 처리 전략 문서화
2. 즉시 전환 가능한 내부 경로 처리
   - [x] `.githooks/pre-commit` 전환
   - [x] `.github/workflows/codex-skills-reload.yml` 전환
   - [x] `workspace-governance` strict 정책 전환
3. 호환 기간 운영(1~2 릴리즈)
   - [ ] 사용자 문서 명령을 source-first + compat 병기 형태로 전환
   - [ ] 릴리즈 기간 동안 wrapper 호출 이슈 0건 확인
4. 최종 제거 준비
   - [ ] `skills/bin` 의존 호출 지점 0건(호환 문구 제외) 확인
   - [ ] 제거 PR 체크리스트(문서/훅/CI/운영가이드) 검증
5. 최종 제거
   - [ ] `skills/bin` 래퍼/링크 제거
   - [ ] 이슈 `#10`을 `status:done`으로 전환 후 close

## 종료 조건
1. `rg -n "skills/bin/"` 결과가 호환 안내 문구를 제외하고 0건이다.
2. 주요 실행 검증이 모두 통과한다.
   - `./skills/aki-codex-session-reload/scripts/codex_skills_reload/session_start.sh`
   - `bash skills/aki-codex-precommit/scripts/validate-precommit-chain.sh --mode strict`
   - 관련 workflow dry-run
3. 팀 합의로 wrapper 제거 시점을 승인한다.
