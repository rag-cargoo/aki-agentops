# AWS Air-Gap Simulation Baseline

## 목적
- 이 문서는 `서버 구축 테스트` 과제를 AWS에서 실습하되, 실제 폐쇄망과 동일한 운영 절차를 유지하기 위한 기준선이다.
- 이 프로젝트에서 AWS는 하드웨어 대체 실습 환경일 뿐이며, 설치/배포 절차는 실제 폐쇄망에 그대로 이식 가능해야 한다.

## 핵심 선언
- 이 프로젝트의 기본 실습 환경은 `AWS 기반 air-gap simulation`이다.
- Terraform은 `인프라 재현성 확보`를 위한 도구이며, 폐쇄망 설치 절차를 대체하지 않는다.
- 과제 적합성 판단 기준은 `AWS 사용 여부`가 아니라 `노드가 인터넷 없이 설치/운영 가능한가`다.

## 왜 이렇게 하는가
1. 과제 재실행과 초기화를 빠르게 반복할 수 있어야 한다.
2. 네트워크 격리 구조를 코드로 고정해 제출용 설정 파일과 직접 연결해야 한다.
3. AWS 위에서 실습하더라도 실제 폐쇄망 VM에 그대로 옮길 수 있는 절차를 유지해야 한다.
4. Kubernetes/DB/모니터링 설치 과정을 관리형 서비스가 아니라 직접 제어 가능한 형태로 남겨야 한다.

## Terraform 채택 원칙
- Terraform은 아래 범위까지만 사용한다.
  - `VPC`
  - public/private `subnet`
  - `route table`
  - `security group`
  - `bastion`
  - `k8s-master`
  - `k8s-worker1`
- Terraform으로 설치 절차를 감추지 않는다.
- `user_data`, `remote-exec`는 최소 부트스트랩 수준으로만 사용하고, 실제 설치 명령의 단일 기준은 별도 매뉴얼/설정 파일에 둔다.

## 절대 준수 사항
1. `k8s-master`, `k8s-worker1`은 public IP 없이 private subnet에만 둔다.
2. private subnet에는 `NAT Gateway`나 일반 인터넷 outbound 경로를 두지 않는다.
3. 노드에서 `apt`, `yum`, `dnf`, `docker pull`, `helm repo add` 같은 외부 네트워크 의존 설치를 직접 수행하지 않는다.
4. 필요한 `deb/rpm`, 바이너리, 컨테이너 이미지, manifest, chart는 사전 수집 후 수동 반입 가능한 구조로 관리한다.
5. `EKS`, `RDS`, 관리형 모니터링 등 AWS 관리형 서비스는 사용하지 않는다.
6. `bastion`은 관리자 진입점일 뿐이며, private 노드의 인터넷 프록시나 패키지 미러 대체물로 사용하지 않는다.
7. 실제 폐쇄망 VM으로 옮겨도 절차가 동일해야 한다.

## 허용되는 AWS 역할
- 격리 네트워크 제공
- VM 대체용 EC2 제공
- 관리자 접속용 bastion 제공
- Terraform state 및 코드 기반 재현성 제공

## 허용되지 않는 설계
- private 노드에 `NAT`를 붙여 필요한 이미지를 실시간 pull 하는 방식
- `ECR`, `S3`, 공인 패키지 저장소를 설치 시점에 직접 참조하는 방식
- 관리형 Kubernetes/DB/모니터링으로 과제 범위를 축소하는 방식
- 설치 절차 대부분을 Terraform 내부 provisioner에 숨겨 수동 매뉴얼 없이 지나가는 방식

## 운영 설명 문구 기준
- 문서에는 아래 의미가 유지되도록 설명한다.
  - `AWS 기반 폐쇄망 시뮬레이션 환경`
  - `온프레미스 폐쇄망과 동일한 오프라인 설치 절차를 재현`
  - `Terraform은 네트워크/서버 재현용, 서비스 설치는 별도 오프라인 절차 기준`

## 성공 기준
- Terraform만으로 격리된 실습 네트워크와 서버 골격을 다시 만들 수 있다.
- 오프라인 artifact 묶음만 있으면 노드 인터넷 없이 Kubernetes/DB/모니터링 설치를 진행할 수 있다.
- 설치 절차 문서가 AWS 전용 지식 없이도 일반 폐쇄망 VM에 이식 가능하다.
