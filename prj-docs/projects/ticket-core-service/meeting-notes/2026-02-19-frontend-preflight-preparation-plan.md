# Meeting Notes: Frontend Preflight Preparation Plan (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 14:50:59`
> - **Updated At**: `2026-02-19 14:50:59`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 프론트 오류 파서 고정 스키마 사전 확정
> - 안건 2: 시간 파싱 공통 유틸 규약 확정
> - 안건 3: 실시간 클라이언트 WS 기본 + SSE 폴백 전략 확정
> - 안건 4: 최종 핸드오프 증빙 고정 절차 확정
> - 안건 5: 이슈/태스크 트래킹 동기화
<!-- DOC_TOC_END -->

## 안건 1: 프론트 오류 파서 고정 스키마 사전 확정
- Created At: 2026-02-19 14:50:59
- Updated At: 2026-02-19 14:50:59
- Status: TODO
- 결정사항:
  - 프론트 오류 파서는 `status`, `errorCode`, `message` 3필드를 고정 스키마로 사용한다.
  - `AUTH_*` + 비-auth(`BAD_REQUEST`, `CONFLICT`, `REQUEST_BODY_INVALID`, `INTERNAL_SERVER_ERROR`)를 코드 상수 테이블로 고정한다.
- 후속작업:
  - [ ] UI 전역 에러 어댑터에서 문자열 본문 fallback 제거 여부 점검
  - [ ] 에러코드별 사용자 메시지/재시도 정책 매핑표 확정

## 안건 2: 시간 파싱 공통 유틸 규약 확정
- Created At: 2026-02-19 14:50:59
- Updated At: 2026-02-19 14:50:59
- Status: TODO
- 결정사항:
  - `LocalDateTime`(offset 없음)과 `Instant(UTC)` 혼재 응답을 단일 유틸에서 파싱한다.
  - 내부 표준은 UTC 인스턴트로 정규화하고, 화면 출력 시 사용자 시간대로 변환한다.
- 후속작업:
  - [ ] 응답 필드 타입별 파서 분기표(도메인별 `*At` 필드) 작성
  - [ ] 프론트 공통 util/API client 레이어 적용 범위 확정

## 안건 3: 실시간 클라이언트 WS 기본 + SSE 폴백 전략 확정
- Created At: 2026-02-19 14:50:59
- Updated At: 2026-02-19 14:50:59
- Status: TODO
- 결정사항:
  - 기본 전송 채널은 WebSocket(STOMP)로 고정한다.
  - WS 실패/차단 환경에 한해 SSE 폴백을 허용한다.
  - 재연결(backoff), 구독 복구(resubscribe), 화면 이탈 시 unsubscribe 절차를 명시한다.
- 후속작업:
  - [ ] 채널 전환 상태 머신(WS -> SSE fallback -> WS restore) 정의
  - [ ] 네트워크 오류/인증 만료 시 재연결 시나리오 테스트 케이스 확정

## 안건 4: 최종 핸드오프 증빙 고정 절차 확정
- Created At: 2026-02-19 14:50:59
- Updated At: 2026-02-19 14:50:59
- Status: TODO
- 결정사항:
  - 프론트 핸드오프 직전 `make test-suite` 1회 실행과 리포트 최신화를 필수 증빙으로 고정한다.
  - 결과 리포트 경로(`.codex/tmp/ticket-core-service/api-test/latest.md`)를 체크리스트 증빙 링크로 사용한다.
- 후속작업:
  - [ ] `make test-suite` 재실행 후 C5 상태 갱신
  - [ ] 체크리스트/이슈 코멘트에 최종 증빙 링크 반영

## 안건 5: 이슈/태스크 트래킹 동기화
- Created At: 2026-02-19 14:50:59
- Updated At: 2026-02-19 14:50:59
- Status: DONE
- 처리사항:
  - 트래킹 이슈: `https://github.com/rag-cargoo/aki-agentops/issues/118`
  - 기준 PR: `https://github.com/rag-cargoo/aki-agentops/pull/119`
  - 기준 구현 커밋: `rag-cargoo/ticket-core-service@1988f2c`
  - sidecar `task.md`에 `TCS-SC-015`로 후속 TODO 등록
