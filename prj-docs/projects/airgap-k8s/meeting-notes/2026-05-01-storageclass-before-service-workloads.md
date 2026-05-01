# 2026-05-01 StorageClass Before Service Workloads

## Context
- `03` 수동 kubeadm 클러스터 구성과 Calico 적용은 완료됐다.
- 현재 클러스터에서 `kubectl get storageclass` 실행 결과는 `No resources found`다.
- `04` 서비스 배포 대상인 MySQL/MariaDB, MongoDB, Prometheus, Grafana는 PVC를 사용할 가능성이 높다.
- 기본 StorageClass가 없으면 PVC가 자동으로 PV를 만들지 못하고 `Pending` 상태로 멈출 수 있다.

## Why kubeadm Does Not Provide It
- `kubeadm`은 Kubernetes control plane과 node bootstrap을 담당한다.
- Calico는 Pod 네트워크를 담당한다.
- 둘 다 스토리지 프로비저너를 설치하지 않는다.
- StorageClass는 클러스터 환경에 따라 별도로 선택해야 하는 애드온이다.
- EKS 같은 관리형 환경은 EBS CSI 같은 프로비저너가 붙을 수 있지만, 직접 만든 kubeadm 클러스터에는 기본 제공되지 않는다.

## Decision
- `04` 서비스 배포 전에 `03` 단계에서 기본 StorageClass를 구성한다.
- `03`의 Kubernetes 기본 구성 범위에 `StorageClass` 단원을 추가한다.
- 과제 제출용 기본 선택지는 `local-path-provisioner v0.0.35`로 둔다.
- NFS provisioner와 Longhorn은 대안으로 기록하되, 이번 과제의 1차 구현은 local-path-provisioner 기준으로 진행한다.

## Rationale
- `04` 서비스 manifest/Helm values가 PVC를 요청해도 자동으로 PV가 바인딩돼야 한다.
- DB와 모니터링 서비스의 데이터 경로를 각 manifest마다 임시 `hostPath`로 흩뜨리면 운영 구조가 불명확해진다.
- `local-path-provisioner`는 폐쇄망에서 준비할 이미지와 manifest가 상대적으로 작고, kubeadm 실습 클러스터에 적용하기 쉽다.
- 단, local-path는 노드 로컬 디스크 기반이므로 운영급 HA 스토리지는 아니다. 이 한계는 제출 매뉴얼에 명시한다.

## Options
| 방식 | 장점 | 단점 | 이번 기준 |
| --- | --- | --- | --- |
| static PV / hostPath | 가장 단순하고 이미지가 필요 없다 | PVC 자동 바인딩이 약하고 서비스별 manifest에 노드 경로가 흩어진다 | 임시 fallback |
| local-path-provisioner | 기본 StorageClass 제공이 쉽고 폐쇄망 준비물이 작다 | 노드 로컬 디스크라 Pod 재스케줄링 시 데이터 위치 제약이 있다 | 1차 선택 |
| NFS provisioner | 여러 노드에서 같은 스토리지를 볼 수 있다 | NFS 서버 구성과 provisioner 이미지/chart가 추가된다 | 대안 |
| Longhorn | 운영형 분산 블록 스토리지에 가깝다 | 준비 이미지가 많고 설치/검증 범위가 커진다 | 후순위 대안 |

## Manual Impact
- `manual/03-쿠버네티스-클러스터-구성/`에 StorageClass 구성 기준을 추가한다.
- StorageClass 운영 기준은 `manual/03-쿠버네티스-클러스터-구성/storageclass/operations.md`에 분리한다.
- `manual/04-서비스-배포-및-모니터링-설정/`은 03에서 기본 StorageClass가 준비됐다는 전제로 작성한다.
- `04`의 MySQL/MongoDB/Prometheus/Grafana values는 `storageClassName`을 명시하거나 기본 StorageClass를 사용한다.

## Implemented Actions
- local-path-provisioner 이미지와 manifest 버전을 `v0.0.35`로 확정했다.
- helper pod 이미지는 `docker.io/library/busybox:1.37.0`로 고정했다.
- 폐쇄망 반입 대상에 local-path-provisioner와 busybox 이미지를 추가했다.
- `03`에 `make 03-03-storageclass-run`, `make 03-03-storageclass-verify` target을 추가했다.
- StorageClass 세부 스크립트는 `03-03-01` 반입, `03-03-02` 이미지 import, `03-03-03` manifest apply/동적 PVC 검증 순서로 분리한다.
- 검증 기준은 `kubectl get storageclass`, 테스트 PVC 생성/Bound 확인, 테스트 Pod 쓰기 확인으로 둔다.

## Verification Result
- `make 03-03-storageclass-run`: success
- `make 03-03-storageclass-verify`: success
- `kubectl get storageclass`: `local-path (default)`
- `kubectl get pvc -A`: `No resources found` after smoke cleanup
- `kubectl get pv`: `No resources found` after smoke cleanup
- `local-path-provisioner`: `1/1 Running` in namespace `local-path-storage`
- Smoke test: PVC `Bound`, Pod volume write/read success
