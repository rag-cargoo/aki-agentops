> **Source**: https://docs.tosspayments.com/guides/llms (및 사용자 제공 정보)
> **Purpose**: AI 에이전트가 토스페이먼츠 연동 시 참고할 핵심 가이드 및 MCP 설정 정보
> **Date**: 2026-01-26

# 토스페이먼츠 연동 가이드 for AI

## 1. LLM 연동 리소스

### llms.txt
- **URL**: https://docs.tosspayments.com/llms.txt
- **용도**: AI 도구와 에이전트가 토스페이먼츠 결제 연동 정보에 쉽게 접근하기 위한 표준 파일
- **사용법**: AI 프롬프트에 이 파일 내용을 포함하면 더 정확한 답변 가능

### MCP (Model Context Protocol) 서버
토스페이먼츠는 AI가 문서를 더 잘 이해하도록 MCP 서버를 제공합니다.

#### 설정 (mcp.json)
```json
{
  "mcpServers": {
    "tosspayments-integration-guide": {
      "command": "npx",
      "args": ["-y", "@tosspayments/integration-guide-mcp@latest"]
    }
  }
}
```

#### 제공 도구 (Tools)
1. **`get-v2-documents`**: v2 문서 조회 (기본값)
2. **`get-v1-documents`**: v1 문서 조회 (명시적 요청 시)
3. **`document-by-id`**: 문서 ID로 전체 내용 조회

## 2. 개발 도구 연동 방법

### Cursor
- 설정 위치: `~/.cursor/mcp.json`
- `tosspayments-integration-guide` 설정 추가 시 자동 연결

### VS Code
- 설정 위치: `.vscode/mcp.json`

### Windsurf
- 설정 위치: `~/.codeium/windsurf/mcp_config.json`

## 3. 코드 작성을 위한 프롬프트 예시

- "V2 SDK로 주문서 내에 결제위젯을 삽입하는 코드를 작성해줘"
- "결제 승인 요청하는 코드를 작성해줘"

## 4. 핵심 API 문서 (참조)

- **개발자 센터**: https://developers.tosspayments.com
- **연동 가이드**: https://docs.tosspayments.com
- **테스트 결제**: 별도 회원가입 없이 샌드박스에서 테스트 가능
- **API 키**: 개발자 센터 > API 키 관리에서 '테스트 키' 발급 필요
