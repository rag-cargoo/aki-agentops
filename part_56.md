
---

## Step 5: Redis Sorted Set 기반 실시간 대기열 ✅
---
> [!NOTE]
> **핵심 가치**: 사용자에게 내 앞의 대기자 수를 실시간으로 피드백하여 UX를 혁신하고 서버 인입량을 조절합니다.
>
> ### 1. 개요 (Overview)
> ---
>   - 단순히 Kafka에 요청을 쌓는 것만으로는 사용자의 불안감을 해소할 수 없습니다. 
>   - 실시간 순번 제공을 통해 사용자 경험을 개선하고 무분별한 새로고침을 방지합니다.
>
> ### 2. 핵심 매커니즘: Redis Sorted Set (ZSET)
> ---
>   - Key: waiting-queue:concert:{concertId}
>   - Score: System.currentTimeMillis() (시간 기반 자동 정렬)
>   - 장점: 100만 명 중 내 순위를 O(log N) 속도로 조회 가능.
>
> ### 3. 실제 구현 코드 (WaitingQueueServiceImpl)
> ---
> ```java
> @Override
> public WaitingQueueResponse join(Long userId, Long concertId) {
>     String queueKey = QUEUE_KEY_PREFIX + concertId;
>     String userIdStr = String.valueOf(userId);
>     if (Boolean.TRUE.equals(redisTemplate.hasKey(ACTIVE_KEY_PREFIX + userIdStr))) {
>         return WaitingQueueResponse.builder().userId(userId).concertId(concertId).status("ACTIVE").rank(0L).build();
>     }
>     redisTemplate.opsForZSet().add(queueKey, userIdStr, System.currentTimeMillis());
>     return getStatus(userId, concertId);
> }
> ```

---

## Step 6: 유입량 제어 전략 (Throttling) 👈
---
> [!WARNING]
> **시스템 생존 보장**: 임계치 이상의 요청을 사전에 차단하고 활성화 인원을 동적으로 조절하는 최종 수비 단계입니다.
>
> ### 1. 핵심 제어 매커니즘 (Control Mechanisms)
> ---
>   - 1.1. 진입 차단 (Throttling): ZCARD로 현재 대기 인원 체크, 임계치 초과 시 진입 거부.
>   - 1.2. 유입량 동적 조절: 서버 상태(CPU, DB 부하)에 따라 활성화 인원수 가변 운영.
>   - 1.3. ACTIVE 토큰 검증: 인터셉터에서 유효 권한 검증.
