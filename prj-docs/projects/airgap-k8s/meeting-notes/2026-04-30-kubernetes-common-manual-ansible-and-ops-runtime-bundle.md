# 2026-04-30 Kubernetes Common Manual Ansible and Ops Runtime Bundle

## Decision
- `03-kubernetes-cluster`는 `common/`, `manual-kubeadm/`, `ansible-kubeadm/`, `calico/` 구조로 분리한다.
- `common/`은 수동/Ansible 공통 기준을 관리한다.
- `manual-kubeadm/`과 `ansible-kubeadm/`은 같은 `01`~`06` 단계 번호를 공유한다.
- CNI는 `Calico`로 확정한다.
- bastion 반입 번들은 2종으로 구분한다.
  - `delivery/offline-assets.tar.gz`
  - `delivery/ops-runtime.tar.gz`

## Why
- 반입 경로와 설치 방식은 별개다.
- bastion 경유든 폐쇄망 내부 control node든 공통 기준은 같고, 주로 바뀌는 것은 접속 대상/IP/SSH 설정이다.
- 수동과 Ansible이 같은 단계 번호를 공유해야 추적과 비교가 쉽다.

## Practical Rule
- `.env`는 원천값 저장소로 사용한다.
- 수동 방식은 접속 대상과 경로만 바꿔 같은 절차를 재사용한다.
- Ansible 방식은 inventory, SSH user, key, ProxyCommand, host IP만 바꿔 같은 playbook을 재사용하는 방향으로 간다.
- bastion에서 `kubectl`, `helm`, `ansible-playbook`를 실행할 경우 `ops-runtime.tar.gz`를 `/opt/airgap-k8s-ops`에 배치한다.

## Follow-up
- `03/common`에 `.env` 기반 bootstrap 스크립트와 inventory template를 추가한다.
- `manual-kubeadm/01~06`에 실제 명령을 채운다.
- `ansible-kubeadm/01~06`에 playbook 골격과 inventory 생성 절차를 추가한다.
