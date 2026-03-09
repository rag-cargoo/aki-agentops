---
name: aki-mcp-figma
description: |
  Figma MCP 통합 운영 스킬.
  Figma remote/desktop MCP endpoint 연결 점검, 디자인 구현 전 선행 조건 확인, 세션 재시작/복구 지침을 표준화한다.
  Figma 링크 기반 UI 구현을 시작하거나 Figma MCP 연결 장애를 점검해야 할 때 사용한다.
---

# Aki MCP Figma

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 15:45:00`
> - **Updated At**: `2026-02-19 15:45:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 오케스트레이션 경계
> - 기본 원칙
> - 실행 절차
> - 운영 모드
> - 운영 스크립트
> - 로컬 실행 계약
> - 참고 문서
<!-- DOC_TOC_END -->

## 목표
- Figma MCP(remote/desktop) 연결 상태를 일관된 절차로 점검한다.
- 디자인 구현 시작 전 MCP 연결/노드 접근 선행 조건을 표준화한다.
- Figma MCP 장애 시 즉시 분류(엔드포인트, 앱 실행, 인증)하고 복구 시간을 줄인다.

## 오케스트레이션 경계
- 이 스킬은 Figma MCP 도메인 실행(연결 점검/초기화/장애 대응)만 담당한다.
- 세션 공통 동기화(`~/.codex/config.toml` 템플릿 반영)는 `aki-codex-session-reload`가 담당한다.
- 크로스 스킬 호출 순서/분기/완료판정은 `aki-codex-workflows` 문서를 권위 소스로 따른다.

## 기본 원칙
1. Figma 디자인 구현 요청 시 먼저 MCP 연결 상태를 확인한다.
2. remote(`https://mcp.figma.com/mcp`)와 desktop(`http://127.0.0.1:3845/mcp`)를 분리해 판단한다.
3. desktop 모드는 Figma Desktop 앱 실행 여부를 반드시 확인한다.
4. 인증/권한 이슈는 연결 가용성 점검과 분리해 보고한다.
5. 민감정보(토큰)는 스킬/레포에 저장하지 않고 환경변수로만 주입한다.

## 실행 절차
1. MCP config bootstrap 상태 확인
   - Owner Skill: `aki-codex-session-reload`
   - `sync_mcp_config.sh --mode guide` 결과에서 누락 섹션을 확인한다.
2. endpoint 연결 점검
   - Owner Skill: `aki-mcp-figma`
   - `scripts/probe_figma_mcp.sh --server all` 실행으로 remote/desktop 가용성을 확인한다.
3. 장애 분기
   - Owner Skill: `aki-mcp-figma`
   - desktop down이면 앱 실행/포트 점검, remote down이면 네트워크/정책 점검으로 분기한다.
4. 구현 단계 전달
   - Owner Skill: `aki-codex-workflows`
   - 연결 상태가 정상이면 Figma 구현 스킬(`figma-implement-design`)로 전달한다.

## 운영 모드
1. `figma` (remote):
   - 장점: 환경 독립적, 파일 링크 기반 협업
   - 주의: 인증/권한 구성 필요
2. `figma-desktop` (local):
   - 장점: 현재 선택 노드 기반 작업 가능
   - 주의: 로컬 앱 실행 + 127.0.0.1:3845 endpoint 필요

## 운영 스크립트
1. endpoint probe:
   - `scripts/probe_figma_mcp.sh`
2. 공통 config sync(소유: session-reload):
   - `skills/aki-codex-session-reload/scripts/codex_skills_reload/sync_mcp_config.sh`

## 로컬 실행 계약
- Input:
  - 서버 대상(`figma|figma-desktop|all`), 환경(endpoint override 선택)
- Output:
  - endpoint별 reachability, HTTP code, 조치 가이드
- Success:
  - 필요한 endpoint가 reachable 상태이며 후속 구현 단계로 전달 가능
- Failure:
  - unreachable endpoint와 원인 분류(앱 미기동/포트 미개방/네트워크)를 보고하고 중단

## 참고 문서
1. Init Guide:
   - `references/init.md`
2. Troubleshooting:
   - `references/troubleshooting.md`
