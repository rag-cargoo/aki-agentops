# Auth Error Monitoring Guide

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-02-19 04:05:21`
> - **Updated At**: `2026-02-19 04:05:21`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Source
> - Publication Policy
> - Content
> - 1. 목적
> - 2. 인증 예외코드 표준
> - 3. 운영 집계 로그 규약
> - 4. 대시보드/알람 임계치
> - 5. 운영 점검 절차
<!-- DOC_TOC_END -->

## Source
- SoT: `AKI AgentOps sidecar` (`prj-docs/projects/ticket-core-service/product-docs/**`)

## Publication Policy
- 이 문서는 GitHub Pages 사용자 탐색용 공식 문서다.
- 변경은 `rag-cargoo/aki-agentops` sidecar PR에서 관리한다.

## Content

---

## 1. 목적

- 인증 실패를 문자열 메시지 단위가 아니라 `AUTH_*` 코드 단위로 집계한다.
- 운영 대시보드에서 "토큰 만료 증가", "무효 토큰 급증", "권한 거절 급증"을 빠르게 식별한다.

---

## 2. 인증 예외코드 표준

| errorCode | HTTP | 의미 | 대표 원인 |
| :--- | :--- | :--- | :--- |
| `AUTH_ACCESS_TOKEN_REQUIRED` | 401 | Access Token 누락/형식 오류 | Authorization 헤더 없음, `Bearer` 형식 아님 |
| `AUTH_TOKEN_EXPIRED` | 401 | Access Token 만료 | 만료된 JWT |
| `AUTH_TOKEN_INVALID` | 401 | 토큰 서명/형식 오류 | 변조 토큰, 파싱 실패 |
| `AUTH_ACCESS_TOKEN_REVOKED` | 401 | 로그아웃 등으로 무효화된 토큰 | denylist 등록 토큰 |
| `AUTH_ACCESS_TOKEN_TYPE_INVALID` | 401 | access 위치에 refresh 토큰 전달 | `typ=refresh` 토큰 오용 |
| `AUTH_FORBIDDEN` | 403 | 권한 부족 | USER가 ADMIN endpoint 호출 |
| `AUTH_REFRESH_TOKEN_REQUIRED` | 400 | refresh token 누락 | refresh API body 누락 |
| `AUTH_REFRESH_TOKEN_NOT_FOUND` | 400 | refresh token 저장소 미존재 | 이미 회전/폐기된 refresh |
| `AUTH_REFRESH_TOKEN_EXPIRED_OR_REVOKED` | 400 | refresh 만료/폐기 | TTL 만료 또는 revoke 상태 |
| `AUTH_REFRESH_TOKEN_USER_MISMATCH` | 400 | refresh 사용자 불일치 | 토큰 subject와 저장값 불일치 |
| `AUTH_REFRESH_TOKEN_TYPE_INVALID` | 400 | refresh 위치에 access 토큰 전달 | `typ=access` 토큰 오용 |
| `AUTH_LOGOUT_TOKEN_USER_MISMATCH` | 400 | logout 요청의 access/refresh 주체 불일치 | 다른 사용자 토큰 혼합 |
| `AUTH_AUTHENTICATED_USER_REQUIRED` | 400 | 인증 컨텍스트 누락 | 보호 API 직접 호출 |
| `AUTH_USER_NOT_FOUND` | 400 | 토큰 사용자 조회 실패 | 삭제/비정상 사용자 |
| `AUTH_REQUEST_BODY_INVALID` | 400 | JSON body 파싱 실패 | malformed JSON |

---

## 3. 운영 집계 로그 규약

- 로그 키: `AUTH_MONITOR`
- 표준 형식:

```text
AUTH_MONITOR code=<AUTH_...> status=<http> method=<METHOD> path=<URI> detail=<message>
```

- 집계 기준:
  - 분당/5분당 코드별 count
  - endpoint별 code 분포
  - 배포 전/후 동일 구간 증감률

---

## 4. 대시보드/알람 임계치

권장 윈도우: 5분 이동 합계(`5m sum`)

| 분류 | 조건 | 심각도 | 조치 |
| :--- | :--- | :--- | :--- |
| 토큰 만료 급증 | `AUTH_TOKEN_EXPIRED`가 직전 24h 동일 시간대 평균 대비 2배 이상 | WARN | access TTL/클라이언트 자동 재발급 동작 점검 |
| 무효 토큰 급증 | `AUTH_TOKEN_INVALID + AUTH_ACCESS_TOKEN_TYPE_INVALID`가 5분 50건 초과 | HIGH | 클라이언트 토큰 저장/전송 경로 및 공격 트래픽 점검 |
| 로그아웃 후 재사용 | `AUTH_ACCESS_TOKEN_REVOKED`가 5분 10건 초과 | WARN | 멀티탭/캐시 재사용 시나리오, 프론트 세션 정리 로직 점검 |
| 권한 거절 급증 | `AUTH_FORBIDDEN`이 5분 20건 초과 | WARN | 권한 매트릭스/클라이언트 노출 메뉴 권한 점검 |
| refresh 실패 증가 | `AUTH_REFRESH_TOKEN_*` 합계가 5분 30건 초과 | HIGH | refresh 회전 정책/저장소 TTL/동시 요청 경합 점검 |

---

## 5. 운영 점검 절차

1. 대시보드에서 5분 윈도우 기준 code별 급증 구간 확인
2. 동일 시점 배포/트래픽 이벤트와 비교
3. `path` 상위 endpoint 기준으로 원인 범위를 축소
4. 상세 로그(`detail`)로 토큰 만료/무효/형식 오류를 구분
5. 임계치 초과가 15분 이상 지속되면 incident로 승격
