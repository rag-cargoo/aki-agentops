# Meeting Notes: Admin Operations CRUD and Media Pipeline Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-20 04:53:36`
> - **Updated At**: `2026-02-20 05:08:38`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 관리자 운영 CRUD 범위 확정
> - 안건 2: 미디어 입력/썸네일 파이프라인 정책 확정
> - 안건 3: 권한 경계/기존 setup API 운영 모드 정리
> - 안건 4: 이슈/태스크 동기화
<!-- DOC_TOC_END -->

## 안건 1: 관리자 운영 CRUD 범위 확정
- Created At: 2026-02-20 04:53:36
- Updated At: 2026-02-20 05:08:38
- Status: DONE
- 결정사항:
  - 운영 관리자 기준으로 `콘서트`, `세션/회차`, `가격 정책` CRUD를 API 1차 범위로 확정한다.
  - 현재 테스트 중심 `setup/cleanup` 엔드포인트와 분리된 운영 API 네임스페이스를 사용한다.
- 처리결과:
  - 운영 관리자 API 추가:
    - `POST/GET/PUT/DELETE /api/admin/concerts`
    - `POST /api/admin/concerts/{concertId}/options`
    - `PUT/DELETE /api/admin/concerts/options/{optionId}`
    - `PUT /api/admin/concerts/{concertId}/sales-policy`
  - 회차 가격 필드(`ticketPriceAmount`)를 옵션 응답/도메인에 반영
  - 예약 확정 결제금액이 회차 가격을 우선 사용하도록 연동 완료
  - 검증:
    - `./gradlew test` PASS
    - `AdminConcertControllerIntegrationTest` PASS
    - `ReservationLifecyclePricingIntegrationTest` PASS

## 안건 2: 미디어 입력/썸네일 파이프라인 정책 확정
- Created At: 2026-02-20 04:53:36
- Updated At: 2026-02-20 05:08:38
- Status: DONE
- 결정사항:
  - 영상 업로드는 제외하고 YouTube URL 입력만 지원한다.
  - 이미지 업로드는 `multipart/form-data`로 원본을 받되, 서버에서 썸네일 생성 후 URL/메타데이터를 저장한다.
- 처리결과:
  - 콘서트 엔티티에 YouTube URL + 원본/썸네일 메타데이터/바이너리 저장 필드 반영
  - 관리자 이미지 업로드:
    - `POST /api/admin/concerts/{concertId}/thumbnail` (`multipart/form-data`, `image`)
    - 서버에서 640x360 JPEG 썸네일 생성 후 저장
  - 공개 썸네일 조회:
    - `GET /api/concerts/{id}/thumbnail`
  - 목록/검색 응답에 `youtubeVideoUrl`, `thumbnailUrl` 필드 반영

## 안건 3: 권한 경계/기존 setup API 운영 모드 정리
- Created At: 2026-02-20 04:53:36
- Updated At: 2026-02-20 05:08:38
- Status: DOING
- 결정사항:
  - 관리자 CRUD는 `ROLE_ADMIN` 보호를 기본값으로 고정한다.
  - 기존 `setup/cleanup` 테스트 API는 `dev/test` 프로필 한정 또는 단계적 제거를 적용한다.
- 후속작업:
  - [x] `SecurityConfig`에 `/api/admin/**` `ROLE_ADMIN` 보호 반영
  - [x] 통합테스트에 관리자 권한 경계 회귀 추가 (`AdminConcertControllerIntegrationTest`)
  - [ ] 기존 `setup/cleanup` 경로를 dev/test 프로필 한정으로 축소
  - [ ] API 스크립트 기본 경로를 운영 관리자 API 기준으로 분리

## 안건 4: 이슈/태스크 동기화
- Created At: 2026-02-20 04:53:36
- Updated At: 2026-02-20 05:08:38
- Status: DONE
- 처리사항:
  - Product Issue 생성: `rag-cargoo/ticket-core-service#16`
  - URL: `https://github.com/rag-cargoo/ticket-core-service/issues/16`
  - 분리 근거:
    - 기존 `#15`는 목록 판매상태/카운트다운 계약 범위이며,
      관리자 운영 CRUD/미디어 파이프라인과 범위가 달라 신규 이슈로 분리
  - sidecar `task.md`에 `TCS-SC-019` TODO 등록
