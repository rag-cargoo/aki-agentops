---
name: aki-github-mcp-bootstrap
description: |
  GitHub MCP 세션 부팅 스킬. 새 세션 시작 직후 GitHub MCP 기본 toolset(context, repos, issues, projects, pull_requests, labels)을 점검, 활성화, 재검증한다.
  GitHub 이슈/프로젝트/리포 작업 전에 "서버는 연결되지만 toolset이 비활성" 상태를 예방해야 할 때 사용한다.
---

# GitHub MCP Bootstrap

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 06:54:15`
> - **Updated At**: `2026-02-09 07:07:52`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 목표
> - 기본 프로필
> - 실행 절차
> - 검증 기준
> - 실패 대응
> - 보고 포맷
<!-- DOC_TOC_END -->

## 목표
- GitHub MCP 연결 직후 기본 작업 도구를 즉시 사용 가능한 상태로 만든다.
- 최소 권한 원칙을 유지하면서 세션 초반 재시도 비용을 줄인다.
- bootstrap 결과를 사용자에게 명시적으로 보고한다.

## 기본 프로필
- 기본 대상 toolset: `context`, `repos`, `issues`, `projects`, `pull_requests`, `labels`
- 오버라이드: `GITHUB_MCP_DEFAULT_TOOLSETS` 값이 있으면 해당 CSV 순서를 우선한다.
- 원칙: 이미 활성화된 toolset은 재활성화해도 무방하다(idempotent).

## 실행 절차
1. `mcp__github__list_available_toolsets`를 호출해 서버 응답과 전체 toolset 상태를 수집한다.
2. 대상 toolset 목록을 결정한다.
3. 각 대상 toolset을 순회한다.
4. `can_enable=true`이고 `currently_enabled=false`인 경우에만 `mcp__github__enable_toolset`를 호출한다.
5. `mcp__github__list_available_toolsets`를 다시 호출해 최종 상태를 재검증한다.
6. 대상별 결과(활성/이미활성/실패/미지원)를 표 형태로 요약해 사용자에게 보고한다.

## 검증 기준
- 성공 기준: 대상 toolset 전부 `currently_enabled=true`.
- 부분 성공 기준: 일부 실패가 있어도 bootstrap 결과를 즉시 보고하고 진행 가능 여부를 분리해서 안내한다.
- 차단 기준: `list_available_toolsets` 자체가 실패하면 GitHub MCP 작업을 보류하고 원인(인증/서버/권한)을 먼저 해결한다.

## 실패 대응
1. `list_available_toolsets` 실패:
   - GitHub MCP 서버/토큰/세션 상태를 먼저 점검한다.
   - 복구 전에는 GitHub 변경 작업을 시작하지 않는다.
2. 개별 toolset enable 실패:
   - 실패한 toolset만 보고하고, 성공한 toolset 범위 내 작업만 진행한다.
   - 실패 원인을 요약하고 재시도 조건을 함께 남긴다.
3. 대상 toolset이 목록에 없음:
   - 서버 버전 또는 권한 스코프 차이로 간주하고 "미지원"으로 보고한다.

## 보고 포맷
- `Bootstrap Target`: `context,repos,issues,projects,pull_requests,labels`
- `Enabled Now`: 이번에 활성화된 항목
- `Already Enabled`: 기존 활성 항목
- `Failed`: 실패 항목 + 원인 한 줄
- `Unsupported`: 목록 미노출 항목
- `Next`: 현재 세션에서 가능한 작업 범위를 한 줄로 확정
