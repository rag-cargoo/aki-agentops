# Meeting Notes: Frontend Readiness and Implementation Deferral (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-18 09:30:00`
> - **Updated At**: `2026-02-23 06:31:07`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 현재 명세 기반 프론트 개발 가능 범위
> - 안건 2: 출시 기준 필수 항목 정리
> - 안건 3: 구현 보류 및 재검토 결정
<!-- DOC_TOC_END -->

## 안건 1: 현재 명세 기반 프론트 개발 가능 범위
- Created At: 2026-02-18 09:30:00
- Updated At: 2026-02-18 09:30:00
- Status: DONE
- 결정사항:
  - 현재 API 명세로 프론트 1차 구현(MVP)은 진행 가능하다.
  - `User/Entertainment/Artist/Concert` CRUD 및 기본 예약 흐름 연동은 가능하다.
  - 단, 운영/출시 수준 기준으로는 추가 계약 정의가 필요하다.

## 안건 2: 출시 기준 필수 항목 정리
- Created At: 2026-02-18 09:30:00
- Updated At: 2026-02-18 09:30:00
- Status: DONE
- 결정사항:
  - 결제/환불/보유머니 원장(정합성, 멱등성 포함)은 필수다.
  - OAuth/JWT 토큰 만료/재발급/로그아웃 무효화 규칙은 필수다.
  - 예약 대기열 SSE/폴링 이벤트 스펙과 에러 코드 표준은 필수다.
  - 시간대/만료 시각 규칙(UTC/KST)과 권한 경계(공개/인증/관리자) 명세가 필요하다.

## 안건 3: 구현 보류 및 재검토 결정
- Created At: 2026-02-18 09:30:00
- Updated At: 2026-02-18 09:30:00
- Status: DONE
- 결정사항:
  - 현재는 구현을 진행하지 않고 회의록만 기록한다.
  - 추후 재개 시 본 회의록을 기준으로 범위를 재확인한 뒤 착수한다.
  - 다음 재개 시에는 구현 전 회의록 기반으로 이슈/태스크를 재정렬한다.
