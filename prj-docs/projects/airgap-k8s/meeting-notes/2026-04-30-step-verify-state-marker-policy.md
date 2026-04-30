# 2026-04-30 Step Verify State Marker Policy

## Decision
- `airgap-k8s` 실행 단계는 `step -> verify -> state marker` 구조로 정리한다.
- 세부 `step`은 작업 수행 후 같은 단계의 `verify`를 즉시 호출한다.
- `verify`가 성공하면 `.codex/runtime/airgap-k8s-state/*.done` 마커를 기록한다.
- 실패하면 `.failed` 마커를 기록한다.

## Reason
- `all-verify`가 실제 적용 여부를 하드코딩 없이 판정해야 한다.
- 준비 검증 성공과 실제 노드 적용 성공을 섞어 보이면 현재 상태를 오해하게 된다.
- 단계 재실행 없이도 현재 완료 상태를 요약하려면 독립 verify 또는 상태 마커가 필요하다.

## Applied First
- `ops/02-user-network/`
  - `02-01-user-network-run`
  - `02-01-user-network-verify`
  - `02-01-user-network-clear`
  - `step-02-01-01-user-network-apply`

## Follow-up
- `03-01` 원격 preflight도 같은 구조로 맞춘다.
- `manual-kubeadm 01~06` 실제 단계도 같은 구조로 맞춘다.
- `ansible-kubeadm` 실행도 같은 구조로 맞춘다.
