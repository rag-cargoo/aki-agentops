# Meeting Notes: Terraform Path and Makefile Strategy

## 안건 1: Terraform 코드 경로 결정
- Created At: 2026-04-28 02:50:00
- Updated At: 2026-04-28 02:50:00
- Status: DONE
- 검토사항:
  - 이 프로젝트는 아직 루트에 실구현 코드가 거의 없어서 Terraform 경로를 지금 고정하는 편이 좋다.
  - `manual/`, sidecar 문서, 실제 IaC 코드는 서로 역할이 다르므로 경로를 분리해야 한다.
- 결정사항:
  - Terraform 코드는 프로젝트 루트 `./ops/02-environment/A-terraform/`에 둔다.
  - 제출 매뉴얼 `02-환경-준비.md`와 sidecar `tasks/02-환경-준비.md`는 이 경로를 기준으로 설명한다.
  - Terraform 코드는 `VPC`, `subnet`, `route table`, `security group`, `bastion`, `master`, `worker` 범위 골격부터 시작한다.

## 안건 2: Makefile 전략 결정
- Created At: 2026-04-28 02:50:00
- Updated At: 2026-04-28 02:50:00
- Status: DONE
- 검토사항:
  - 루트에서 바로 실행할 진입점이 있으면 반복 작업이 편하다.
  - 반면 Terraform 디렉터리 안에도 독립적인 작업용 Makefile이 있어야 디렉터리 단독 사용성이 좋다.
- 결정사항:
  - 프로젝트 루트에는 상위 진입점 `Makefile`을 둔다.
  - `./ops/02-environment/A-terraform/Makefile`은 실제 Terraform 명령을 담당한다.
  - 루트 `Makefile`은 Terraform 디렉터리 `Makefile`을 호출하는 위임형 구조로 유지한다.

## 안건 3: 인프라 장 착수 처리
- Created At: 2026-04-28 02:50:00
- Updated At: 2026-04-28 02:50:00
- Status: DONE
- 결정사항:
  - 인프라 장을 실제로 시작했으므로 `manual/02-환경-준비.md`를 생성한다.
  - sidecar 상세 task도 `tasks/02-환경-준비.md`를 생성한다.
  - `AIRGAP-SC-007`은 Terraform 디렉터리와 VPC 골격 생성까지 완료되면 DONE 처리한다.
