# Offline Assets Packaging and Server Path

## Summary
- 오프라인 반입 자산은 레포 내부 작업 원본과 서버 배치 경로를 분리한다.
- 로컬 작업 원본은 `workspace/infra/airgap/kubernetes/airgap-k8s/assets/offline-assets/`다.
- 서버 반입용 설치 번들 경로는 `workspace/infra/airgap/kubernetes/airgap-k8s/delivery/offline-assets/`다.
- 서버 배치 경로는 `/opt/offline-assets`로 고정한다.

## Decision
1. 오프라인 자산은 장 디렉터리(`01`, `03`, `04`, `05`)에 분산 배치하지 않고 공통 저장소로 유지한다.
2. 실제 서버 설치는 레포 경로가 아니라 `/opt/offline-assets` 기준으로 수행한다.
3. 설치 전에 로컬 작업 원본에서 필요한 파일을 `delivery/offline-assets/`에 모은 뒤 서버로 반입한다.
4. 서버에서는 `/opt` 아래에 압축을 풀고, 모든 설치 명령은 `/opt/offline-assets/...` 경로를 사용한다.

## Packaging Flow
1. 로컬 PC에서 패키지, 이미지, manifest, chart, checksum을 `assets/offline-assets/` 아래에 정리한다.
2. 서버 반입에 필요한 파일만 `delivery/offline-assets/` 아래에 모은다.
3. 반입용 압축 파일을 만든다.
4. 폐쇄망 서버로 압축 파일을 업로드한다.
5. 서버에서 `/opt/offline-assets` 경로로 압축을 해제한다.
6. 이후 `dpkg`, `ctr images import`, `kubectl apply` 등은 `/opt/offline-assets` 기준으로 실행한다.

## Command Baseline
```bash
mkdir -p /opt
tar -xzf offline-assets.tar.gz -C /opt
```

```bash
sudo dpkg -i /opt/offline-assets/kubernetes/packages/kubernetes/*.deb
```

## Impact
- 제출 매뉴얼은 로컬 레포 경로보다 서버 기준 경로 `/opt/offline-assets`를 우선 사용한다.
- sidecar task에는 로컬 원본 경로, 반입 번들 경로, 서버 반입 경로를 함께 기록한다.
- 다음 세션에서는 오프라인 자산 다운로드, 압축, 업로드, 설치 검증을 이 기준으로 이어간다.
