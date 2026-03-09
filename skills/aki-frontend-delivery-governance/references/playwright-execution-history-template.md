# Playwright Execution History Template

프로젝트별 실행 이력 파일 기본 템플릿:

```md
# Playwright Execution History (<service>)

이 문서는 `run-playwright-suite.sh` 실행 결과를 누적 기록한다.

## Run Ledger
| Executed At | Scope | Result | Run ID | Summary | Log |
| --- | --- | --- | --- | --- | --- |
| 2026-02-20 02:45:00 | `smoke` | `PASS` | `20260220-024500-12345` | `.codex/tmp/frontend-playwright/<service>/<run-id>/summary.txt` | `.codex/tmp/frontend-playwright/<service>/<run-id>/run.log` |
```

운영 규칙:
1. row는 append-only로 누적한다.
2. 동일 실행은 1 row만 기록한다.
3. 실패(`FAIL(code)`)도 삭제하지 않고 남긴다.
