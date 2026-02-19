# Figma MCP Troubleshooting

## 1) remote endpoint unreachable
증상:
- `probe_figma_mcp.sh --server figma`에서 `http_code=000`

조치:
1. 네트워크/DNS 확인
2. 프록시/방화벽 정책 확인
3. 재시도 후 동일하면 세션 보고에 `remote unreachable`로 기록

## 2) desktop endpoint unreachable
증상:
- `probe_figma_mcp.sh --server figma-desktop`에서 `http_code=000`

조치:
1. Figma Desktop 앱 실행 여부 확인
2. 로컬 포트 점검: `ss -ltnp | rg 3845`
3. 재시작 후 재점검

## 3) endpoint는 reachable인데 구현 실패
증상:
- probe는 통과했지만 디자인 context fetch 실패

조치:
1. MCP 인증 상태 확인
2. 파일 접근 권한/링크 유효성 확인
3. 문제 URL, node-id, 오류 메시지를 증빙으로 기록
