# Meeting Notes: Assignment-Aligned Infra Chapter Scope

## 안건 1: `02-환경-준비.md`의 과제 대응 범위 정렬
- Created At: 2026-04-28 03:35:00
- Updated At: 2026-04-28 03:35:00
- Status: DONE
- 검토사항:
  - 과제문 첫 요구는 `인터넷이 불가능한 네트워크 환경`과 `리눅스 기본 구성`이다.
  - 따라서 `02-환경-준비.md`는 단순 Terraform 소개가 아니라, 폐쇄망 네트워크와 bastion 진입 구조를 먼저 다뤄야 한다.
- 결정사항:
  - `02-환경-준비.md`의 1차 목표는 `인터넷이 불가능한 private 노드 환경`을 AWS에서 재현하는 것이다.
  - `bastion`은 관리자 접속용 public subnet에 두고, `k8s-master`, `k8s-worker1`은 private subnet에 둔다.
  - private 노드는 public IP 없이 운영하고, 인터넷 outbound 경로를 두지 않는다.

## 안건 2: bastion 포함 여부
- Created At: 2026-04-28 03:35:00
- Updated At: 2026-04-28 03:35:00
- Status: DONE
- 결정사항:
  - bastion은 `01` 장 범위에 포함한다.
  - 관리자 접근은 bastion으로만 허용하고, Kubernetes 노드는 bastion을 통해서만 접근 가능하게 설계한다.
  - 이 구조가 이후 `devops` 사용자 설정, hostname, `/etc/hosts`, kubeadm 작업의 전제 조건이 된다.
