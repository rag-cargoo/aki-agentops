# Task Dashboard (ticket-rush-deploy sidecar)

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
> - Scope
> - Checklist
> - Current Items
> - Next Items
<!-- DOC_TOC_END -->

## Scope
- 이 문서는 `ticket-rush-deploy` 운영 sidecar 태스크를 관리한다.
- 구현 상세는 인프라 코드 변경(PR/커밋)과 함께 추적한다.

## Checklist
- [x] TRD-SC-001 sidecar baseline 등록 (`project-map` + 필수 문서 세트)
- [x] TRD-SC-002 keyless SSM 배포 경로 구현 (`deploy.sh`, terraform key optional)
- [x] TRD-SC-003 EC2 단일노드 배포 검증 (ECR push + SSM rollout + HTTP/API 확인)
- [~] TRD-SC-004 배포 레포 remote 확정 및 CI/OIDC 연동 규칙 문서화

## Current Items
- TRD-SC-001 sidecar baseline 등록
  - Status: DONE
  - Description:
    - `prj-docs/projects/ticket-rush-deploy` baseline 문서(`README`, `PROJECT_AGENT`, `task`, `meeting-notes/README`, `rules`)를 생성한다.
    - `project-map.yaml`, `projects/README`, `github-pages/sidebar-manifest.md`에 신규 프로젝트를 등록한다.
  - Evidence:
    - `prj-docs/projects/project-map.yaml`
    - `prj-docs/projects/ticket-rush-deploy/README.md`
    - `prj-docs/projects/ticket-rush-deploy/PROJECT_AGENT.md`
    - `prj-docs/projects/ticket-rush-deploy/task.md`
    - `prj-docs/projects/ticket-rush-deploy/meeting-notes/README.md`
    - `prj-docs/projects/ticket-rush-deploy/rules/architecture.md`
    - `github-pages/sidebar-manifest.md`

- TRD-SC-002 keyless SSM 배포 경로 구현
  - Status: DONE
  - Description:
    - terraform에 `enable_ssh`, optional `key_name`을 반영해 키페어 없는 배포를 기본화한다.
    - `deploy.sh`에 SSM 모드를 추가해 SSH 키 없이 원격 compose 배포를 실행한다.
  - Evidence:
    - `workspace/ticket-rush-deploy/deploy/aws/terraform/variables.tf`
    - `workspace/ticket-rush-deploy/deploy/aws/terraform/main.tf`
    - `workspace/ticket-rush-deploy/deploy/aws/scripts/deploy.sh`
    - `workspace/ticket-rush-deploy/README.md`

- TRD-SC-003 EC2 단일노드 배포 검증
  - Status: DONE
  - Description:
    - ECR 이미지 push 후 SSM 배포를 수행하고 프론트/API 헬스를 확인한다.
    - H2 URL/seed 프로필 문제를 수정해 `/api/concerts/search` 정상 응답을 확인한다.
  - Evidence:
    - runtime: `http://3.34.42.112/` (`200`)
    - runtime: `http://3.34.42.112/service` (`200`)
    - runtime: `http://3.34.42.112/api/concerts/search?page=0&size=1` (`200`)
    - `workspace/ticket-rush-deploy/deploy/aws/docker-compose/ticket-rush/docker-compose.ec2.yml`

## Next Items
- `TRD-SC-004` 배포 전용 원격 레포(remote URL/branch 정책) 확정
- GitHub Actions OIDC role/secrets 연동 가이드 문서화
- 스테이징/운영 seed 정책 분리(`APP_SEED_KPOP20_ENABLED` 기본 false) 적용
