# Meeting Notes: KPOP20 Seed JSON Dataset Externalization Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 01:28:00`
> - **Updated At**: `2026-03-01 01:28:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: 목표/범위
> - 안건 2: 구현 원칙
> - 안건 3: 진행 현황
> - 안건 4: 검증/수용 기준
> - 안건 5: 연계 트래킹
<!-- DOC_TOC_END -->

## 안건 1: 목표/범위
- Status: DOING
- 목표:
  - KPOP20 더미 데이터셋을 스크립트 heredoc 하드코딩에서 JSON 외부 파일로 분리한다.
  - URL/아티스트/좌석/상태 수정 및 신규 콘서트 추가를 JSON 변경만으로 처리 가능하게 만든다.
- 범위:
  - `setup-kpop20-demo-data.sh` 데이터 로딩 경로만 변경
  - 운영 도메인/예약/실시간/결제 로직은 비변경

## 안건 2: 구현 원칙
- Status: DONE
- 원칙:
  - 운영 경로 침범 금지: 데모 시드 스크립트 범위만 수정
  - 스키마 검증 필수: JSON 배열/필수 필드(`artist`, `entertainment`, `youtubeUrl`, `seatCount`, `saleBucket`) 체크
  - 데이터 소스 외부화: `DATASET_FILE` env로 파일 교체 가능하게 구성

## 안건 3: 진행 현황
- Status: DOING
- 반영:
  - 신규 파일: `scripts/api/data/kpop20-demo-dataset.json` (24개 콘서트)
  - `setup-kpop20-demo-data.sh`:
    - heredoc dataset 제거
    - `DATASET_FILE` 기반 JSON 순회 시드로 전환
    - JSON 스키마 검증 추가
  - 최근 요청 URL 반영:
    - LE SSERAFIM: `https://youtu.be/hLvWy2b857I?si=aS73yFYIc0l53Cyo`
    - TOMORROW X TOGETHER: `https://youtu.be/C0EYKxF1oTI?si=p6Wn2VSfC2R0jNPX`

## 안건 4: 검증/수용 기준
- Status: DOING
- 완료된 검증:
  - `bash -n scripts/api/setup-kpop20-demo-data.sh` PASS
  - `jq` 스키마 검증 PASS
- 수용 기준:
  - JSON 값 변경만으로 URL/건수/상태 수정 가능
  - JSON 객체 추가만으로 신규 콘서트 시드 가능
  - 운영 프로파일 기본 동작 영향 없음

## 안건 5: 연계 트래킹
- Status: DONE
- issue: `https://github.com/rag-cargoo/ticket-core-service/issues/59`
- branch: `feat/issue-59-seed-json-dataset`
- task: `prj-docs/projects/ticket-core-service/task.md` (`TCS-SC-034`)
