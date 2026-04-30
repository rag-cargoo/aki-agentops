# 로컬 Docker 보조 사용과 Kubernetes containerd 런타임 구분

## 핵심 구분
- 로컬 PC의 `docker` 사용 목적:
  - 격리된 Ubuntu 컨테이너를 띄워 `apt` 패키지를 다운로드
  - kube-system 이미지를 pull/save 해서 tar 파일로 수집
  - 호스트 OS 패키지 캐시 오염을 줄임
- 클러스터 노드의 실제 container runtime:
  - `containerd`
  - Kubernetes 1.35 공식 기준에 맞춤

## 왜 Docker를 썼는가
- 현재 로컬 PC에 Docker가 이미 설치되어 있었다.
- `ubuntu:22.04` 컨테이너를 바로 띄워서 호스트에 패키지 설치 없이 `.deb`를 수집할 수 있었다.
- `docker pull`, `docker save`로 kube-system 이미지를 tar로 내리기 쉬웠다.

## 왜 Kubernetes는 containerd를 써야 하는가
- Kubernetes 1.35는 CRI 호환 runtime을 요구한다.
- 현재 프로젝트 기준 runtime은 `containerd`다.
- 따라서 폐쇄망 서버/VM에는 Docker를 runtime으로 설치하는 것이 아니라 `containerd`를 설치하고, 반입한 이미지는 `ctr -n k8s.io images import ...` 방식으로 적재하는 흐름이 맞다.

## 제출 매뉴얼에 남길 수준
- Docker는 로컬 PC 오프라인 자산 수집용 보조 도구라고만 짧게 적는다.
- 실제 노드 runtime은 `containerd`라고 명시한다.

## 나중에 다시 볼 포인트
1. 로컬 PC 다운로드 도구를 Docker 대신 Podman이나 Skopeo로 바꿀 수 있는지
2. `containerd`를 Ubuntu repo `containerd`로 갈지, Docker repo `containerd.io`로 갈지
3. 이미지 반입을 `docker save/load` 대신 `ctr images export/import` 흐름으로 통일할지
