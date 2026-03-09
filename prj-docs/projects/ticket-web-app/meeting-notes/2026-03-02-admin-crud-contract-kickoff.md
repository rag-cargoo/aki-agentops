# Meeting Notes: Admin CRUD Contract Alignment Kickoff

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-02 06:10:00`
> - **Updated At**: `2026-03-02 10:05:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 이슈/브랜치 분리
> - 안건 2: 문제 정의
> - 안건 3: 구현 범위
> - 안건 4: 완료 기준
> - 안건 5: 실행 순서
<!-- DOC_TOC_END -->

## 안건 1: 이슈/브랜치 분리
- Status: DONE
- 이슈:
  - `https://github.com/rag-cargoo/ticket-web-app/issues/13`
- 브랜치:
  - `feat/twa-admin-crud-hardening-20260301`
- 메모:
  - 기존 `#3`, `#9`는 서비스/실시간 사용자 플로우 중심이므로 재오픈하지 않고 Admin CRUD 계약 정렬을 별도 트래킹으로 분리한다.

## 안건 2: 문제 정의
- Status: CONFIRMED
- 요약:
  - Admin 화면의 콘서트/옵션 CRUD에서 노출 필드가 축약되어 운영 데이터 확인성이 낮다.
  - 프론트 입력 필드와 백엔드 계약이 일부 불일치해 저장값/표시값 신뢰성이 떨어진다.
  - 이미지 업로드는 존재하지만 등록 플로우와 분리되어 관리 UX가 끊긴다.

## 안건 3: 구현 범위
- Status: DONE
- 범위:
  - 콘서트 테이블/상세 폼에 계약 필드 확장(artist/promoter/sale/runtime 관련 표시 포함).
  - 옵션 테이블/폼에 일정/가격/venue 관련 필드 확장.
  - 요청/응답 파서를 백엔드 실제 DTO 필드와 일치하도록 정렬.
  - thumbnail 업로드를 등록/수정 운영 흐름에서 일관되게 사용할 수 있도록 UX 정리.
  - Artist/Promoter/Venue를 검색형 카탈로그 선택 UX로 전환.
  - Genre 고정(`K-POP`) 및 Promoter 국가코드 자동 반영 정책 적용.

## 안건 4: 완료 기준
- Status: AGREED
- 기준:
  - Admin에서 생성/조회/수정/삭제 시 입력 필드와 표시 필드가 계약과 1:1로 대응한다.
  - UI가 실제 저장되지 않는 값을 저장된 것처럼 보여주지 않는다.
  - typecheck/build 통과 + 주요 CRUD 수동 시나리오 점검 로그를 남긴다.

## 안건 5: 실행 순서
- Status: AGREED
- 순서:
  - 1) API client 타입/파서/요청 body 계약 정렬
  - 2) AdminPage 폼/테이블 필드 확장 및 UX 정리
  - 3) 검증(typecheck/build + 수동 시나리오) 및 sidecar evidence 업데이트

## 실행 결과 (2026-03-02)
- Issue/PR:
  - issue: `https://github.com/rag-cargoo/ticket-web-app/issues/13` (closed)
  - PR: `https://github.com/rag-cargoo/ticket-web-app/pull/14` (merged)
  - merge commit: `4debe2c7f32e9cd56cad797594c30d835282fa5b`
- 검증:
  - `npm run typecheck` PASS
  - `npm run lint` PASS
  - `npm run build` PASS
- 핵심 반영:
  - Admin concert/option CRUD 계약 정렬 완료
  - 등록/수정 썸네일 multipart 업로드 연계 유지
  - Service checkout의 회차 상한을 sales policy(`maxReservationsPerUser`) 기준으로 동기화
