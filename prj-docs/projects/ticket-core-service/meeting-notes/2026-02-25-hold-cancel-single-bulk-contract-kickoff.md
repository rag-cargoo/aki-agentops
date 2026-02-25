# Meeting Notes: HOLD 취소(단건/벌크) 계약 확장 Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 16:20:00`
> - **Updated At**: `2026-02-25 17:22:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 사용자 요구사항 재정의
> - 안건 2: 백엔드 상태전이/API 결정
> - 안건 3: 프론트 연동 기준
> - 안건 4: 후속 작업
<!-- DOC_TOC_END -->

## 안건 1: 사용자 요구사항 재정의
- Status: DONE
- 요약:
  - checkout 모달에서 `좌석 예약(HOLD)` 완료 후에도 단건/전체 취소가 가능해야 한다.
  - 전체 취소는 다건 처리 성격이므로 벌크 API 우선 도입을 검토한다.

## 안건 2: 백엔드 상태전이/API 결정
- Status: DONE
- 결정:
  - `cancel` 전이를 `CONFIRMED` 전용에서 `HOLD`까지 확장해 예약 직후 취소를 허용한다.
  - 벌크 취소 엔드포인트를 추가해 reservationId 목록 취소를 1회 호출로 처리한다.
  - `refund`는 결제 확정 후 취소된 건만 허용하도록 가드를 명시한다.

## 안건 3: 프론트 연동 기준
- Status: DONE
- 기준:
  - 모달의 좌석 리스트 `X` 버튼은 HOLD 상태일 때 예약 취소 API를 호출한다.
  - `전체 취소` 버튼은 벌크 취소 API를 우선 사용한다.
  - 취소 성공 시 결제창 닫힘/좌석 리스트 재동기화/실시간 상태 문구를 즉시 반영한다.

## 안건 4: 후속 작업
- Status: DOING
- 후속:
  - [x] backend issue 재오픈/진행 코멘트 동기화
  - [x] 상태전이/컨트롤러/DTO/테스트 반영
  - [x] `reservation-api.md` 계약 업데이트
  - [ ] frontend checkout 모달 취소 동작 수동 시나리오 검증
