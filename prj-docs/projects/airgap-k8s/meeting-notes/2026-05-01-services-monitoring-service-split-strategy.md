# 2026-05-01 Services Monitoring Service Split Strategy

## Context
- `03` 수동 kubeadm Kubernetes 클러스터 설치와 내 PC `kubectl` 접속이 완료됐다.
- 다음 단계인 `04`는 MySQL/MariaDB, MongoDB, Prometheus, Grafana, Grafana Alloy 배포를 다룬다.
- 각 서비스는 선택적으로 사용할 수 있고, 서비스마다 필요한 이미지, chart, manifest, storage, Secret, 검증 기준이 다르다.

## Decision
- `04`는 서비스별 독립 단원으로 구성한다.
- 다운로드, 검증, 전송, 이미지 import, 배포, 검증 스크립트는 각 서비스 디렉터리 안에 둔다.
- 공통 묶음 target은 전체 실행 편의용으로만 둔다.
- 실제 책임 단위는 서비스별 target으로 유지한다.

## Rationale
- 서비스별 사용 여부를 독립적으로 선택할 수 있다.
- 특정 서비스 장애 시 자산 준비 문제인지, 이미지 import 문제인지, 배포 manifest 문제인지 빠르게 좁힐 수 있다.
- Helm chart 기반 서비스와 순수 manifest 기반 서비스를 같은 상위 구조 안에서 다루되, 서비스 내부 구현은 독립적으로 유지할 수 있다.
- 제출 매뉴얼에는 실제 배포와 검증이 끝난 절차만 반영하고, 미확정 초안은 sidecar task에 둔다.

## Target Structure
```text
ops/04-services-monitoring/
  01-mysql-or-mariadb/
    assets/
      images.txt
      charts.txt
    manifests/
    values/
    scripts/
      04-01-01-download-assets.sh
      04-01-02-verify-assets.sh
      04-01-03-transfer-assets.sh
      04-01-04-import-images.sh
      04-01-05-run-mysql-or-mariadb.sh
      04-01-05-verify-mysql-or-mariadb.sh
  02-mongodb/
  03-prometheus/
  04-grafana/
  05-grafana-alloy/
  06-services-verify/
```

## Asset Placement
```text
assets/offline-assets/services/<service>/images/
assets/offline-assets/services/<service>/charts/
assets/offline-assets/services/<service>/manifests/
delivery/offline-assets/services/<service>/
```

## Next Actions
- Rename current service directories to numbered service directories.
- Add per-service `assets/images.txt` and `assets/charts.txt`.
- Decide DB storage mode for a cluster with no current StorageClass.
- Add per-service run/verify targets before writing final manual steps.
