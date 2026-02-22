# Meeting Notes: Distributed Backend Readiness Code Review Kickoff (ticket-core-service)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-21 18:27:00`
> - **Updated At**: `2026-02-22 10:02:24`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 0: Stage 0 사전작업 게이트(선행조건)
> - 안건 1: 목적/범위
> - 안건 2: 1차 코드 스캔 요약
> - 안건 3: 분산 점검 체크리스트
> - 안건 4: 진행 방식
> - 안건 5: 대규모 매진 트래픽 기준 Redis/DB 책임 분리 결정 업데이트
> - 진행현황: 완료/남은 항목
<!-- DOC_TOC_END -->

## 안건 0: Stage 0 사전작업 게이트(선행조건)
- Status: DONE
- 분리 이유:
  - #21의 본 구현(soft lock + HOLD 상태머신)을 바로 시작하면, 분산환경에서 보안/원자성/스케줄러 중복 실행 리스크가 남는다.
  - 구현 착수 전 필수 안전장치를 선행 단계로 고정해 리스크를 줄인다.
- Stage 0 선행 항목:
  1. WebSocket 구독 인증 경계 강화:
     - 구독 등록/해제에서 `userId` body 신뢰를 제거하고 인증 컨텍스트 기준으로 정렬
  2. 대기열 활성화 원자화:
     - `range -> set -> remove` 멀티스텝을 Lua(또는 동등 원자 연산)로 치환
  3. 스케줄러 분산 실행 제어:
     - waiting-queue/hold-expire 스케줄러에 분산락 적용
  4. 공식 문서 선반영:
     - API spec/realtime spec/task에 Stage 0 -> #21 순서와 의존성 명시
- 진행 순서:
  - `Stage 0(#22)` 완료 후 `#21` 본 구현 착수
- Tracking:
  - Stage 0 Issue: `https://github.com/rag-cargoo/ticket-core-service/issues/22` (closed)
  - Stage 0 PR: `https://github.com/rag-cargoo/ticket-core-service/pull/23` (merged)
  - #21 선행의존 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/21#issuecomment-3939683402`
  - #21 완료보고 코멘트: `https://github.com/rag-cargoo/ticket-core-service/issues/21#issuecomment-3939821886`

## 안건 1: 목적/범위
- Status: AGREED
- 목적:
  - 백엔드가 다중 인스턴스(분산 배포) 환경에서 좌석/대기열/실시간/인증 흐름을 안정적으로 처리하는지 코드 기준으로 점검한다.
- 범위:
  - 예약/좌석 선점(v7 포함)
  - 대기열(활성화/순위/상태)
  - 실시간 푸시(WebSocket/SSE)
  - 인증 토큰 무효화(denylist)
  - 캐시/스케줄러 동작의 멀티노드 안전성

## 안건 2: 1차 코드 스캔 요약
- Status: RECORDED
- 관찰사항(초기):
  - Redis 기반 처리 존재:
    - 대기열 join/rank/활성화, 비동기 예약 상태, 토큰 denylist, v3 분산락 경로
  - v7 실사용 예약 흐름은 DB 비관적 락 기반으로 좌석 정합성을 보장
  - 분산 관점 보강 필요 후보:
    - WebSocket broker가 simple broker(인메모리)
    - WebSocket/SSE 구독자 상태를 인메모리 컬렉션으로 보관
    - 대기열 스케줄러가 인스턴스별로 실행될 수 있는 구조
    - 공연 조회 캐시가 로컬 Caffeine(노드별 캐시)

