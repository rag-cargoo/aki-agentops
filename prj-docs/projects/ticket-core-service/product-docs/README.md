# Ticket Core Service README (Pages Mirror)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:03:13`
> - **Updated At**: `2026-02-17 17:03:13`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source
> - Mirror Policy
> - Content
<!-- DOC_TOC_END -->

## Source
- Upstream: [ticket-core-service/README.md](https://github.com/rag-cargoo/ticket-core-service/blob/main/README.md)
- Synced At: 2026-02-17 17:03:13

## Mirror Policy
- 이 문서는 GitHub Pages 탐색을 위한 읽기 전용 미러다.
- 원본 수정/PR은 `rag-cargoo/ticket-core-service`에서 진행한다.

## Content



이 문서는 `workspace/apps/backend/ticket-core-service` 프로젝트의 소개, 실행 방법, 검증 진입점을 제공합니다.

---

## 프로젝트 개요

- 목적: 선착순 티켓 예약 도메인에서 동시성 제어와 대기열 처리의 정합성을 확보하는 백엔드 코어 서비스
- 상태: `진행중` (핵심 시나리오 구현 완료, 운영/성능 고도화 진행)
- 기술 스택: Java 17, Spring Boot 3.4.1, PostgreSQL, Redis, Kafka

---

## 실행 방법

### 1. 인프라 실행
```bash
docker-compose up -d
```

### 2. 애플리케이션 실행
```bash
./gradlew bootRun --args='--spring.profiles.active=local'
```

### 3. API 스크립트 회귀 실행
```bash
make test-suite
```

### 4. k6 부하 테스트 실행
```bash
make test-k6
```

- 로컬 `k6`가 없으면 Docker(`grafana/k6`) fallback으로 자동 실행됩니다.
- 웹 대시보드 포함 실행: `make test-k6-dashboard` (기본 URL: `http://127.0.0.1:5665`)

---

## 검증/운영 포인트

- API 스크립트 가이드: [API Script Guide](/workspace/apps/backend/ticket-core-service/prj-docs/api-test/README.md)
- 현재 작업/백로그 통합 보드: [Project Task Dashboard](/workspace/apps/backend/ticket-core-service/prj-docs/task.md)

---

## 대표 문서 링크

- 프로젝트 에이전트 규칙: [Project Agent (Rules)](/workspace/apps/backend/ticket-core-service/prj-docs/PROJECT_AGENT.md)
- 아키텍처: [Architecture](/workspace/apps/backend/ticket-core-service/prj-docs/rules/architecture.md)
- 동시성 전략 기록: [동시성 제어 전략](/workspace/apps/backend/ticket-core-service/prj-docs/knowledge/동시성-제어-전략.md)
- 소셜 로그인 전략 기록: [소셜 로그인 OAuth 연동 전략](/workspace/apps/backend/ticket-core-service/prj-docs/knowledge/social-login-oauth-연동-전략.md)
- 예약 API 명세: [Reservation API](/workspace/apps/backend/ticket-core-service/prj-docs/api-specs/reservation-api.md)
- 소셜 인증 API 명세: [Social Auth API](/workspace/apps/backend/ticket-core-service/prj-docs/api-specs/social-auth-api.md)
