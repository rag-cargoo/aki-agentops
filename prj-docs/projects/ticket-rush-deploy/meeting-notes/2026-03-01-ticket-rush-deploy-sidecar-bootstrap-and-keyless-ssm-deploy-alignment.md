# Meeting Notes: Ticket Rush Deploy Sidecar Bootstrap and Keyless SSM Deploy Alignment (ticket-rush-deploy)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 06:47:14`
> - **Updated At**: `2026-03-01 06:47:14`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - 안건 1: sidecar 등록
> - 안건 2: 배포 경로 표준화
> - 안건 3: 런타임 검증
> - 안건 4: 후속 과제
<!-- DOC_TOC_END -->

## 안건 1: sidecar 등록
- Status: DONE
- 요약:
  - `ticket-rush-deploy`를 `project-map`과 sidebar에 등록했다.
  - 세션 연속성을 위해 baseline 문서(`README`, `PROJECT_AGENT`, `task`, `meeting-notes`, `rules`)를 생성했다.

## 안건 2: 배포 경로 표준화
- Status: DONE
- 요약:
  - 배포 기본 모드를 keypair-less SSM으로 정렬했다.
  - Terraform에서 SSH ingress를 optional로 전환하고, `deploy.sh`는 SSM/SSH dual-mode를 지원하도록 확장했다.

## 안건 3: 런타임 검증
- Status: DONE
- 요약:
  - EC2 단일노드 배포에서 `/`, `/service`, `/api/concerts/search` 응답을 확인했다.
  - H2 URL/seed profile 이슈를 수정해 시드 데이터 포함 응답까지 복구했다.

## 안건 4: 후속 과제
- Status: DOING
- 요약:
  - 배포 전용 원격 레포(remote URL) 확정 및 문서 반영
  - CI OIDC role/secrets/vars 표준 설정을 sidecar에 고정
