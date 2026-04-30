# Kubernetes 오프라인 자산 실제 다운로드 검증

## 결정
- Kubernetes 오프라인 자산 다운로드는 로컬 PC에서 실제로 검증한다.
- 반복 실행을 위해 `make 08-k8s-assets-download`, `make 08-k8s-assets-verify` 타깃을 추가한다.
- 패키지 다운로드는 호스트 오염을 줄이기 위해 격리된 `ubuntu:22.04` 컨테이너에서 수행한다.

## 실제 확인 결과
- Kubernetes apt repo `v1.35`에는 현재 `1.35.4-1.1`과 `1.35.3-1.1`이 모두 존재한다.
- 현재 매뉴얼 기준은 `1.35.3-1.1`로 고정한다.
- 실제 다운로드 성공:
  - `kubeadm_1.35.3-1.1_amd64.deb`
  - `kubelet_1.35.3-1.1_amd64.deb`
  - `kubectl_1.35.3-1.1_amd64.deb`
  - `cri-tools_1.35.0-1.1_amd64.deb`
  - `kubernetes-cni_1.8.0-1.1_amd64.deb`
  - `containerd_2.2.1-0ubuntu1~22.04.1_amd64.deb`
  - `runc_1.3.4-0ubuntu1~22.04.1_amd64.deb`
  - Calico `operator-crds.yaml`, `tigera-operator.yaml`, `custom-resources.yaml`
  - kube-system image tar 7개

## 보완 아이디어
- 선택지 A: 현재처럼 `1.35.3` 고정 유지
- 선택지 B: `1.35.4`로 상향해 최신 patch 기준으로 재고정
- 선택지 C: containerd를 Ubuntu repo `containerd` 대신 Docker repo `containerd.io` 기준으로 바꿔 재검증
