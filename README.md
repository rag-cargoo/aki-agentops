#  Ticket-Rush (고성능 선착순 티켓팅 시스템)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-08 23:07:03`
> - **Updated At**: `2026-02-08 23:11:27`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 단계 목차 (Step Index)
---
> [!TIP]
> - Step 1: 낙관적 락(Optimistic Lock) - JPA @Version 활용
> - Step 2: 비관적 락(Pessimistic Lock) - DB FOR UPDATE 쿼리 활용
> - Step 3: 분산 락(Distributed Lock) - Redis(Redisson) Facade 패턴 적용
> - Step 1~7
> - Step 1~3: 락 전략 구축 및 정합성 검증
> - Step 4: Kafka 기반 비동기 대기열 및 SSE 알림 시스템
> - Step 5: Redis Sorted Set 기반 실시간 대기 순번 시스템
> - Step 6: 대기열 진입 제한(Throttling) 및 유입량 제어
> - Step 7: SSE 기반 실시간 순번 자동 푸시 시스템
<!-- DOC_TOC_END -->

대규모 트래픽 발생 시 데이터 정합성을 보장하고 시스템의 안정성을 유지하기 위한 **동시성 제어 및 비동기 처리 시스템** 프로젝트입니다.

---

##  시스템 아키텍처 (Architecture)

- **Language**: Java 17
- **Framework**: Spring Boot 3.4.1
- **Database**: PostgreSQL (Main), H2 (Local Test)
- **Messaging**: Apache Kafka (비동기 대기열)
- **Caching/Lock**: Redis (분산 락, 상태 관리)
- **Notification**: Server-Sent Events (실시간 알림)

---

##  주요 구현 기능

### 1. 동시성 제어 전략 (Concurrency Control)
- **Step 1: 낙관적 락(Optimistic Lock)** - JPA `@Version` 활용
- **Step 2: 비관적 락(Pessimistic Lock)** - DB `FOR UPDATE` 쿼리 활용
- **Step 3: 분산 락(Distributed Lock)** - Redis(Redisson) Facade 패턴 적용

### 2. 고성능 비동기 대기열 (Queue System)
- **Kafka 기반 요청 수집**: 초당 수만 건의 요청을 안전하게 완충
- **실시간 상태 추적**: Redis를 통한 PENDING -> SUCCESS 상태 전이 관리
- **실시간 알림**: SSE(`INIT`/`RANK_UPDATE`/`ACTIVE`)를 통해 순번 및 상태 변화를 즉시 통보

---

##  핵심 기술 문서 (Engineering Docs)

모든 설계 결정과 실험 기록은 `prj-docs/` 하위에 상세히 기록되어 있습니다.
- **[동시성 제어 전략 (Step 1~7)](/workspace/apps/backend/ticket-core-service/prj-docs/knowledge/동시성-제어-전략.md)**: 기술적 진화 과정 및 코드 대조 가이드.
- **[API 연동 가이드](/workspace/apps/backend/ticket-core-service/prj-docs/api-specs/reservation-api.md)**: 프론트엔드 작업자를 위한 상세 시퀀스 및 JSON 명세.

---

##  기동 및 테스트 방법 (Quick Start)

### 1. 인프라 실행 (Docker)
```bash
docker-compose up -d
```

### 2. 서버 실행
```bash
cd workspace/apps/backend/ticket-core-service
./gradlew bootRun --args='--spring.profiles.active=local'
```

### 3. 테스트 자동화 (Admin Setup & Verify)
```bash
# 1. 테스트 공연 및 좌석 자동 생성
./scripts/api/setup-test-data.sh

# 2. API 스크립트 회귀 테스트(v1~v7)
make test-suite
```

---

##  개발 로드맵
- [x] Step 1~3: 락 전략 구축 및 정합성 검증
- [x] Step 4: Kafka 기반 비동기 대기열 및 SSE 알림 시스템
- [x] Step 5: Redis Sorted Set 기반 실시간 대기 순번 시스템
- [x] Step 6: 대기열 진입 제한(Throttling) 및 유입량 제어
- [x] Step 7: SSE 기반 실시간 순번 자동 푸시 시스템
- [ ] **Next: 캐싱 전략 적용 (공연 조회 성능 개선)**
