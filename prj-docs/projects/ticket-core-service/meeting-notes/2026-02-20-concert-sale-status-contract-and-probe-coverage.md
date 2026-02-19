# Meeting Notes: Concert Sale Status Contract and Probe Coverage (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 03:46:00`
> - **Updated At**: `2026-02-20 04:30:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 목록 응답 판매상태 계약
> - 안건 2: API Probe 커버리지
> - 안건 3: 문서 동기화
> - 안건 4: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 목록 응답 판매상태 계약
- Status: DONE
- 결정사항:
  - `GET /api/concerts`, `GET /api/concerts/search`가 프론트 예매 CTA 제어에 필요한 상태 필드를 직접 제공한다.
  - 오픈 임계 구간은 `1시간 전`, `5분 전`을 구분한다.
- 처리결과:
  - DTO/서비스/컨트롤러 반영 완료
  - 상태값: `UNSCHEDULED`, `PREOPEN`, `OPEN_SOON_1H`, `OPEN_SOON_5M`, `OPEN`, `SOLD_OUT`

## 안건 2: API Probe 커버리지
- Status: DONE
- 처리계획:
  - `scripts/http/concert.http`에 판매 정책 전환 및 `saleStatus` 확인 시나리오 추가
  - `scripts/api/v15-concert-sale-status-contract.sh`를 신규 추가해 자동 계약 검증
- 처리결과:
  - `concert.http` 시나리오 반영 완료
  - `v15-concert-sale-status-contract.sh` 추가 및 PASS 검증 완료 (`API_HOST=http://127.0.0.1:18081`)

## 안건 3: 문서 동기화
- Status: DONE
- 처리계획:
  - API 명세(`concert-api.md`)와 API 테스트 가이드(`api-test/README.md`)를 새 계약 기준으로 갱신
- 처리결과:
  - `concert-api.md` 신규 필드/상태 규칙 반영 완료
  - `api-test/README.md` 기본 세트(`v1~v15`) 및 v15 섹션 반영 완료

## 안건 4: 이슈/태스크 동기화
- Status: DONE
- 처리결과:
  - Product Issue 생성: `rag-cargoo/ticket-core-service#15`
  - URL: `https://github.com/rag-cargoo/ticket-core-service/issues/15`
  - 진행 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/15#issuecomment-3929234804`
  - sidecar task에서 `TCS-SC-017`을 `DONE`으로 고정
