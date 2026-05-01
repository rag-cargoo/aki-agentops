# 2026-04-30 Manual kubeadm Install Verification

## Result
- `03-01-preflight-verify`: SUCCESS
- `03-02-manual-kubeadm-run`: SUCCESS
- `03-02-manual-kubeadm-verify`: SUCCESS
- Calico image pull failure check: SUCCESS

## Cluster Evidence
- `k8s-master`: `Ready`, `control-plane`, `v1.35.4`, `10.10.20.151`, `containerd://2.2.1+unknown`
- `k8s-worker1`: `Ready`, worker, `v1.35.4`, `10.10.20.154`, `containerd://2.2.1+unknown`
- `ErrImagePull` / `ImagePullBackOff`: none after missing Calico images were imported.

## Issues Found
- `delivery/offline-assets.tar.gz` is about `677M`; plain `scp` to bastion `/tmp` stalled around `583M`.
- Amazon Linux offline install failed when `amazon-linux-repo-cdn-*` conflicted with the installed `amazon-linux-repo-s3` package.
- Calico CRD client-side apply failed because the generated annotation exceeded the Kubernetes metadata annotation size limit.
- Re-running the original script after partial success failed because `kubeadm init` was not idempotent.
- Calico optional components initially failed with `ImagePullBackOff` because `csi`, `node-driver-registrar`, `goldmane`, `whisker`, and `whisker-backend` images were not in the offline asset list.

## Fixes Applied
- Use `rsync --partial --inplace --info=progress2` for large archive transfers.
- Stage the bastion archive under `/home/ec2-user/airgap-transfer` and keep it for retry.
- Remove only the staged private key during cleanup.
- Exclude `amazon-linux-repo-cdn-*` from local RPM install inputs.
- Skip package install when required RPMs are already installed.
- Skip `kubeadm init` when `/etc/kubernetes/admin.conf` already exists.
- Apply Calico CRDs with server-side apply.
- Add missing Calico images to `download-k8s-offline-assets.sh` and import them into both nodes.
- Extend `verify-manual-kubeadm-stage.sh` to fail when any Pod reports `ErrImagePull` or `ImagePullBackOff`.

## Follow-up
- Split `03-02` into smaller targets if repeated troubleshooting is needed.
- Reduce Amazon Linux `dnf` release metadata timeout in offline mode.
