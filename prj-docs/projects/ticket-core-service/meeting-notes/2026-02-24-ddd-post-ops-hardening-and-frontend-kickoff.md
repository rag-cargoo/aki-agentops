# Meeting Notes: DDD Post Ops-Hardening and Frontend Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-24 04:16:00`
> - **Updated At**: `2026-02-24 04:16:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 배경
> - 안건 2: 이번 범위(운영/고도화 7종)
> - 안건 3: 완료 기준
> - 안건 4: 추적 규칙
> - 안건 5: 전환 조건(프론트)
<!-- DOC_TOC_END -->

## 안건 1: 배경
- Status: DONE
- 배경:
  - DDD 리팩토링 핵심 경계(Phase8-A~I)는 완료되었고, 코드 레벨 의존성 지표도 목표값(0)으로 수렴했다.
  - 프론트 구현에 바로 착수하기 전에 운영 안정성과 검증 체인을 보강해야 이후 통합 비용을 줄일 수 있다.

## 안건 2: 이번 범위(운영/고도화 7종)
- Status: DOING
- 범위:
  - 1) Redis/Kafka 의존 통합테스트 환경 정리
  - 2) CI verify 확장(ArchUnit-only -> 핵심 회귀 포함)
  - 3) 성능 기준선 수립(k6 smoke + distributed)
  - 4) 관측성 강화(운영 로그/메트릭/가이드)
  - 5) 장애 대응 강화(재시도/백오프/운영 런북)
  - 6) 릴리즈 거버넌스 정리(검증 체인/보호 규칙)
  - 7) 최종 문서 정리(완료 회의록 + 지식문서 + 프론트 핸드오프)

## 안건 3: 완료 기준
- Status: DOING
- 기준:
  - 위 7개 항목 모두 코드/CI/문서 증빙이 존재해야 한다.
  - 각 항목은 최소 1개 이상의 검증 명령 PASS 로그를 확보해야 한다.
  - `task.md`의 `TCS-SC-027` 체크리스트를 `[x]`로 마감하고 제품 이슈 코멘트로 동기화한다.

## 안건 4: 추적 규칙
- Status: DONE
- 규칙:
  - 실행 순서는 `회의록 -> task -> 제품 이슈 -> 코드/검증`으로 고정한다.
  - 제품 레포 추적은 기존 이슈 `rag-cargoo/ticket-core-service#33`에 누적 코멘트 방식으로 유지한다.
  - 새 이슈는 범위가 분리될 때만 생성한다.

## 안건 5: 전환 조건(프론트)
- Status: TODO
- 조건:
  - 운영/고도화 7종 완료 후 `frontend` 페이즈 전환 회의록을 작성한다.
  - 전환 시점에 프론트 작업의 첫 배치를 `task.md` 신규 항목으로 등록한다.
