# Meeting Notes: OAuth/JWT Session Hardening Completion (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 01:31:31`
> - **Updated At**: `2026-02-19 01:31:31`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 구현 완료 및 이슈/PR 상태
> - 안건 2: 인증 계약 변경사항
> - 안건 3: 후속 점검 항목
<!-- DOC_TOC_END -->

## 안건 1: 구현 완료 및 이슈/PR 상태
- Created At: 2026-02-19 01:31:31
- Updated At: 2026-02-19 01:31:31
- Status: DONE
- 결정사항:
  - 제품 이슈 `rag-cargoo/ticket-core-service#7` 완료(CLOSED)
  - 구현 PR `rag-cargoo/ticket-core-service PR #8` 머지 완료
  - 머지 커밋 `f3cd910632bddf266bda904a382b977d20538b05`

## 안건 2: 인증 계약 변경사항
- Created At: 2026-02-19 01:31:31
- Updated At: 2026-02-19 01:31:31
- Status: DONE
- Checklist:
  - [x] Access Token에 `jti`(token id) 발급 추가
  - [x] 로그아웃 시 `refreshToken` revoke + `accessToken` denylist 무효화 동시 처리
  - [x] JWT 필터에서 denylist access 토큰 차단 처리
  - [x] Redis 미사용 환경용 InMemory denylist fallback 구성
  - [x] `./gradlew test` 전체 통과

## 안건 3: 후속 점검 항목
- Created At: 2026-02-19 01:31:31
- Updated At: 2026-02-19 01:31:31
- Status: TODO
- 후속작업:
  - 프론트 연동 시 `logout` 요청 헤더(`Authorization`) 누락 케이스를 e2e 테스트로 추가 검증
  - 운영 환경에서 Redis 장애 시 denylist fallback 로그 모니터링 기준 정리
