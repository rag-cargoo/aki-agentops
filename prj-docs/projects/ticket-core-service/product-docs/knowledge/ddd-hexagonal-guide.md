# DDD + Hexagonal 가이드 (용어사전 포함)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 20:30:00`
> - **Updated At**: `2026-02-23 20:32:00`
> - **Target**: `HUMAN`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1) 용어 사전
> - 2) 왜 DDD와 Hexagonal을 같이 쓰는가
> - 3) 왜 포트(Inbound/Outbound)를 나누는가
> - 4) 왜 패키지를 이렇게 나누는가
> - 5) 이번 리팩토링에서 실제로 해결한 문제
> - 6) 2차 리팩토링에서 보통 추가되는 항목
> - 7) 자주 나오는 질문
<!-- DOC_TOC_END -->

## 1) 용어 사전
- `DDD (Domain-Driven Design)`: 비즈니스 규칙(도메인)을 코드 구조의 중심에 두는 설계 방식.
- `Domain`: 서비스의 핵심 업무 규칙(예: 예약 상태 전이, 좌석 선점 정책).
- `Entity`: 식별자(Identity)로 구분되는 도메인 객체.
- `Value Object`: 값 자체로 동등성을 판단하는 불변 객체.
- `Use Case (Application Service)`: 한 개의 업무 시나리오를 실행하는 단위.
- `Hexagonal Architecture`: 코어를 중심으로 외부 입출력을 포트/어댑터로 분리하는 구조.
- `Port`: 코어가 약속하는 인터페이스.
- `Adapter`: 포트의 실제 구현체(예: Kafka, Redis, OAuth, DB).
- `Inbound Port`: 외부에서 코어 유스케이스를 호출할 때 들어오는 인터페이스.
- `Outbound Port`: 코어가 외부 시스템을 사용할 때 의존하는 인터페이스.
- `Dependency Rule`: 의존성은 바깥에서 안쪽으로만 향해야 한다는 규칙.
- `ArchUnit`: 패키지/계층 의존 규칙을 테스트로 강제하는 도구.

## 2) 왜 DDD와 Hexagonal을 같이 쓰는가
- DDD만 적용하면 "무엇이 핵심 비즈니스 규칙인지"는 선명해지지만, 외부 기술과의 연결 규칙이 느슨하면 다시 엉킬 수 있다.
- Hexagonal을 같이 적용하면 외부 기술(Kafka/Redis/OAuth/Spring 컴포넌트)이 코어를 직접 오염시키지 못하도록 경계를 고정할 수 있다.
- 즉, 역할 분담은 다음과 같다.
  - DDD: 도메인 모델/업무 규칙 중심 설계.
  - Hexagonal: 경계(포트/어댑터)와 의존 방향 고정.

## 3) 왜 포트(Inbound/Outbound)를 나누는가
- `Inbound`가 필요한 이유:
  - 컨트롤러/스케줄러/컨슈머가 어떤 유스케이스를 호출하는지 명확해진다.
  - 코어가 "어떤 입력을 받아 어떤 결과를 주는지" 계약이 분리된다.
- `Outbound`가 필요한 이유:
  - 코어가 Kafka/Redis/OAuth/Config 구현체를 직접 알 필요가 없다.
  - 구현 교체 시 코어 수정량을 줄인다.
- 이 프로젝트의 예시:
  - Inbound 예시:
    - `application/reservation/port/inbound/DistributedReservationUseCase`
  - Outbound 예시:
    - `application/reservation/port/outbound/ReservationQueueEventPublisher`
    - `application/port/outbound/PushEventPublisherPort`
    - `application/waitingqueue/port/outbound/WaitingQueueConfigPort`
    - `application/auth/port/outbound/AuthJwtConfigPort`

## 4) 왜 패키지를 이렇게 나누는가
- `api`: HTTP 진입점. DTO 변환/인증된 사용자 식별/응답 포맷 책임.
- `application`: 유스케이스 오케스트레이션. 트랜잭션과 흐름 조합 책임.
- `domain`: 핵심 비즈니스 규칙과 상태 전이 책임.
- `infrastructure`: Kafka/Redis/OAuth/DB 같은 외부 기술 구현 책임.
- `global`: 공통 런타임 구성/횡단 관심사를 담는 영역(점진적으로 포트 기준 정리 진행).
- 목적:
  - 컨트롤러는 업무 흐름을 직접 구현하지 않는다.
  - 도메인은 API DTO/프레임워크 타입을 모른다.
  - 인프라는 코어 계약(포트)만 보고 구현한다.

## 5) 이번 리팩토링에서 실제로 해결한 문제
- 과거 문제(요약):
  - `domain -> api dto` 의존이 존재.
  - `application -> api dto/global` 직접 의존이 존재.
  - `api/global -> infrastructure.messaging` 직접 의존이 존재.
  - `infrastructure -> global` 직접 의존이 존재.
- 정리 결과(1차 완료 시점):
  - `domain -> api`: `0`
  - `application -> api dto`: `0`
  - `api -> global`: `0`
  - `application -> global`: `0`
  - `infrastructure -> global`: `0`
  - `global -> api`: `0`
  - `global -> infrastructure`: `0`
- 회귀 방지:
  - `src/test/java/com/ticketrush/architecture/LayerDependencyArchTest.java`로 경계 규칙을 테스트화.

## 6) 2차 리팩토링에서 보통 추가되는 항목
- 1차가 "경계/의존 정리"라면, 2차는 주로 "도메인 모델 심화"다.
- 보통 다음 항목이 추가된다.
  - 애그리거트 경계 재설계(트랜잭션 경계 명확화)
  - 불변식 검증 책임을 서비스에서 엔티티/VO로 이동
  - 도메인 이벤트 발행/구독 정책 명확화
  - 컨텍스트(BC) 경계 분리 및 anti-corruption layer 설계
  - 읽기 모델/조회 최적화(CQRS-lite) 검토

## 7) 자주 나오는 질문
- `Q. 인터페이스(포트)가 많아져서 복잡해지지 않나?`
  - A. 파일 수는 늘지만, 변경 영향 범위가 줄어든다. 운영 단계에서 유지보수 비용을 줄이기 위한 구조다.
- `Q. 서비스가 작아도 DDD/Hexagonal이 필요한가?`
  - A. 단순 CRUD 위주면 과할 수 있다. 하지만 이 서비스처럼 동시성/대기열/결제/실시간 전송이 섞인 경우 경계 통제가 필요하다.
- `Q. 왜 ArchUnit까지 필요한가?`
  - A. 사람 리뷰만으로는 경계 회귀를 막기 어렵다. 규칙을 테스트로 고정해야 장기적으로 유지된다.
