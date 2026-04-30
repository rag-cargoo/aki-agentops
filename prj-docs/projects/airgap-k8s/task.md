# Task Board (airgap-k8s)

<!-- DOC_META_START -->
> [!NOTE]
> - **Created At**: `2026-04-28 00:06:47`
> - **Updated At**: `2026-04-30 00:35:00`
> - **Target**: `BOTH`
> - **Surface**: `PUBLIC_NAV`
<!-- DOC_META_END -->

<!-- DOC_TOC_START -->
## 문서 목차 (Quick Index)
---
> [!TIP]
> - Active Target
> - Assignment Checklist
> - Task Governance
> - Task Files
> - Current Items
<!-- DOC_TOC_END -->

## Active Target
- Status: DOING
- Goal: `서버 구축 테스트` 과제 항목을 기준으로 실제 작업을 시작한다.

## Assignment Checklist
- [ ] 인터넷이 불가능한 네트워크 환경 확인
- [ ] 리눅스 기본 구성 확인
- [ ] `devops` 사용자 생성 및 `sudo` 권한 부여
- [ ] `k8s-master`, `k8s-worker1` 호스트명 설정
- [ ] `/etc/hosts` 등록
- [ ] `master + worker` Kubernetes 클러스터 구성
- [ ] `Calico` 적용
- [ ] `MySQL` 또는 `MariaDB` 배포
- [ ] `MongoDB` 배포
- [ ] `Prometheus` 배포
- [ ] `Grafana` 배포
- [ ] `Grafana Alloy` 배포
- [ ] `Prometheus` / `Grafana` 외부 접근 설정
- [ ] 단계별 매뉴얼 작성
- [ ] 설정 파일 압축본 정리

