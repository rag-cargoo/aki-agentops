# Meeting Notes: Ticket Listing Sale Status and Media Contract Kickoff (ticket-web-client)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 03:21:00`
> - **Updated At**: `2026-02-20 04:30:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 요구사항 정리
> - 안건 2: 백엔드 응답 계약
> - 안건 3: 구현/검증 범위
> - 안건 4: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 요구사항 정리
- Status: DONE
- 결정사항:
  - 메인 목록은 테스트 카드가 아니라 예매 서비스 관점으로 전환한다.
  - 프론트는 백엔드 응답 기반으로 `예매 버튼 노출/활성`을 제어한다.
  - 오픈 임계 구간은 최소 `1시간 전`, `5분 전`을 구분해 표현한다.

## 안건 2: 백엔드 응답 계약
- Status: DONE
- 계약 초안:
  - 공연 목록 응답(`GET /api/concerts`, `/api/concerts/search`)에 아래 필드를 추가한다.
    - `saleStatus`: `UNSCHEDULED | PREOPEN | OPEN_SOON_1H | OPEN_SOON_5M | OPEN | SOLD_OUT`
    - `saleOpensAt`: 일반 예매 오픈 시각
    - `saleOpensInSeconds`: 오픈까지 남은 초
    - `reservationButtonVisible`: 프론트 버튼 노출 여부
    - `reservationButtonEnabled`: 프론트 버튼 활성 여부
    - `availableSeatCount`, `totalSeatCount`: 잔여/전체 좌석 집계
- 처리결과:
  - 상태 계산 로직 및 DTO/컨트롤러 반영 완료
  - 테스트: `./gradlew test --tests com.ticketrush.domain.concert.service.ConcertExplorerIntegrationTest` PASS

## 안건 3: 구현/검증 범위
- Status: DONE
- 구현:
  - 백엔드에서 판매정책 + 좌석집계 기반 상태 계산 로직 추가
  - 콘서트 목록 DTO 확장 및 응답 반영
  - 문서(`concert-api.md`, `frontend-feature-spec.md`) 동기화
- 검증:
  - `ticket-core-service`: 단위/통합 테스트로 status 필드 검증
  - 프론트 연동은 후속 단계에서 버튼/카운트다운 렌더링 검증

## 안건 4: 이슈/태스크 동기화
- Status: DONE
- 처리계획:
  - `task.md`에 `TWC-SC-009` 추가 및 진행 상태 추적
  - 기존 이슈 재사용 우선 조회 후, 범위 불일치 시 신규 이슈 생성
- 처리결과:
  - AKI AgentOps 이슈 생성: `#128`
  - URL: `https://github.com/rag-cargoo/aki-agentops/issues/128`
  - 진행 코멘트: `https://github.com/rag-cargoo/aki-agentops/issues/128#issuecomment-3929066936`
  - 구현 완료 후 sidecar task에서 `TWC-SC-009`를 `DONE`으로 갱신
