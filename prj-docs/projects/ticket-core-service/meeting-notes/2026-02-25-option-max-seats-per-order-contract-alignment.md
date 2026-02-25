# Meeting Notes: Option-Level maxSeatsPerOrder Contract Alignment (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-25 13:05:00`
> - **Updated At**: `2026-02-25 13:05:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 범위 재정의(백엔드 우선, 프론트 분리)
> - 안건 2: 백엔드 계약/검증 규칙
> - 안건 3: API/문서 반영 범위
> - 안건 4: 후속 작업(프론트 연계)
<!-- DOC_TOC_END -->

## 안건 1: 범위 재정의(백엔드 우선, 프론트 분리)
- Status: DONE
- 결정:
  - 이번 작업은 `회차(ConcertOption) 단위 1회 주문 최대 좌석수` 계약을 먼저 백엔드에 고정한다.
  - 프론트(`ticket-web-app`)의 다중 좌석 선택 UX는 별도 후속으로 분리해 진행한다.
  - 트래킹은 제품 이슈 2개를 병행한다.
    - backend: `https://github.com/rag-cargoo/ticket-core-service/issues/20`
    - frontend: `https://github.com/rag-cargoo/ticket-web-app/issues/3`

## 안건 2: 백엔드 계약/검증 규칙
- Status: DONE
- 결정:
  - `concert_options.maxSeatsPerOrder` 필드를 도입한다.
  - 기본값: `2`
  - 허용 범위: `1 <= maxSeatsPerOrder <= 10`
  - 생성/수정 경로에서 값이 `null`이면 기본값으로 정규화한다.
  - 범위를 벗어나면 `IllegalArgumentException`으로 `400 BAD_REQUEST`를 반환한다.

## 안건 3: API/문서 반영 범위
- Status: DONE
- 반영:
  - Admin 옵션 생성/수정 요청에 `maxSeatsPerOrder`를 추가한다.
    - `POST /api/admin/concerts/{concertId}/options`
    - `PUT /api/admin/concerts/options/{optionId}`
  - 옵션 조회 응답에 `maxSeatsPerOrder`를 추가한다.
    - `GET /api/concerts/{id}/options`
    - `ConcertOptionResponse`
  - API 명세 문서 반영:
    - `prj-docs/projects/ticket-core-service/product-docs/api-specs/concert-api.md`

## 안건 4: 후속 작업(프론트 연계)
- Status: DOING
- 후속:
  - 프론트 checkout 모달에서 `maxSeatsPerOrder`를 읽어 다중 좌석 선택 상한을 UI에서 강제한다.
  - Admin 옵션 폼/테이블에도 `maxSeatsPerOrder` 입력/조회 필드를 노출한다.
  - 회의록/task 동기화는 프론트 sidecar(`ticket-web-app`)에 별도 기록한다.
