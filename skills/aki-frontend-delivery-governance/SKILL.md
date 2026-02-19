---
name: aki-frontend-delivery-governance
description: |
  프론트엔드 구현을 기능 단위로 분해하고, 프로젝트 sidecar(prj-docs) 문서/Playwright 재검증 흐름을 표준화하는 전역 스킬.
  특정 서비스에 종속되지 않으며, 신규/기존 프론트 프로젝트에서 동일한 문서화·시연·로그 증빙 규칙을 적용할 때 사용한다.
---

# Aki Frontend Delivery Governance

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 21:05:00`
> - **Updated At**: `2026-02-19 21:05:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 오케스트레이션 경계
> - 전역 규칙
> - 프로젝트 분리 원칙
> - 구현 분해 규칙
> - Playwright 시연 계약
> - 장기 공백 리마인더
> - 로그 증빙 계약
> - 산출물 규칙
> - 로컬 실행 계약
> - 참고 문서
<!-- DOC_TOC_END -->

## 목표
- 프론트 개발 규칙을 `aki-*` 전역 스킬로 고정해 특정 서비스 종속을 방지한다.
- 기능 명세/진행 TODO/회의록/검증 가이드를 `prj-docs/projects/<service>`에 표준 구조로 축적한다.
- Codex 사용자가 Playwright 테스트를 파트별/전체로 선택 실행하고, 콘솔 로그/검증 근거를 동일 포맷으로 확인하게 한다.

## 오케스트레이션 경계
- 이 스킬은 프론트 구현 운영 규칙(분해/문서화/검증)을 담당한다.
- 세션 리로드/Active Project 전환은 `aki-codex-session-reload`를 따른다.
- Playwright MCP 설치/환경 진단은 `aki-mcp-playwright`를 따른다.

## 전역 규칙
1. 이 스킬은 서비스 비종속(global) 규칙으로 유지한다.
2. 서비스 전용 요구사항은 Active Project sidecar 문서(`prj-docs/projects/<service>/*`)에 기록한다.
3. 프론트 구현은 최소 아래 4영역으로 분해한다.
   - Layout/Navigate
   - API Contract Adapter
   - Realtime Adapter
   - UX State/Error Handling
4. 각 영역은 `기능 설명 + 테스트 범위 + 검증 근거`를 한 세트로 남긴다.

## 프로젝트 분리 원칙
1. 글로벌 규칙/공통 실행 절차:
   - `skills/aki-frontend-delivery-governance/*`
2. 프로젝트별 기능/결정/TODO/회의록:
   - `prj-docs/projects/<service>/*`
3. 제품 코드/실제 테스트 실행:
   - `workspace/apps/frontend/<service>` (외부 제품 레포)

## 구현 분해 규칙
1. 기능 상세 문서에는 아래 5항목을 고정 포함한다.
   - 목적(Why)
   - 사용자 플로우(How)
   - API 연동 지점(Contract)
   - 실패/복구 전략(Error/Fallback)
   - 검증 시나리오(Playwright Scope)
2. 태스크 보드는 `[ ]/[~]/[x]/[!]` 상태를 유지한다.
3. 회의록 결정사항은 같은 날 태스크/이슈 상태에 즉시 동기화한다.

## Playwright 시연 계약
1. 테스트 목록은 실행 전에 반드시 제시한다.
   - 예: `smoke`, `nav`, `contract`, `all`
2. 사용자가 범위를 지정하면 해당 범위만 실행한다.
3. 사용자가 지정하지 않으면 목록을 보여주고 선택을 받는다.
4. 실행은 아래 공통 래퍼를 기본으로 사용한다.
   - `./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --list`
   - `./skills/aki-frontend-delivery-governance/scripts/run-playwright-suite.sh --project-root <path> --scope <scope>`

## 장기 공백 리마인더
1. 프론트 Active Project 상태에서 `session_start.sh` 실행 시 Frontend Quick Remind를 자동 노출한다.
2. 사용자 복귀 프롬프트는 아래 문구를 기준으로 한다.
   - `프론트 Playwright 테스트 목록 보여주고 scope별로 실행해줘`
3. 장기 공백 복귀용 1페이지 카드는 아래 문서를 사용한다.
   - `prj-docs/references/frontend-long-gap-recall-card.md`

## 로그 증빙 계약
1. 기본 증빙은 텍스트다.
   - Playwright run log
   - 브라우저 console log
   - 실패 스택/trace 경로
2. 스크린샷은 사용자 요청 시에만 제공한다.
3. 실행 결과는 `.codex/tmp/frontend-playwright/<service>/<run-id>/`에 저장한다.

## 산출물 규칙
- 작업 후 아래 3가지를 함께 남긴다.
  1. sidecar 기능 문서 갱신
  2. sidecar task/meeting-notes 동기화
  3. Playwright 실행 로그 경로 및 판정

## 로컬 실행 계약
- Input:
  - Active frontend project root
  - 실행 scope(`smoke`/`nav`/`contract`/`all`)
- Output:
  - 테스트 실행 로그, 콘솔 로그, 요약 리포트
- Success:
  - 선택한 scope 실행 성공 + 근거 경로 기록 완료
- Failure:
  - 실패 scope/원인/재시도 명령을 sidecar task 또는 meeting note에 기록

## 참고 문서
- Playwright 분할 실행 가이드: `references/playwright-partition-runbook.md`
- Sidecar 문서 작성 계약: `references/sidecar-frontend-docs-contract.md`
