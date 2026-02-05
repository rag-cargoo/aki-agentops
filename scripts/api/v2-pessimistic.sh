#!/bin/bash
source "$(dirname "$0")/../common/env.sh"

echo -e "${BLUE}[v2] Pessimistic Lock Reservation Test${NC}"
curl -X POST "${BASE_URL}/v2/pessimistic" \
     -H "${CONTENT_TYPE}" \
     -d "{\"userId\": ${DEFAULT_USER_ID}, \"seatId\": ${DEFAULT_SEAT_ID}}" \
     -w "\nStatus: %{http_code}\n"
