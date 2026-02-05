#!/bin/bash
source "$(dirname "$0")/../common/env.sh"

echo -e "${BLUE}[v1] Optimistic Lock Reservation Test${NC}"
curl -X POST "${BASE_URL}/v1/optimistic" \
     -H "${CONTENT_TYPE}" \
     -d "{\"userId\": ${DEFAULT_USER_ID}, \"seatId\": ${DEFAULT_SEAT_ID}}" \
     -w "\nStatus: %{http_code}\n"
