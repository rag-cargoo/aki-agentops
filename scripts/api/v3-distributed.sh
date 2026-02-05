#!/bin/bash

# ==============================================================================
# [v3] Redis 분산 락(Distributed Lock) 예약 테스트 스크립트
#
# 목적: Redisson 라이브러리를 이용한 분산 환경 동시성 제어 API를 호출합니다.
# 설정 안내:
# - 서버 주소 및 기본 데이터(User/Seat ID)는 'scripts/common/env.sh'에서 수정하세요.
# - 실행 전 서버와 Redis 컨테이너가 모두 구동 중이어야 합니다.
# ==============================================================================

source "$(dirname "$0")/../common/env.sh"

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}[v3] Distributed Lock Reservation Test${NC}"
echo -e "${BLUE}Target URL: ${BASE_URL}/v3/distributed-lock${NC}"
echo -e "${BLUE}====================================================${NC}"

curl -X POST "${BASE_URL}/v3/distributed-lock" \
     -H "${CONTENT_TYPE}" \
     -d "{\"userId\": ${DEFAULT_USER_ID}, \"seatId\": ${DEFAULT_SEAT_ID}}" \
     -w "\n\n${GREEN}Result Status: %{http_code}${NC}\n"