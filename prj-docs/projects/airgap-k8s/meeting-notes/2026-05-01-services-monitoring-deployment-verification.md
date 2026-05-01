# 2026-05-01 Services Monitoring Deployment Verification

## Context
- `04` 단계는 MariaDB, MongoDB, Prometheus, Grafana, Grafana Alloy를 폐쇄망 Kubernetes 클러스터에 배포하는 범위다.
- `03`에서 `local-path` 기본 StorageClass를 구성한 뒤 PVC 기반 서비스를 배포했다.

## Implemented
- 서비스별 디렉터리 아래에 `assets/images.txt`, `manifests/*.yaml`, `scripts/04-xx-01`부터 `04-xx-06`까지 순서형 스크립트를 배치했다.
- 공통 실행 로직은 `ops/04-services-monitoring/scripts/04-service-lib.sh`에 두었다.
- master에는 manifest만 전달하고, worker에는 서비스 이미지 tar를 전달해 `ctr -n k8s.io images import`를 수행한다.
- 원격 이미지 tar는 import 후 삭제해 작은 루트 볼륨에서 `DiskPressure`가 재발하지 않게 했다.

## DiskPressure Finding
- AWS EC2 기본 8GB root volume에서는 Kubernetes/Calico 이미지, offline tar, DB/모니터링 이미지가 누적되어 `node.kubernetes.io/disk-pressure:NoSchedule`이 발생했다.
- Terraform에 `node_root_volume_size = 30`을 추가했다.
- 실행 중인 master/worker EBS 볼륨도 30GB로 확장하고 `growpart`, `xfs_growfs`로 파일시스템을 확장했다.
- 장애 대응은 `manual/troubleshooting/04-services-diskpressure-root-volume.md`에 기록했다.

## Verification
```bash
make 04-01-mysql-or-mariadb-run
make 04-02-mongodb-run
make 04-03-prometheus-run
make 04-04-grafana-run
make 04-05-grafana-alloy-run
make 04-services-monitoring-verify
```

Result:
- MariaDB: `mariadb-0` `1/1 Running`, PVC `data-mariadb-0` `Bound`
- MongoDB: `mongodb-0` `1/1 Running`, PVC `data-mongodb-0` `Bound`
- Prometheus: `prometheus-0` `1/1 Running`, PVC `data-prometheus-0` `Bound`
- Grafana: `grafana` `1/1 Running`, PVC `grafana-data` `Bound`
- Grafana Alloy: `alloy` `1/1 Running`
- `make 04-services-monitoring-verify`: success

## Next
- `05`에서 Prometheus/Grafana 외부 접근 방식을 정한다.
- 제출 압축본에는 `ops/04-services-monitoring/`, `manual/04-서비스-배포-및-모니터링-설정/`, `manual/troubleshooting/`을 포함한다.
