# Meeting Notes: Node Instance Type to m7i-flex.large

## 안건 1: master/worker 인스턴스 타입을 어떤 기준으로 둘지 결정
- Created At: 2026-04-28 09:18:00
- Updated At: 2026-04-28 09:18:00
- Status: DONE
- 검토사항:
  - 현재 Terraform 기본값은 `node_instance_type = "t3.medium"`이었고, 로컬 `terraform.tfvars`는 `t3.small`로 더 낮아져 있었다.
  - Kubernetes master/worker를 같은 타입으로 유지하려면 `node_instance_type` 한 값만 바꾸면 된다.
  - bastion은 별도 변수 `bastion_instance_type`로 관리되므로 노드 사양 상향과 분리할 수 있다.
- 확인사항:
  - AWS 조회 기준 `m7i-flex.large`는 `ap-northeast-2a`에서 제공된다.
  - 조회 사양은 `2 vCPU / 8192 MiB / x86_64`다.
- 결정사항:
  - `k8s-master`, `k8s-worker1` 공통 인스턴스 타입은 `m7i-flex.large`로 고정한다.
  - bastion은 `t3.small`을 유지한다.
  - Terraform 기본값, 예시 파일, 로컬 실행값을 모두 같은 기준으로 맞춘다.
