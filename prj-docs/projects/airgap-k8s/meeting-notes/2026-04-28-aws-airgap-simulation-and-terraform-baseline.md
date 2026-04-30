# Meeting Notes: AWS Air-Gap Simulation and Terraform Baseline

## 안건 1: AWS를 과제 실습 환경으로 사용해도 되는지 판단
- Created At: 2026-04-28 01:05:00
- Updated At: 2026-04-28 01:05:00
- Status: DONE
- 검토사항:
  - 과제 원문은 `온프레미스(폐쇄망 = Air-gapped)`와 `인터넷이 불가능한 네트워크 환경`을 요구한다.
  - 실습 인프라를 AWS에 두더라도, 노드 설치/배포 절차가 인터넷 없이 성립하면 폐쇄망 시뮬레이션 환경으로는 충분히 활용할 수 있다.
  - 핵심은 `AWS를 쓰는가`가 아니라 `노드가 외부 네트워크 없이 독립적으로 설치/운영 가능한가`다.
- 결정사항:
  - 이 프로젝트의 실습 환경은 `AWS 기반 air-gap simulation`으로 정의한다.
  - 제출/설명 문서에는 `온프레미스와 동일한 오프라인 절차를 AWS에서 재현한 실습 환경`임을 명시한다.
  - `EKS`, `RDS`, 기타 관리형 서비스는 사용하지 않고 `EC2 + kubeadm` 기준으로 진행한다.

## 안건 2: Terraform을 기본 인프라 도구로 채택할지 판단
- Created At: 2026-04-28 01:05:00
- Updated At: 2026-04-28 01:05:00
- Status: DONE
- 검토사항:
  - VMware 수동 실습보다 Terraform이 재현성과 재실습 속도에서 유리하다.
  - 과제 재진행, 환경 초기화, 같은 구조 재구축이 반복될 가능성이 높다.
  - 네트워크 구조와 보안 경계를 코드로 남기면 제출용 설정 파일 묶음에도 직접 연결된다.
- 결정사항:
  - 실습 인프라 프로비저닝 기본 도구는 `Terraform`으로 채택한다.
  - Terraform의 책임 범위는 `VPC`, `subnet`, `route table`, `security group`, `bastion`, `master`, `worker`까지로 제한한다.
  - Kubernetes/DB/모니터링 설치 절차는 Terraform `remote-exec`에 숨기지 않고 별도 오프라인 매뉴얼과 설정 파일로 관리한다.
- 이유:
  - 재현성과 초기화 속도가 높다.
  - 폐쇄망 네트워크 구조를 선언형으로 고정할 수 있다.
  - AWS 위에서 실습하더라도 온프레미스 이전 가능한 배포 절차를 분리 유지할 수 있다.

## 안건 3: 절대 기준선
- Created At: 2026-04-28 01:05:00
- Updated At: 2026-04-28 01:05:00
- Status: DONE
- 결정사항:
  - private 노드(`k8s-master`, `k8s-worker1`)는 public IP 없이 private subnet에만 둔다.
  - private 노드에는 `IGW`, `NAT`, 외부 패키지 저장소 직접 접근을 두지 않는다.
  - 필요한 패키지/바이너리/이미지/manifest는 미리 수집해서 수동 반입 가능한 형태로 관리한다.
  - bastion은 관리자 접속용으로만 사용하고, 클러스터 노드의 인터넷 프록시처럼 쓰지 않는다.
  - 설치 절차는 `실제 폐쇄망 VM`으로 옮겨도 그대로 재사용 가능해야 한다.
- 후속작업:
  - 담당: Codex
  - 기한: 2026-04-28
  - 상태: TODO
  - 내용:
    - 기준 문서 작성 및 진입점 고정
    - Terraform 범위 명시
    - 오프라인 artifact 목록 작성
