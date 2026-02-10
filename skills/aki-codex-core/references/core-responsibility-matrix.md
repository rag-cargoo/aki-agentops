# Core Responsibility Matrix

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-10 04:07:22`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 책임 분해 원칙
> - 책임 매트릭스
> - 관리 범위 규칙
> - 호환성 규칙
> - 공존/이관 계획
<!-- DOC_TOC_END -->

> [!NOTE]
> 코어 스킬 분해 시 기존 기능을 유지하면서 책임을 분리하기 위한 기준 문서.

## 책임 분해 원칙
1. 허브(`aki-codex-core`)는 원칙/경계/완료 기준만 담당한다.
2. 실행 로직은 도메인별 스킬로 위임한다.
3. 규칙/운영 문서는 소유 스킬(`aki-codex-core`, `aki-codex-session-reload`, `aki-codex-precommit`, `aki-codex-workflows`, `aki-mcp-github`, `aki-meeting-notes-task-sync`, `aki-github-pages-expert`, `aki-mcp-playwright`)에 직접 배치한다.

## 책임 매트릭스
- `aki-codex-core`
  - 전역 원칙
  - 분해/통합 기준
  - 완료 정의
- `aki-codex-session-reload`
  - 세션 시작/리로드
  - Active Project 점검/복구
  - 런타임 스냅샷 확인
  - 세션 부트스트랩 훅 실행기(`run-skill-hooks.sh`, `runtime_orchestrator/engine.yaml`) 소유
- `aki-codex-precommit`
  - quick/strict 모드 운영
  - 정책 체인 검증
  - strict 차단 규칙 적용
- `aki-codex-workflows`
  - 크로스 스킬 실행 순서(Trigger/Why/Order/Condition/Done)
  - 단계별 Owner Skill 명시
  - Done 판정(Completion/Verification/Evidence)
  - 사용자 작업 오케스트레이션 문서 권위 소스
- `aki-mcp-github`
  - GitHub MCP 초기화(init)와 운영 subflow 실행
  - 이슈/PR/프로젝트/라벨 반영 및 링크 결과 보고
- `aki-meeting-notes-task-sync`
  - 회의록 후속작업의 `task.md` 동기화
  - TODO/DOING/DONE 상태 매핑 및 중복 방지
- `aki-github-pages-expert`
  - 문서 렌더링/무손실 검증
  - 사이드바/링크/Docsify 표시 품질 점검
- `aki-mcp-playwright`
  - Playwright MCP 설치/진단/GUI smoke 실행
  - 브라우저 자동화 런타임 안정성 점검

## 관리 범위 규칙
1. 코어 전역 관리 대상 스킬은 `aki-*` prefix를 기준으로 한다.
2. 비-`aki` 스킬은 기본적으로 프로젝트 위임 대상이며 전역 운영 규칙의 강제 대상이 아니다.
3. 비-`aki` 스킬의 사용 판단은 Active Project 문서(`PROJECT_AGENT.md`, `task.md`)에서 결정한다.
4. 세션 시작 보고는 `Managed(aki-*)`와 `Delegated(non-aki)`를 분리해 노출한다.

## 오케스트레이션 경계 규칙
1. `aki-codex-workflows`는 `When/Why/Order/Condition/Done`만 소유한다.
2. 각 도메인 스킬은 실행 계약(입력/출력/성공/실패)과 내부 로직만 소유한다.
3. 도메인 스킬 문서에 엔드투엔드 순서가 필요할 때는 "참조용 실행 예시"로 표시하고, 권위 소스는 `aki-codex-workflows`로 고정한다.
4. Owner Skill 없는 단계가 확인되면 `aki-codex-workflows`에서 Gap/Risk/Proposed Skill/Boundary/Trigger를 보고하고 스킬 신설을 권고한다.

## 호환성 규칙
1. 단일 소스 경로를 기준으로 중복 규칙 문서를 제거한다.
2. 동일 규칙이 두 곳에 존재할 때는 실행 스킬(세션/프리커밋)을 소스로 간주한다.
3. 신규 문서는 책임 스킬에 직접 추가하고, 허브 문서는 최소 링크로 유지한다.

## 공존/이관 계획
1. 완료 상태:
   - 레거시 거버넌스 자산 이관 완료
   - 세션/프리커밋/페이지스 운영 문서는 소유 스킬로 이동
2. 완료 판정:
   - 사이드바 링크 동기화
   - 세션 리로드/프리커밋 체인 검증 통과
   - 회의록/이슈 상태 동기화
