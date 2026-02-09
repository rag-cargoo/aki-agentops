# Core Responsibility Matrix

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-09 09:43:13`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 책임 분해 원칙
> - 책임 매트릭스
> - 호환성 규칙
> - 공존/이관 계획
<!-- DOC_TOC_END -->

> [!NOTE]
> 코어 스킬 분해 시 기존 기능을 유지하면서 책임을 분리하기 위한 기준 문서.

## 책임 분해 원칙
1. 허브(`aki-codex-core`)는 원칙/경계/완료 기준만 담당한다.
2. 실행 로직은 도메인별 스킬로 위임한다.
3. 기존 `workspace-governance`는 호환 레이어로 유지한다.

## 책임 매트릭스
- `aki-codex-core`
  - 전역 원칙
  - 분해/통합 기준
  - 완료 정의
- `aki-codex-session-reload`
  - 세션 시작/리로드
  - Active Project 점검/복구
  - 런타임 스냅샷 확인
- `aki-codex-precommit`
  - quick/strict 모드 운영
  - 정책 체인 검증
  - strict 차단 규칙 적용

## 호환성 규칙
1. `workspace-governance`를 즉시 제거하지 않는다.
2. 동일 규칙이 두 곳에 존재할 때는 실행 스킬(세션/프리커밋)을 소스로 간주한다.
3. 신규 문서는 가급적 새 코어 스킬에 추가하고, 기존 스킬에는 링크만 보강한다.

## 공존/이관 계획
1. 1단계(현재):
   - `workspace-governance`는 허브로 유지
   - 코어 실행 규칙은 `aki-codex-session-reload`, `aki-codex-precommit`으로 분리
2. 2단계:
   - 운영 문서의 실행 경로를 코어 모듈 기준으로 순차 이관
   - `workspace-governance`에는 요약/링크 중심으로만 유지
3. 3단계:
   - 중복 규칙이 제거되고 참조 경로가 안정화되면 최소 허브 형태로 고정
4. 완료 판정:
   - 사이드바 링크 동기화
   - 세션 리로드/프리커밋 체인 검증 통과
   - 회의록/이슈 상태 동기화
