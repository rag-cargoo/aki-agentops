# 2026-05-01 Manual kubeadm Step Target Alignment

## Context
- 기존 `03` 구조에는 `common/`과 `manual-kubeadm/01..06`이 섞여 있어 사전점검, 반입, 실제 설치 단계의 책임 경계가 불명확했다.
- 상위 `manual-kubeadm/scripts/*.sh`에 설치 로직을 모으면 단원별 실행 명령이 보이지 않아 제출 매뉴얼과 ops 디렉터리의 대응 관계가 약해진다.
- 사용자는 각 단원마다 실제 실행 스크립트와 검증 스크립트가 있어야 한다고 판단했다.

## Decision
- `03` 수동 설치 흐름에서 `common/`을 사용하지 않는다.
- 사전점검과 반입은 `manual-kubeadm/01-access-and-transfer`, `manual-kubeadm/02-preflight`로 편입한다.
- 수동 kubeadm은 `01`~`10` 단계로 세분화한다.
- 각 단원은 자기 `scripts/` 아래에 번호 접두어가 붙은 `run`/`verify` 스크립트를 둔다.
- 상위 `manual-kubeadm/scripts/manual-kubeadm-lib.sh` 같은 공용 설치 본체는 사용하지 않는다.
- `03-01-preflight-*` target은 기존 상위 검증 호환을 위해 alias로만 유지한다.
- 단원 내부 스크립트 파일명은 `NN-MM-역할-이름.sh` 형식으로 둔다.
- 같은 작업 단위의 `run`과 `verify`는 같은 `NN-MM`을 공유한다.
- helper/diagnostic 스크립트는 실행 우선순위에 맞춰 별도 `NN-MM`을 사용한다.
- 제출 매뉴얼도 `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/01..10` 디렉터리로 구성해 ops의 `manual-kubeadm/01..10`과 1:1로 맞춘다.

## Step Mapping
| 순서 | ops 디렉터리 | 실행 target | 검증 target |
| --- | --- | --- | --- |
| `03-02-01` | `manual-kubeadm/01-access-and-transfer/` | `step-03-02-01-access-and-transfer-run` | `step-03-02-01-access-and-transfer-verify` |
| `03-02-02` | `manual-kubeadm/02-preflight/` | `step-03-02-02-preflight-run` | `step-03-02-02-preflight-verify` |
| `03-02-03` | `manual-kubeadm/03-node-baseline/` | `step-03-02-03-node-baseline-run` | `step-03-02-03-node-baseline-verify` |
| `03-02-04` | `manual-kubeadm/04-containerd/` | `step-03-02-04-containerd-run` | `step-03-02-04-containerd-verify` |
| `03-02-05` | `manual-kubeadm/05-kubernetes-packages/` | `step-03-02-05-kubernetes-packages-run` | `step-03-02-05-kubernetes-packages-verify` |
| `03-02-06` | `manual-kubeadm/06-image-import/` | `step-03-02-06-image-import-run` | `step-03-02-06-image-import-verify` |
| `03-02-07` | `manual-kubeadm/07-control-plane-init/` | `step-03-02-07-control-plane-init-run` | `step-03-02-07-control-plane-init-verify` |
| `03-02-08` | `manual-kubeadm/08-calico/` | `step-03-02-08-calico-run` | `step-03-02-08-calico-verify` |
| `03-02-09` | `manual-kubeadm/09-worker-join/` | `step-03-02-09-worker-join-run` | `step-03-02-09-worker-join-verify` |
| `03-02-10` | `manual-kubeadm/10-cluster-verify/` | 없음 | `step-03-02-10-cluster-verify` |

## Script Naming
| 순서 | scripts |
| --- | --- |
| `01` | `01-01-render-env-from-survey-yaml.sh`, `01-02-run-access-and-transfer.sh`, `01-02-verify-access-and-transfer.sh` |
| `02` | `02-01-kubeadm-preflight-check.sh`, `02-02-run-preflight.sh`, `02-02-verify-preflight.sh` |
| `03` | `03-01-run-node-baseline.sh`, `03-01-verify-node-baseline.sh` |
| `04` | `04-01-run-containerd.sh`, `04-01-verify-containerd.sh` |
| `05` | `05-01-run-kubernetes-packages.sh`, `05-01-verify-kubernetes-packages.sh` |
| `06` | `06-01-run-image-import.sh`, `06-01-verify-image-import.sh` |
| `07` | `07-01-run-control-plane-init.sh`, `07-01-verify-control-plane-init.sh` |
| `08` | `08-01-run-calico.sh`, `08-01-verify-calico.sh` |
| `09` | `09-01-run-worker-join.sh`, `09-01-verify-worker-join.sh` |
| `10` | `10-01-verify-cluster.sh`, `10-02-troubleshoot-cluster.sh` |

## Manual Mapping
| manual 디렉터리 | ops 디렉터리 |
| --- | --- |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/01-access-and-transfer/` | `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/02-preflight/` | `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/03-node-baseline/` | `ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/04-containerd/` | `ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/05-kubernetes-packages/` | `ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/06-image-import/` | `ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/07-control-plane-init/` | `ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/08-calico/` | `ops/03-kubernetes-cluster/manual-kubeadm/08-calico/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/09-worker-join/` | `ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/` |
| `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/10-cluster-verify/` | `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/` |
| `manual/03-쿠버네티스-클러스터-구성/ansible-kubeadm/01-node-baseline/` | `ops/03-kubernetes-cluster/ansible-kubeadm/01-node-baseline/` |
| `manual/03-쿠버네티스-클러스터-구성/ansible-kubeadm/02-containerd/` | `ops/03-kubernetes-cluster/ansible-kubeadm/02-containerd/` |
| `manual/03-쿠버네티스-클러스터-구성/ansible-kubeadm/03-kubernetes-packages/` | `ops/03-kubernetes-cluster/ansible-kubeadm/03-kubernetes-packages/` |
| `manual/03-쿠버네티스-클러스터-구성/ansible-kubeadm/04-control-plane-init/` | `ops/03-kubernetes-cluster/ansible-kubeadm/04-control-plane-init/` |
| `manual/03-쿠버네티스-클러스터-구성/ansible-kubeadm/05-calico/` | `ops/03-kubernetes-cluster/ansible-kubeadm/05-calico/` |
| `manual/03-쿠버네티스-클러스터-구성/ansible-kubeadm/06-worker-join/` | `ops/03-kubernetes-cluster/ansible-kubeadm/06-worker-join/` |

## Verification Result
- `make -C ops/03-kubernetes-cluster 03-02-manual-kubeadm-script-verify`: success
- `make -C ops/03-kubernetes-cluster 03-02-manual-kubeadm-verify`: success
- Cluster result:
  - `k8s-master`: `Ready`, `control-plane`, `v1.35.4`, `10.10.20.151`
  - `k8s-worker1`: `Ready`, worker, `v1.35.4`, `10.10.20.154`

## Follow-up
- Ansible kubeadm은 수동 `01..10`과 같은 목적을 자동화하되, Ansible 전용 preflight와 실행 스크립트는 `ansible-kubeadm/` 안에서 별도로 정리한다.
