# PROJECT_AGENT (ticket-rush-deploy sidecar)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-03-01 06:47:14`
> - **Updated At**: `2026-03-01 06:47:14`
> - **Target**: `AGENT`
> - **Surface**: `AGENT_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Scope
> - Rules
> - Deploy Contract
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-rush-deploy`의 sidecar 운영 규칙을 정의한다.
- 코드/배포 자동화 변경은 인프라 코드베이스 기준으로 수행한다.

## Rules
- 실행 기준은 `deploy/aws/terraform`, `deploy/aws/docker-compose`, `deploy/aws/scripts`를 우선한다.
- 운영 비밀값은 레포에 저장하지 않고 환경변수/시크릿으로만 관리한다.
- 세션 이어받기 품질을 위해 `task.md`와 `meeting-notes/README.md`를 항상 최신화한다.
- 실배포에서 키페어 없는 SSM 배포를 기본값으로 유지한다.

## Deploy Contract
- 기본 배포 경로: `Terraform(EC2/IAM/SG) -> ECR push -> SSM deploy.sh`
- 런타임 기본 모드:
  - 접근: `http://<public-ip>/`
  - API 프록시: `/api`
  - seed: 환경변수 제어 (`APP_SEED_KPOP20_ENABLED`, `APP_SEED_KPOP20_MARKER_KEY`)