## 안건 3: 분산 점검 체크리스트
- Status: TODO
- 체크 포인트:
  1. 예약/좌석:
     - 좌석 중복 선점/확정 경쟁 시 DB 락/트랜잭션으로 정합성 유지되는지
     - 분산락(v3)와 v7 경로의 역할 분리 의도 검증
  2. 대기열:
     - 활성화 스케줄이 다중 인스턴스에서 중복 실행될 때 중복 활성화/푸시 위험 검증
     - Redis 연산 원자성(Lua + multi-step 로직 경계) 검증
  3. 실시간:
     - 다중 인스턴스에서 구독자 추적/푸시 누락 가능성 검증
     - broker relay(RabbitMQ/Redis pubsub 등) 필요성 판단
  4. 인증/보안:
     - Redis 장애 시 denylist fallback 동작이 보안 요건을 만족하는지
  5. 캐시:
     - 노드별 캐시 불일치 허용 범위 및 강제 무효화 전략 검증

## 안건 4: 진행 방식
- Status: AGREED
- 원칙:
  - 이번 문서는 점검 착수 기준선만 기록한다.
  - #21 본 구현 전 `Stage 0(#22)` 선행 게이트를 먼저 완료한다.
  - 즉시 구조개편은 하지 않고, 선행 게이트 완료 후 #21 본 구현 트랙으로 진행한다.
  - 점검 결과는 `문제/영향/재현조건/개선안/우선순위` 형식으로 추가 기록한다.

## 안건 5: 대규모 매진 트래픽 기준 Redis/DB 책임 분리 결정 업데이트
- Status: AGREED
- 전제 조건:
  - 대형 공연 기준 `10만+` 좌석, 짧은 시간대 동시 접속자 `수십만~수백만` 급 트래픽을 상정한다.
  - 프론트/백엔드 모두 다중 인스턴스 + 오토스케일링 환경을 기본 운영 가정으로 둔다.
- 용어 정리(운영 기준):
  - `좌석 선택(click)`:
    - 사용자 UI 상 선택 의도 표현 단계
    - 서버에서는 Redis 임시 점유(soft lock) 시도 이벤트로 처리한다.
  - `좌석 확정`:
    - 결제 직전 단계
    - Redis 임시 점유를 검증한 뒤 DB `HOLD(TEMP_RESERVED)` 원장을 생성/갱신한다.
  - `결제 확정(CONFIRMED)`:
    - 결제 성공 후 DB에서 최종 소유 상태(`RESERVED`)를 확정한다.
- 아키텍처 결정:
  1. 클릭 시점 동시성 제어는 Redis 원자 연산(`SET NX + TTL`)으로 처리한다.
  2. Redis soft lock 성공/실패 결과를 WebSocket으로 즉시 브로드캐스트하여 다른 사용자 화면을 동기화한다.
  3. 사용자 반복 클릭/해제는 Redis/실시간 레이어에서 처리하고, DB는 클릭 토글마다 쓰지 않는다.
  4. 사용자의 `좌석 확정` 요청 시점에만 DB 트랜잭션으로 하드 홀드 원장을 기록한다.
  5. 결제 성공 시 DB `HOLD -> CONFIRMED`로 전이하고, 실패/취소/만료 시 DB/Redis 상태를 정리한다.
  6. WebSocket은 실시간 전파 채널이며, 정합성 원장은 Redis 단독이 아니라 DB를 포함한 상태머신으로 유지한다.
- 좌석 실시간 채널(WebSocket) 채택 이유:
  1. 초고트래픽 매진 구간에서 좌석 상태 변화가 초 단위로 급변하므로, Polling 대비 지연/중복 요청을 줄일 수 있다.
  2. 동일 좌석에 대한 임시 점유 결과(성공/충돌)를 즉시 fan-out하여 UI 불일치(동시에 선택 가능해 보이는 문제)를 최소화할 수 있다.
  3. Polling 기반에서는 프론트 인스턴스 수와 사용자 수가 늘수록 조회 QPS가 선형 증가하므로, 백엔드/DB 부담이 급격히 커진다.
  4. WebSocket은 "상태 알림 채널" 역할에 집중하고, 실제 판정은 Redis 원자 연산 + DB 트랜잭션으로 분리할 때 안정성이 높다.
  5. 운영 정책상 장애/차단 시 SSE 또는 짧은 주기 Polling fallback 경로를 유지해 실시간 채널 단일 의존을 피한다.
