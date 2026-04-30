# Meeting Notes: Kubernetes Manual and Ansible Structure Strategy

## 안건 1: 과제문 상위 번호와 문서/디렉터리 번호를 어떻게 맞출지 결정
- Created At: 2026-04-29 00:12:00
- Updated At: 2026-04-29 09:35:00
- Status: DONE
- 검토사항:
  - 기존 초안에는 `01-인프라-구축`, `02-오프라인-설치-자산-준비`처럼 과제문에 없는 상위 장이 섞여 있었다.
  - 이 구조는 `환경 준비`, `Terraform`, `오프라인 설치 자산`, `수동/Ansible`을 모두 별도 상위 단계처럼 보이게 만들어 과제문과 어긋난다.
- 결정사항:
  - 상위 장 번호는 과제문 `1~6`과 동일하게 유지한다.
  - 과제문에 없는 준비성 항목은 별도 상위 장으로 올리지 않는다.
  - 대신 `1-A`, `2-A`, `2-B`, `4-A`, `4-B`처럼 해당 상위 장 아래 하위 라벨로 둔다.

## 안건 2: 수동 설치와 Ansible 자동화를 어디에 둘지 결정
- Created At: 2026-04-29 00:12:00
- Updated At: 2026-04-29 09:35:00
- Status: DONE
- 검토사항:
  - Kubernetes 설치를 수동 모드와 Ansible 모드 두 가지로 구현할 계획이다.
  - 두 모드는 서로 다른 구축 방법이 아니라 동일 절차의 실행 주체만 다른 구조여야 한다.
- 결정사항:
  - `4-A`는 kubeadm 수동 설치 절차다.
  - `4-B`는 `4-A` 절차를 그대로 옮긴 Ansible 자동화다.
  - DB/모니터링까지 같이 묶지 않고, 우선 `04. 쿠버네티스 클러스터 구성` 범위 안에서만 분리한다.

## 안건 3: 최종 구조 기준
- Created At: 2026-04-29 00:12:00
- Updated At: 2026-04-29 09:35:00
- Status: DONE
- 구조 원칙:
  - `manual/`은 제출 문서다.
  - `ops/`는 실제 실행 자산이다.
  - `task.md`와 `tasks/*.md`는 sidecar 진행판이다.
  - 세 영역 모두 과제문 상위 번호 `1~6`을 기준으로 맞춘다.
- 현재 기준 트리:
```text
workspace/infra/airgap/kubernetes/airgap-k8s/
├── manual/
│   ├── 00-제출-매뉴얼-개요.md
│   ├── 01-주제.md
│   ├── 02-환경.md
│   ├── 03-사용자-및-네트워크-설정.md
│   ├── 04-쿠버네티스-클러스터-구성.md
│   ├── 05-서비스-배포-및-모니터링-설정.md
│   └── 06-제출물-정리.md
├── ops/
│   ├── 02-environment/
│   │   ├── A-terraform/
│   │   └── B-offline-artifacts/
│   ├── 03-user-network/
│   ├── 04-kubernetes-cluster/
│   │   ├── A-manual/
│   │   └── B-ansible/
│   ├── 05-services-monitoring/
│   └── 06-deliverables/
└── prj-docs/projects/airgap-k8s/tasks/
    ├── 01-주제.md
    └── 02-환경.md
```
- 하위 라벨 기준:
  - `1-A`: 과제 범위
  - `1-B`: 실습 해석 기준
  - `2-A`: 인터넷 불가 네트워크 환경 해석
  - `2-B`: Terraform 기반 air-gap simulation 인프라 준비
  - `2-C`: 오프라인 설치 자산 준비
  - `4-A`: kubeadm 수동 설치
  - `4-B`: Ansible 자동화

## 안건 4: 현재 반영 상태
- Created At: 2026-04-29 09:35:00
- Updated At: 2026-04-29 09:35:00
- Status: DONE
- 반영사항:
  - `manual/01-주제.md`를 생성했다.
  - `manual/02-환경-준비.md`를 `manual/02-환경.md`로 정리했다.
  - `tasks/01-주제.md`를 생성했다.
  - `tasks/02-환경-준비.md`를 `tasks/02-환경.md`로 정리했다.
  - `task.md`, `manual/00`, `meeting-notes/README.md`, 관련 README/rules를 과제문 번호 체계에 맞춰 수정했다.

## 안건 5: 다음 업데이트 원칙
- Created At: 2026-04-29 00:12:00
- Updated At: 2026-04-29 09:35:00
- Status: DONE
- 원칙:
  - 구조 변경은 먼저 회의록에 남기고 반영한다.
  - 미래 장의 매뉴얼 파일과 sidecar task 파일은 실제 착수 시점에만 생성한다.
  - 이후 장에서 세부 준비 항목이 늘어나더라도 새로운 상위 번호를 만들지 않고 해당 장의 하위 라벨로만 확장한다.
