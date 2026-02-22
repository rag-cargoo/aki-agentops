# Meeting Notes: Domain Association + QueryDSL Admin CRUD Plan (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-22 23:59:50`
> - **Updated At**: `2026-02-23 05:48:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 도메인 의미 재정의
> - 안건 2: 연관관계(JPA/Data JPA) 안전 규칙
> - 안건 3: 코드 점검 결과
> - 안건 4: QueryDSL 적용 범위
> - 안건 5: 구현 단계(Phase)
> - 안건 6: 이슈/태스크 동기화
> - 안건 7: Phase B 1차 구현 결과
> - 안건 8: Phase B 2차 구현 결과(도메인 분리 + Admin CRUD 골격)
> - 안건 9: Phase B 3차 구현 결과(프론트 계약 정합: 썸네일/가격/미디어)
<!-- DOC_TOC_END -->

## 안건 1: 도메인 의미 재정의
- Status: DONE
- 결정사항:
  - 현재 코드의 `Agency`는 사실상 아티스트 `소속사(Entertainment)` 의미로 사용되고 있다.
  - 운영 모델에서는 `공연 기획사(Promoter)`를 분리 도메인으로 추가한다.
  - `Venue`(공연장) 도메인을 추가하고, 공연장 선택은 `ConcertOption(회차)` 단위로 관리한다.
- 관계 목표:
  - `Entertainment 1:N Artist`
  - `Promoter 1:N Concert`
  - `Concert 1:N ConcertOption`
  - `Venue 1:N ConcertOption`
  - `Concert N:M Artist`는 확장 목표로 두고, 1차는 단일 아티스트 모델과 호환 전개한다.

## 안건 2: 연관관계(JPA/Data JPA) 안전 규칙
- Status: DONE
- 규칙:
  - FK 소유는 `@ManyToOne` + `@JoinColumn` 기준으로 고정한다.
  - 컬렉션(`@OneToMany`)은 `mappedBy` 읽기 보조로만 사용한다.
  - 연관 기본 fetch는 `LAZY`를 유지한다.
  - `cascade`/`orphanRemoval`은 aggregate 경계 내부에서만 제한 사용한다.
  - API 응답은 DTO로만 노출하고 엔티티 직접 직렬화를 금지한다.
- 보강 규칙:
  - 필수 FK는 `optional=false`와 DB `NOT NULL/FK` 제약을 함께 적용한다.
  - 양방향 매핑 시 편의 메서드로 양쪽 상태를 동기화한다.
  - `equals/hashCode/toString`에 연관 필드를 포함하지 않는다.

## 안건 3: 코드 점검 결과
- Status: DONE
- 핵심 발견:
  - `Artist -> Agency` 소속 구조는 이미 존재한다.
  - `Concert -> Artist`, `Concert -> ConcertOption`, `Seat -> ConcertOption` 구조는 존재한다.
  - `Promoter`/`Venue` 도메인은 현재 부재다.
  - `main` 기준 `/api/admin/concerts/**` 운영 CRUD 경로는 부재다.
  - `DataInitializer`는 admin 계정 1건만 생성하며 운영 시드가 없다.

## 안건 4: QueryDSL 적용 범위
- Status: DONE
- 확인:
  - QueryDSL 의존/apt/generated source 설정은 이미 빌드 파일에 존재한다.
- 적용 계획:
  - 1차: `Agency/Artist` Admin 목록용 `find/search/paging/sort`를 QueryDSL custom repository로 구현한다.
  - 2차: `Concert Admin` 목록/필터(아티스트/기획사/상태/날짜 범위) 조회에 QueryDSL을 확장한다.
  - 3차: `Venue/Promoter` 도메인 도입 후 통합 검색 조건을 QueryDSL로 단일화한다.

## 안건 5: 구현 단계(Phase)
- Status: DOING
- Phase A (진행중):
  - 도메인 연관관계/의미 점검 완료
  - Admin API 경로 불일치 지점(`ticket-web-client` 계약 vs `ticket-core-service main`) 확정
- Phase B (다음):
  - `/api/admin/concerts/**` 운영 CRUD 복구(콘서트/회차/판매정책/썸네일)
  - `Agency/Artist` QueryDSL 검색/페이지네이션 도입(1차 완료)
  - `Entertainment/Promoter/Venue` 분리 및 Admin CRUD 골격 도입(2차 완료)
- Phase C:
  - `Promoter`/`Venue` 계약 안정화(프론트 연동/검증) + 계약 마이그레이션
  - 초기 시드 전략(dev/demo profile + idempotent marker) 고정

## 안건 6: 이슈/태스크 동기화
- Status: DONE
- 처리결과:
  - Product Issue `#16` 재오픈 트랙에 본 설계 결정을 진행 코멘트로 누적한다.
  - Sidecar task `TCS-SC-025`를 `DOING`으로 전환한다.
- 링크:
  - `https://github.com/rag-cargoo/ticket-core-service/issues/16`
  - `https://github.com/rag-cargoo/ticket-core-service/issues/16#issuecomment-3941623654`
  - `https://github.com/rag-cargoo/ticket-core-service/issues/16#issuecomment-3941631467`
  - `https://github.com/rag-cargoo/ticket-core-service/issues/16#issuecomment-3941655066`

## 안건 7: Phase B 1차 구현 결과
- Status: DONE
- 구현:
  - `Agency/Artist` QueryDSL custom repository를 추가했다.
  - Admin 조회 API를 확장했다:
    - `GET /api/agencies/search`
    - `GET /api/artists/search`
  - 페이징 응답 DTO를 추가했다:
    - `AgencySearchPageResponse`
    - `ArtistSearchPageResponse`
- 검증:
  - `./gradlew compileJava` PASS
  - `./gradlew test --tests '*Agency*' --tests '*Artist*'`는 기존 Redis 통합테스트 환경 의존으로 실패(`RedisConnectionException`)

## 안건 8: Phase B 2차 구현 결과(도메인 분리 + Admin CRUD 골격)
- Status: DONE
- 구현:
  - 도메인 추가:
    - `Promoter`(공연 기획사)
    - `Venue`(공연장)
  - 연관관계 확장:
    - `Concert -> Promoter (ManyToOne)`
    - `ConcertOption -> Venue (ManyToOne)`
  - Admin API 골격 추가:
    - `GET/POST/PUT/DELETE /api/admin/entertainments/**`
    - `GET/POST/PUT/DELETE /api/admin/promoters/**`
    - `GET/POST/PUT/DELETE /api/admin/venues/**`
    - `POST/GET/PUT/DELETE /api/admin/concerts/**`
    - `POST/PUT/DELETE /api/admin/concerts/options/**`
    - `PUT /api/admin/concerts/{concertId}/sales-policy`
  - 호환성:
    - `admin-concert-client`의 기존 name 기반 payload와 신규 id 기반 payload를 모두 처리하도록 fallback 로직을 적용했다.
- 검증:
  - `./gradlew compileJava` PASS
  - `./gradlew test --tests '*ReservationStateMachineTest' --tests '*SeatSoftLockServiceImplTest'` PASS

## 안건 9: Phase B 3차 구현 결과(프론트 계약 정합: 썸네일/가격/미디어)
- Status: DONE
- 구현:
  - `Concert` 도메인에 운영 미디어 필드를 추가했다.
    - `youtubeVideoUrl`
    - `thumbnailBytes` + `thumbnailContentType` + `thumbnailUpdatedAt`
  - Admin 콘서트 업서트 요청에 `youtubeVideoUrl` 및 아티스트/엔터테인먼트 메타 필드를 반영했다.
  - Admin 썸네일 경로를 구현했다.
    - `POST /api/admin/concerts/{concertId}/thumbnail` (multipart `image`)
    - `DELETE /api/admin/concerts/{concertId}/thumbnail`
  - 공개 썸네일 조회 경로를 구현했다.
    - `GET /api/concerts/{concertId}/thumbnail`
  - 콘서트 회차 가격 계약을 반영했다.
    - `ticketPriceAmount` 필드 도입(`AdminConcertOptionCreate/UpdateRequest`, `ConcertOption`, `ConcertOptionResponse`)
    - 옵션 가격 미설정 시 기존 `payment.default-ticket-price-amount`를 fallback으로 유지
- 검증:
  - `./gradlew compileJava` PASS
  - `./gradlew test --tests '*ReservationStateMachineTest' --tests '*SeatSoftLockServiceImplTest' --tests '*ReservationLifecycleServiceIntegrationTest'` PASS

## 증빙
- 엔티티/서비스:
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/artist/Artist.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/concert/entity/Concert.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/concert/entity/ConcertOption.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/concert/entity/Seat.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/domain/concert/service/ConcertServiceImpl.java`
- API 계층:
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/ConcertController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/AdminConcertController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/EntertainmentController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/PromoterController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/VenueController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/AgencyController.java`
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/api/controller/ArtistController.java`
- 런타임/빌드:
  - `workspace/apps/backend/ticket-core-service/src/main/java/com/ticketrush/DataInitializer.java`
  - `workspace/apps/backend/ticket-core-service/build.gradle`
- 프론트 관리자 계약:
  - `workspace/apps/frontend/ticket-web-client/src/shared/api/admin-concert-client.ts`
