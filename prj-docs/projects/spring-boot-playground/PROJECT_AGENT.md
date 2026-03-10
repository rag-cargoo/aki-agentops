# PROJECT_AGENT (spring-boot-playground sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-10 17:30:00`
> - **Updated At**: `2026-03-10 17:30:00`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Rules
> - Learning Contract
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `spring-boot-playground`의 sidecar 운영 규칙을 정의한다.
- 학습/실험 중심 Spring Boot 프로젝트의 실행 기준을 관리한다.

## Rules
- 최소 품질 게이트는 `./gradlew test`다.
- 학습 태스크 상태 변경은 `task.md`와 함께 갱신한다.
- 실험 결과/실패 원인은 `meeting-notes`에 날짜 기준으로 기록한다.

## Learning Contract
- 우선순위: Kafka 메시징 기본기 -> Redis 패턴 -> 테스트 자동화
- 각 단계 완료 시 Evidence(코드 경로 + 실행 로그 + 잔여 리스크)를 남긴다.