- 좌석 선점(임시점유) 상세 계약:
  1. 좌석 클릭:
     - 백엔드는 `seat:{optionId}:{seatId}` 키에 `SET NX EX <ttl>`로 soft lock을 시도한다.
     - 값에는 `userId`, `requestId`, `expiresAt`를 포함한 owner 정보를 저장한다.
  2. soft lock 성공:
     - 응답은 성공(예: 200/201)으로 반환하고, WebSocket으로 `SELECTING` 이벤트를 브로드캐스트한다.
  3. soft lock 충돌:
     - 기존 owner가 있으면 실패(예: 409 CONFLICT)로 반환하고, 프론트는 "이미 선택 중" 안내를 표시한다.
  4. 좌석 해제:
     - 해제 요청은 owner 일치 조건에서만 허용하며, 성공 시 키 삭제 + `AVAILABLE` 이벤트를 브로드캐스트한다.
  5. TTL 만료:
     - 만료 시 자동 해제 상태로 간주하고, 백그라운드 정리/재동기화 후 `AVAILABLE` 이벤트를 발행한다.
  6. 좌석 확정(결제 직전):
     - 요청 좌석 전체에 대해 owner 검증이 통과한 경우에만 DB `HOLD(TEMP_RESERVED)`를 트랜잭션으로 기록한다.
     - 이 단계에서 `reservationId`, `holdExpiresAt`를 발급하고, soft lock은 해제하거나 hold 키로 승격한다.
  7. 멱등/중복 방지:
     - `requestId(idempotency key)` 기준으로 중복 확정 요청을 1회 처리 원칙으로 제한한다.
  8. 실패 복구:
     - DB HOLD 실패 시 해당 soft lock을 즉시 정리하고, 실패 이벤트를 전파하여 UI와 상태를 되돌린다.
- 상태 모델(운영 표준):
  - `AVAILABLE -> SELECTING(soft lock) -> HOLD(DB) -> CONFIRMED`
  - 실패/취소/만료 시 `AVAILABLE`로 복귀
- 분산/확장 관점 보강 포인트:
  - 입구 제어(Queue Active Token, Rate Limit, 중복 요청 차단)로 DB 유입 트래픽을 제한한다.
  - 실시간 브로커는 단일 노드 simple broker에서 relay 기반으로 확장 검토한다.
  - 좌석 상태 키 설계는 `concert/option` 단위 파티셔닝과 TTL 정책을 포함해 설계한다.
  - 장애 복구 시 DB 원장을 기준으로 Redis/실시간 상태를 재동기화하는 절차를 준비한다.
- 참고 메모:
  - 본 업데이트는 "Redis-only 원장" 또는 "DB-only 즉시 처리" 극단이 아니라,
    `Redis(실시간/게이트/임시점유) + DB(하드홀드/결제확정 원장)` 하이브리드 모델을 기준안으로 확정한다.
- Tracking:
  - Product Issue: `https://github.com/rag-cargoo/ticket-core-service/issues/21`

## 진행현황: 완료/남은 항목
- Status: IN_PROGRESS
- 완료된 것:
  - 분산 백엔드 코드리뷰 착수 안건 생성
  - 점검 범위/체크리스트/진행 원칙 합의용 문서화
  - 대규모 매진/오토스케일링 전제를 반영한 Redis/DB 책임 분리 기준선 합의
  - #21 선행 단계 `Stage 0(#22)` 분리 및 의존 관계 고정
  - Stage 0 구현 완료/머지:
    - WebSocket 구독 인증 경계 강화
    - 대기열 활성화 Lua 원자 처리
    - waiting-queue/hold-expire 스케줄러 분산락 적용
- 남은 것:
  - #21 본 구현:
    - 클릭 기반 Redis soft lock과 좌석 확정(DB HOLD) 경계 API/상태머신 상세 계약서 확정
    - WebSocket broker relay 및 멀티노드 구독자 추적 전략 확정
    - 적용 우선순위(즉시/차기) 확정
