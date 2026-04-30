# Root Runbook and Preflight Placement

## Summary
- 루트 `manual/README.md`는 단순 목차가 아니라 전체 실행 순서를 보여주는 종합 런북으로 유지한다.
- `kubeadm` 설치 전 bastion 점프, 자산 반입, 사전점검 스크립트 실행은 `manual/03-쿠버네티스-클러스터-구성/README.md`에 둔다.

## Decision
1. 루트 `manual/README.md`에는 장별 문서 나열 외에 실제 실행 순서를 함께 둔다.
2. 다운로드 준비는 `manual/01`에 둔다.
3. bastion 점프, `/opt/offline-assets` 배치, preflight 스크립트 실행은 `manual/03`에 둔다.

## Impact
- 사용자는 루트 `manual/README.md`만 봐도 현재 어디까지 진행해야 하는지 순서대로 따라갈 수 있다.
- `manual/03`은 설치 직전 연결 절차와 사전점검 절차를 포함하는 실제 kubeadm 시작점이 된다.
