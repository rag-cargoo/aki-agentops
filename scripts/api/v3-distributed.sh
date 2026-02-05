#!/bin/bash
source "$(dirname "$0")/../common/env.sh"

echo -e "${BLUE}[v3] Distributed Lock Reservation Test${NC}"
curl -X POST "${BASE_URL}/v3/distributed-lock" \
     -H "${CONTENT_TYPE}" \
     -d "{\"userId\": ${DEFAULT_USER_ID}, \"seatId\": ${DEFAULT_SEAT_ID}}" \
     -w "\nStatus: %{http_code}\n"
