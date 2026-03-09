# DDD + Hexagonal 2차 완료 지식문서 (Human Friendly)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-23 22:35:00`
> - **Updated At**: `2026-02-23 22:35:00`
> - **Target**: `HUMAN`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 1) 용어 사전(짧게)
> - 2) 왜 DDD + Hexagonal을 같이 적용했나
> - 3) 1차/2차/3차에서 실제로 바뀐 것
> - 4) 왜 Inbound/Outbound Port를 분리했나
> - 5) 왜 패키지를 이렇게 나눴나
> - 6) 결과 요약(운영 관점)
> - 7) 다음 단계(선택)
<!-- DOC_TOC_END -->

## 1) 용어 사전(짧게)
- `도메인(Domain)`: 서비스의 핵심 업무 규칙(예약 상태 전이, 대기열 활성화, 환불 컷오프 등).
- `DDD`: 도메인 규칙을 코드 구조의 중심으로 두는 설계 방식.
- `Hexagonal`: 코어와 외부 기술을 포트/어댑터로 분리하는 아키텍처.
- `Use Case`: 하나의 업무 시나리오를 실행하는 애플리케이션 서비스.
- `Inbound Port`: 외부가 유스케이스를 호출할 때 사용하는 인터페이스.
- `Outbound Port`: 코어가 외부 시스템을 사용할 때 의존하는 인터페이스.
- `Adapter`: 포트의 실제 구현체(Kafka, Redis, OAuth, Spring Bean).
- `Capability Port`: "기능 단위"로 쪼갠 포트(예: queue, reservation-status, seat-map).
- `ArchUnit`: 계층/의존 규칙을 테스트로 강제하는 도구.

## 2) 왜 DDD + Hexagonal을 같이 적용했나
- DDD만 적용하면 "업무 규칙 모델링"은 좋아지지만, 외부 기술 의존이 다시 섞이기 쉽다.
- Hexagonal을 같이 적용하면 "의존 방향"을 강제할 수 있어 장기 유지보수에 유리하다.
- 이 프로젝트는 동시성, 대기열, 결제, 실시간 전송(SSE/WS/Kafka)이 함께 동작하므로,
  단순 CRUD 구조보다 경계 통제가 필수였다.

## 3) 1차/2차/3차에서 실제로 바뀐 것
- 1차(경계 정리):
  - `domain -> api`, `application -> api dto` 같은 역방향 의존 제거.
  - controller의 직접 구현체 의존 축소.
  - ArchUnit 규칙 본격 도입.
- 2차(확장 정리, Phase2~Phase6):
  - application/global/infrastructure 경계 정리.
  - push 계약 타입 정제(`QueuePushPayload`, `QueueEventName` enum).
  - broad push 의존을 capability 포트로 축소.
  - 회의록/태스크 기준으로 단계별 검증 누적.
- 3차(Phase7-A, 마무리):
  - `RealtimePushPort` 완전 제거.
  - push selector를 capability별 primary bean으로 분리.
  - 결과: `src/**` 기준 `RealtimePushPort` 참조 `0건`.

참고 회의록:
- [DDD Phase6-O](../../meeting-notes/2026-02-23-ddd-phase6o-push-broad-port-final-segregation.md)
- [DDD Phase7-A](../../meeting-notes/2026-02-23-ddd-phase7a-realtime-port-removal-and-selector-split.md)

## 4) 왜 Inbound/Outbound Port를 분리했나
- Inbound를 두는 이유:
  - 외부 진입점(API/스케줄러/컨슈머)과 유스케이스 계약을 분리한다.
  - 입력/출력 모델 책임이 명확해져 컨트롤러가 얇아진다.
- Outbound를 두는 이유:
  - 코어가 Kafka/Redis/OAuth 구현체를 직접 알 필요가 없다.
  - 기술 교체 시 코어 수정 범위를 최소화한다.
- Capability 포트까지 쪼개는 이유:
  - "필요한 기능만 의존"하도록 강제해 결합도를 줄인다.
  - 예: 좌석 상태만 보내는 서비스는 `SeatMapPushPort`만 알면 된다.

## 5) 왜 패키지를 이렇게 나눴나
- `api`: HTTP 입출력/인증 사용자 해석/DTO 매핑.
- `application`: 유스케이스 조합, 트랜잭션 경계, 흐름 오케스트레이션.
- `domain`: 상태 전이 규칙, 비즈니스 불변식.
- `infrastructure`: Kafka/Redis/OAuth/DB 등 외부 기술 구현.
- `global`: 공통 런타임 구성(점진적으로 포트 경계 기준 정리).

핵심 원칙:
- 컨트롤러는 업무 규칙을 직접 구현하지 않는다.
- 도메인은 API DTO/프레임워크 타입을 모른다.
- 인프라는 코어 계약(포트)만 보고 구현한다.

## 6) 결과 요약(운영 관점)
- 장점:
  - 변경 영향 범위 축소(버그 전파 감소).
  - 테스트 가능성 향상(포트 mock 기반 검증 용이).
  - 회귀 방지 자동화(ArchUnit).
- 비용:
  - 파일/인터페이스 수 증가.
  - 초기 진입 난이도 상승.
- 결론:
  - 이 서비스처럼 복합 도메인에서는 비용 대비 효과가 명확했다.

## 7) 다음 단계(선택)
- 필수 리팩토링은 사실상 완료.
- 이후는 선택 과제:
  - 운영 관측성(메트릭/알람) 강화
  - 부하/성능 튜닝
  - 도메인 모델 심화(애그리거트·이벤트 정책)
