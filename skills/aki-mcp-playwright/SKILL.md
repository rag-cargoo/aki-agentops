---
name: aki-mcp-playwright
description: 코드 작성 없이 Playwright MCP 도구로 Linux/WSL 브라우저 자동화 환경을 설치, 검증, 장애대응하는 표준 워크플로우. 새 PC에 세팅할 때, 브라우저 창이 바로 닫히는 문제를 디버깅할 때, GUI 실행은 되는데 MCP 제어가 실패할 때, 또는 팀 공용 runbook을 갱신할 때 사용한다.
---

# MCP Playwright

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-10 04:10:14`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 오케스트레이션 경계
> - 기본 원칙
> - 실행 절차
> - 핵심 구분
> - 산출물 규칙
> - 리소스 안내
> - 운영 원칙
> - 로컬 실행 계약
<!-- DOC_TOC_END -->

## 목표

- Linux/WSL에서 Playwright MCP를 재현 가능하게 세팅한다.
- 코드 없이 MCP 도구만으로 브라우저 제어를 검증한다.
- "MCP 제어 경로"와 "사용자 화면 GUI 경로"를 분리해 원인을 빠르게 좁힌다.

## 오케스트레이션 경계

- 이 스킬은 Playwright MCP 설치/진단/실행 검증 도메인만 담당한다.
- 크로스 스킬 호출 순서/분기/종료판정은 `aki-codex-workflows` 문서를 권위 소스로 따른다.

## 기본 원칙

- 기본 경로는 MCP-only다. Node Playwright 코드 실행을 전제하지 않는다.
- 로컬 코드 기반 Playwright 테스트는 별도 요구가 있을 때만 추가한다.
- GUI 성공과 MCP 성공을 동일시하지 않는다.
- 설치 기본값은 `no-install`이다. 명시 요청 없이는 패키지/브라우저를 설치하지 않는다.
- 설치 정책은 `MCP_INSTALL_POLICY`로 제어한다.
  - `forbid`(기본): 설치 금지. 기존 브라우저만 사용
  - `allow`: 사용자가 설치를 요청한 경우에만 설치 수행
- 브라우저 경로가 커스텀이면 `MCP_BROWSER_BIN=<binary>`를 사용한다.

## 실행 절차

1. `scripts/diagnose_playwright_mcp.sh`로 환경을 먼저 진단한다.
2. `MCP_INSTALL_POLICY` 기준으로 설치 허용 여부를 먼저 판정한다.
3. 필요 시에만 `references/setup-linux-wsl.md`의 설치 레시피를 사용한다.
4. GUI 창 유지 검증은 `scripts/chrome_gui_smoke.sh <url>`로 수행한다.
5. MCP 도구로 `navigate -> snapshot -> click/type -> screenshot` 순서로 검증한다.
6. 실패 시 `references/troubleshooting.md`에서 증상별 원인을 찾아 교정한다.

## 핵심 구분

- GUI 검증:
  - 실제 사용자 화면에 브라우저가 뜨는지 확인한다.
  - WSLg, `DISPLAY`, 셸 종료 시그널(`SIGHUP`) 영향을 점검한다.
- MCP 검증:
  - MCP 도구로 `navigate`, `snapshot`, `click`, `type`를 순차 실행해 세션 안정성을 본다.
  - GUI 성공과 MCP 성공을 동일시하지 않는다.

## 산출물 규칙

- 설치/수정 작업 후 반드시 아래 4개를 남긴다.
  - OS/WSL 정보
  - 브라우저 버전
  - MCP 기능 점검 결과
  - 남은 리스크와 재현 명령

## 리소스 안내

- 설치 가이드: `references/setup-linux-wsl.md`
- 장애 대응: `references/troubleshooting.md`
- 환경 점검: `scripts/diagnose_playwright_mcp.sh`
- GUI 실행 점검: `scripts/chrome_gui_smoke.sh`

## 운영 원칙

- 설치 단계와 검증 단계를 섞지 않는다.
- 실패 메시지는 원문 그대로 보존하고, 해석은 별도로 기록한다.
- 배포/CI 환경에서는 MCP 경로 검증과 GUI 경로 검증을 분리한다.

## 로컬 실행 계약

- Input:
  - 대상 환경(OS/WSL), 설치 정책(`MCP_INSTALL_POLICY`), 브라우저 경로(선택)
- Output:
  - 진단 결과, GUI/MCP 검증 결과, 재현 명령
- Success:
  - 환경 진단 통과 + GUI/MCP 검증 절차 수행 완료
- Failure:
  - 실패 로그/증상 분류를 보존하고 `references/troubleshooting.md` 기준 교정 후 재시도
