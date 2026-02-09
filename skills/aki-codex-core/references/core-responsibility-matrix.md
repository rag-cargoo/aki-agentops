# Core Responsibility Matrix

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-09 08:22:19`
> - **Updated At**: `2026-02-10 02:01:49`
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
3. 규칙/운영 문서는 소유 스킬(`aki-codex-core`, `aki-codex-session-reload`, `aki-codex-precommit`, `aki-codex-workflows`, `aki-github-pages-expert`)에 직접 배치한다.

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
- `aki-codex-workflows`
  - 크로스 스킬 실행 순서(Trigger/Why/Order/Condition/Done)
  - 단계별 Owner Skill 명시
  - Done 판정(Completion/Verification/Evidence)

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
