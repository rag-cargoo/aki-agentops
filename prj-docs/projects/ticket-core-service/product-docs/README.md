# Ticket Core Service README

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-17 17:03:13`
> - **Updated At**: `2026-02-23 22:40:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source
> - Publication Policy
> - Content
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)
- Updated For Dedup: 2026-02-17 22:38:23

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

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

### 5. Auth-Social CI-safe 파이프라인 테스트
```bash
make test-auth-social-pipeline
```

### 6. Auth-Social Real Provider E2E 테스트 (선택)
```bash
APP_AUTH_SOCIAL_REAL_E2E_ENABLED=true \
AUTH_REAL_E2E_PROVIDER=kakao \
AUTH_REAL_E2E_PREPARE_ONLY=true \
make test-auth-social-real-provider
```

- 로컬 `k6`가 없으면 Docker(`grafana/k6`) fallback으로 자동 실행됩니다.
- 웹 대시보드 포함 실행: `make test-k6-dashboard` (기본 URL: `http://127.0.0.1:5665`)

---

## 검증/운영 포인트

- API 스크립트 실행 리포트 기본 경로: `.codex/tmp/ticket-core-service/api-test/latest.md`
- auth-social 파이프라인 리포트 기본 경로: `.codex/tmp/ticket-core-service/api-test/auth-social-e2e-latest.md`
- auth-social real provider e2e 리포트 기본 경로: `.codex/tmp/ticket-core-service/api-test/auth-social-real-provider-e2e-latest.md`
- k6 실행 리포트 기본 경로: `.codex/tmp/ticket-core-service/k6/latest/k6-latest.md`
- 인증 오류 응답은 `errorCode`(`AUTH_*`) 필드를 포함
- 운영 집계 로그 키: `AUTH_MONITOR`

---

## 대표 문서 링크

- Service README (Pages Docs): [AKI AgentOps Pages](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/README.md)
- Architecture Knowledge Index (Pages Docs): [Knowledge Index](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/knowledge/README.md)
- DDD + Hexagonal Guide (Pages Docs): [Guide](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/knowledge/ddd-hexagonal-guide.md)
- DDD + Hexagonal Phase2 Completion (Pages Docs): [Phase2 Completion](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/knowledge/ddd-hexagonal-phase2-completion-human.md)
- API Specs Index (Pages Docs): [API Specs](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/api-specs/README.md)
- Realtime Queue/Push Monitoring Guide (Pages Docs): [Realtime Ops Monitoring](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/api-specs/realtime-ops-monitoring-guide.md)
- API Test Guide (Pages Docs): [API Test Guide](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/api-test/README.md)
- Frontend Release Contract Checklist (Pages Docs): [Checklist](https://rag-cargoo.github.io/aki-agentops/#/prj-docs/projects/ticket-core-service/product-docs/frontend-release-contract-checklist.md)
- Sidecar Task (운영 추적): [Task Dashboard](https://github.com/rag-cargoo/aki-agentops/blob/main/prj-docs/projects/ticket-core-service/task.md)
- Sidecar Meeting Notes (운영 기록): [Meeting Notes](https://github.com/rag-cargoo/aki-agentops/blob/main/prj-docs/projects/ticket-core-service/meeting-notes/README.md)

참고: 제품 레포에서는 `prj-docs`를 운영 SoT로 사용하지 않으며, 문서 거버넌스는 `AKI AgentOps` sidecar에서 관리합니다.