## Task Governance
- Authority: `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
- `task.md`에는 확정된 절차와 실제 착수/완료 항목만 기록한다.
- 미확정 예상 단계는 `meeting-notes/*.md` 또는 `manual/00-제출-매뉴얼-개요/README.md`에만 남긴다.
- `Current Items`는 실제 제출 매뉴얼 장 순서에 맞춰 묶는다.
- 장별 `tasks/*.md`는 ClickUp 과제문 작업 순서와 같은 번호로 맞춘다.

## Task Files
- Index: [Task Files Index](./tasks/README.md)
- `01`: [인터넷 불가능 네트워크 환경 및 리눅스 기본 구성](./tasks/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성.md)
- `02`: [사용자 및 네트워크 설정](./tasks/02-사용자-및-네트워크-설정.md)
- `03`: [쿠버네티스 클러스터 구성](./tasks/03-쿠버네티스-클러스터-구성.md)
- `04`: [서비스 배포 및 모니터링 설정](./tasks/04-서비스-배포-및-모니터링-설정.md)
- `05`: [프로메테우스 그라파나 외부 접근 설정](./tasks/05-프로메테우스-그라파나-외부-접근-설정.md)
- `06`: [제출](./tasks/06-제출.md)

## Current Items
- 04. 서비스 배포 및 모니터링 설정 / 서비스별 독립 단원 구조 확정
  - Status: DOING
  - Evidence: `prj-docs/projects/airgap-k8s/tasks/04-서비스-배포-및-모니터링-설정.md`
  - Notes: MySQL/MariaDB, MongoDB, Prometheus, Grafana, Grafana Alloy는 선택 실행 가능해야 하므로 서비스별 다운로드/검증/전송/import/run/verify 책임을 각 서비스 디렉터리에 둔다. 전체 묶음 target은 편의용으로만 유지한다.
- 03. 쿠버네티스 클러스터 구성 / 환경변수 기반 실행값 정리
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/.env.example`
  - Notes: `.env`는 `<프로젝트-루트>/.env`에 생성하고, 사용자 로컬 절대경로는 매뉴얼에 쓰지 않는다. 키 파일 경로는 유지한 채 bastion/master/worker IP는 `ops/01-airgap-linux-environment/scripts/sync-env-from-terraform.sh`로 Terraform output 기준 갱신한 뒤 `ops/01-airgap-linux-environment/scripts/load-project-env.sh`로 로드한다.
- 00. 루트 매뉴얼 진입점과 전체 실행 순서 분리
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-전체-실행-순서.md`
  - Notes: 루트 `manual/README.md`는 index로 유지하고, 전체 실행 순서는 별도 문서 `01-전체-실행-순서.md`로 분리한다.
- 03. 쿠버네티스 클러스터 구성 / 종합 실행 순서와 preflight 절차 반영
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/03-쿠버네티스-클러스터-구성/README.md`
  - Notes: 루트 `manual/README.md`에는 전체 실행 순서를 두고, `manual/03`에는 bastion 점프, 자산 반입, preflight 스크립트 실행 순서를 둔다.
- 03. 쿠버네티스 클러스터 구성 / manual ansible 단계 분리와 ops-runtime 번들 정리
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/ops/03-kubernetes-cluster/manual-kubeadm/README.md`
  - Notes: `03`은 제출 매뉴얼과 ops 모두 `manual-kubeadm/`, `ansible-kubeadm/`, `calico/`로 분리하고, bastion 실행 원본은 `delivery/ops-runtime.tar.gz`로 별도 번들링한다. 수동 kubeadm은 access/transfer, preflight, node baseline, containerd, Kubernetes packages, image import, control-plane init, Calico, worker join, cluster verify를 `01~10` 단계로 나누고 각 단원별 `NN-MM-run/verify` 스크립트와 `step-03-02-*` target을 1:1로 맞춘다.
- 02~03. 실제 단계는 `step -> verify -> state marker` 구조로 정리
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/ops/02-user-network/Makefile`
  - Notes: 세부 step은 실행 후 같은 단계 verify를 즉시 호출하고, 성공하면 `.codex/runtime/airgap-k8s-state/*.done` 마커를 남긴다. `all-verify`는 이 마커 기준으로 실제 적용 여부를 표시한다.
- 01. 인터넷 불가능 네트워크 환경 및 리눅스 기본 구성 / 다운로드 문서 매뉴얼 배치
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/02-쿠버네티스-설치용-자산-다운로드.md`
  - Notes: 설치용 자산 다운로드 문서는 `manual/01`에 두고, 실제 파일은 `assets/offline-assets/`, 반입 번들은 `delivery/offline-assets/`, 서버 설치 경로는 `/opt/offline-assets`로 분리한다.
- 00. 제출 매뉴얼 개요 / 사전 조사 정보 수집 템플릿 추가
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/00-제출-매뉴얼-개요/03-사전-조사-정보-수집-템플릿.example.yaml`
  - Notes: bastion/control node, SSH 경로, 노드 IP, 수동/Ansible 선택, `.env` 반영값을 먼저 정리하는 YAML 예시 템플릿을 추가했다. 실제 값 파일은 Git ignore 처리한다.
- 03. 쿠버네티스 클러스터 구성 / 설치용 자산 다운로드와 검증 우선
  - Status: DOING
  - Evidence: `prj-docs/projects/airgap-k8s/tasks/03-쿠버네티스-클러스터-구성.md`
  - Notes: 현재 최우선은 `공식문서 링크 정리 -> 다운로드 대상 목록 확정 -> 로컬 PC 실제 다운로드 검증 -> delivery/offline-assets 반입 번들 정리 -> /opt/offline-assets 반입 구조 검증 -> VM 설치 검증` 순서다. `make 08-k8s-assets-download`, `make 08-k8s-assets-verify`로 Kubernetes 오프라인 자산 실제 다운로드 검증까지 수행했다.
- 01. 인터넷 불가능 네트워크 환경 및 리눅스 기본 구성 / Terraform 재적용 여부 검토
  - Status: DOING
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/ops/01-airgap-linux-environment/aws-terraform-simulation/tfplan`
  - Notes: 이전 세션의 `apply -> destroy` 이력은 `terraform.tfstate.backup`의 실리소스 기록과 현재 빈 `terraform.tfstate`로 확인했다. 방금 `make tf-validate`, `make tf-plan`도 재실행했고 현재 상태는 destroy 이후 재적용 대기다.
- 03. 쿠버네티스 클러스터 구성 / 오프라인 자산 서버 배치 경로 고정
  - Status: DOING
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-29-offline-assets-packaging-and-server-path.md`
  - Notes: 로컬 작업 원본은 `assets/offline-assets/`, 반입 번들 디렉터리는 `delivery/offline-assets/`, 반입 압축본은 `delivery/offline-assets.tar.gz`, 서버 기준 경로는 `/opt/offline-assets`로 고정했다.
- 02~03. VM 기준 실제 설치 절차 전환
  - Status: DOING
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-29-aws-simulation-and-vm-execution-boundary.md`
  - Notes: `01`은 AWS 시뮬레이션 또는 VM 환경 재현으로 두고, `02` 이후 실제 설치 절차는 VM 노드 기준으로 진행한다.

## Completed Decisions
- AIRGAP-SC-001 실습 환경 가정 고정
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-28-aws-airgap-simulation-and-terraform-baseline.md`
  - Notes: 실습 기준은 `AWS 기반 air-gap simulation`이며, 설치 절차는 `온프레미스와 동일한 오프라인 기준`을 따른다.
- AIRGAP-SC-005 Terraform 실습 인프라 범위 고정
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/rules/aws-airgap-simulation-baseline.md`
  - Notes: Terraform은 `VPC/subnet/route table/security group/bastion/master/worker` 범위까지만 담당한다.
- AIRGAP-SC-006 제출 매뉴얼 구조 및 생성 시점 고정
  - Status: DONE
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/manual/00-제출-매뉴얼-개요/README.md`
  - Notes: `00`은 공통 개요이고, 실제 구축 절차는 `01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/README.md`부터 시작한다.
- AIRGAP-SC-007 Terraform 디렉터리 및 VPC 골격 작성
  - Status: DONE
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/ops/01-airgap-linux-environment/aws-terraform-simulation/`
  - Notes: bastion public 접근 + private node 폐쇄망 구조 기준으로 루트 `Makefile`, Terraform Makefile, VPC/EC2 골격을 생성했다.
- AIRGAP-SC-008 Terraform 값 확정 및 plan 재현 검증
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-28-terraform-validation-and-plan-replay.md`
  - Notes: 로컬 `terraform.tfvars` 기준으로 `make tf-validate`, `make tf-plan`을 재실행했고 `13 to add / 0 to change / 0 to destroy` 계획을 확인했다.
- AIRGAP-SC-009 Terraform apply/destroy 이력 복구 확인
  - Status: DONE
  - Evidence: `workspace/infra/airgap/kubernetes/airgap-k8s/ops/01-airgap-linux-environment/aws-terraform-simulation/terraform.tfstate.backup`
  - Notes: 이전 세션에서 실제 인프라 생성과 제거가 한 차례 수행됐고, 현재 state는 destroy 이후 빈 상태임을 확인했다.
- AIRGAP-SC-010 Kubernetes 노드 인스턴스 타입 상향
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-28-node-instance-type-m7i-flex-large.md`
  - Notes: `k8s-master`, `k8s-worker1` 공통 타입을 `m7i-flex.large`로 맞추고 bastion은 `t3.small`로 유지한다.
- AIRGAP-SC-011 단계 중심 디렉터리 트리 정렬
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-29-kubernetes-manual-ansible-structure-strategy.md`
  - Notes: 기존 구조는 이후 ClickUp 원문 계층 재확인으로 보정 대상이 됐다.
- AIRGAP-SC-012 과제문 번호 체계 재정렬
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-29-kubernetes-manual-ansible-structure-strategy.md`
  - Notes: 기존 결정은 ClickUp 원문 재확인 전 기준이며, 현재는 원문 작업 순서에 맞춰 `01~06`을 다시 정렬했다.
- AIRGAP-SC-013 ClickUp 원문 계층 재확인 및 구조 보정
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-29-clickup-assignment-source-hierarchy-correction.md`
  - Notes: `주제`는 개요로 흡수하고, 실제 구축 작업은 `인터넷이 불가능한 네트워크 환경 + 리눅스 기본 구성`부터 시작하도록 매뉴얼/ops/task 구조를 보정했다.
- AIRGAP-SC-014 오프라인 자산 압축 및 서버 경로 기준 고정
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-29-offline-assets-packaging-and-server-path.md`
  - Notes: 오프라인 자산은 레포 내부 작업 원본과 서버 배치 경로를 분리하고, 서버 설치 기준 경로는 `/opt/offline-assets`로 고정한다.
- AIRGAP-SC-015 AWS 시뮬레이션과 VM 실제 설치 경계 고정
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-29-aws-simulation-and-vm-execution-boundary.md`
  - Notes: AWS는 `01` 장의 폐쇄망 시뮬레이션 용도로만 사용하고, `02` 이후 실제 설치 절차는 VM 기준으로 진행한다.
- AIRGAP-SC-016 수동 kubeadm 클러스터 설치 검증
  - Status: DONE
  - Evidence: `prj-docs/projects/airgap-k8s/meeting-notes/2026-04-30-manual-kubeadm-install-verification.md`
  - Notes: `03-02-manual-kubeadm-run`과 `03-02-manual-kubeadm-verify`가 성공했고, `k8s-master`, `k8s-worker1` 두 노드가 Kubernetes `v1.35.4` Ready 상태이며 이미지 pull 실패가 없는 상태로 확인됐다.
