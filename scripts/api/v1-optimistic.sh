#!/bin/bash

# ==============================================================================
# [v1] 낙관적 락(Optimistic Lock) 예약 테스트 스크립트
#
# 목적: JPA @Version 기능을 이용한 동시성 제어 API를 호출합니다.
# 설정 안내:
# - 서버 주소 및 기본 데이터(User/Seat ID)는 'scripts/common/env.sh'에서 수정하세요.
# - 실행 전 반드시 서버(Spring Boot)가 구동 중이어야 합니다.
# ==============================================================================

# 공통 설정 로드
source "$(dirname "$0")/../common/env.sh"

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}[v1] Optimistic Lock Reservation Test${NC}"
echo -e "${BLUE}Target URL: ${BASE_URL}/v1/optimistic${NC}"
echo -e "${BLUE}====================================================${NC}"

curl -X POST "${BASE_URL}/v1/optimistic" \
     -H "${CONTENT_TYPE}" \
     -d "{\"userId\": ${DEFAULT_USER_ID}, \"seatId\": ${DEFAULT_SEAT_ID}}" \
     -w "\n\n${GREEN}Result Status: %{http_code}${NC}\n"