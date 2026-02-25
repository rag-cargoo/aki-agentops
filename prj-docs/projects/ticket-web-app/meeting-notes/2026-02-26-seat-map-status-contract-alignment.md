# Meeting Notes: Seat-Map 상태 조회 계약 정렬 (ticket-web-app)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-26 00:26:00`
> - **Updated At**: `2026-02-26 00:26:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 문제 정의
> - 안건 2: API 계약 정렬
> - 안건 3: 프론트 반영 원칙
> - 안건 4: 이슈/태스크 동기화
> - 안건 5: 후속 검증
<!-- DOC_TOC_END -->

## 안건 1: 문제 정의
- Status: DONE
- 요약:
  - 기존 checkout 좌석 조회는 `AVAILABLE` 중심이라, 예약(HOLD) 이후 좌석 상태/리스트 동기화가 사용자 관점에서 불안정하게 보일 수 있다.
  - 실무형 좌석맵은 `AVAILABLE/TEMP_RESERVED/RESERVED` 전체 상태를 기준으로 렌더링해야 한다.

## 안건 2: API 계약 정렬
- Status: DOING
- 결정:
  - 기존 `GET /api/concerts/options/{optionId}/seats`는 하위 호환 유지한다.
  - 신규 `GET /api/concerts/options/{optionId}/seat-map`를 도입해 전체 좌석 상태를 조회한다.
  - 필요 시 `status` 쿼리 파라미터로 상태 필터를 지원한다.

## 안건 3: 프론트 반영 원칙
- Status: DOING
- 결정:
  - checkout 모달은 seat-map API를 사용해 전체 좌석을 렌더링한다.
  - 선택 가능 좌석은 `AVAILABLE`로 제한하고, `TEMP_RESERVED/RESERVED`는 비활성 타일로 노출한다.
  - 예약 후 선택 리스트는 `holdRecords` 기준으로 유지하고 상태 라벨을 즉시 반영한다.

## 안건 4: 이슈/태스크 동기화
- Status: DOING
- 정책:
  - 동일 범위 후속작업은 기존 이슈에 누적한다(신규 이슈 생성 지양).
  - 연계 트래킹:
    - frontend: `https://github.com/rag-cargoo/ticket-web-app/issues/3`
    - backend: `https://github.com/rag-cargoo/ticket-core-service/issues/21`
  - sidecar task 항목 `TWA-SC-011`로 실행 상태를 관리한다.

## 안건 5: 후속 검증
- Status: TODO
- 체크:
  - [ ] backend compile (`./gradlew compileJava`)
  - [ ] frontend build (`npm run build`)
  - [ ] checkout 수동 시나리오(선택/예약/단건취소/전체취소/재선택) 회귀 확인
