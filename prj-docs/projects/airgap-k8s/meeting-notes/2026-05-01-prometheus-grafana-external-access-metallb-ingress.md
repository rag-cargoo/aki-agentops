# 2026-05-01 Prometheus Grafana External Access with MetalLB and Ingress

## Context
- Assignment item `05` requires external access for Prometheus and Grafana.
- The deployed services from `04` are already running in the `monitoring` namespace as internal `ClusterIP` services.
- A plain NodePort is functional but weak as a submitted architecture for an on-premises air-gapped Kubernetes assignment.

## Decision
- Use `MetalLB + ingress-nginx + Ingress` as the primary `05` architecture.
- MetalLB provides the Kubernetes `Service type=LoadBalancer` implementation for a bare-metal or VM LAN cluster.
- ingress-nginx receives traffic through that LoadBalancer service and routes by host name:
  - `grafana.airgap.local` -> `monitoring/grafana:3000`
  - `prometheus.airgap.local` -> `monitoring/prometheus:9090`
- DNS can be represented by internal DNS or by `/etc/hosts` in the lab manual.

## AWS Simulation Note
- The current AWS environment keeps Kubernetes nodes in a private subnet without public IPs.
- AWS VPC networking is not the same as an on-premises L2 LAN, so MetalLB L2 external IPs should not be described as internet-facing AWS load balancers.
- For this simulation, verify Kubernetes state and Ingress routing from the private node path. For operator browser access, use an SSH tunnel through bastion/master if direct routing to the MetalLB IP is unavailable.
- Calico must use `VXLAN` encapsulation in this AWS private subnet simulation. With `VXLANCrossSubnet`, same-subnet pod traffic was not encapsulated and kube-apiserver could not reach admission webhook pods on the worker node.

## Follow-up Tasks
- Status: DONE
  - Added offline asset download, transfer, image import, manifest apply, and verification scripts for `05`.
  - Included MetalLB native manifest and ingress-nginx controller manifest as offline assets.
  - Added MetalLB `IPAddressPool` / `L2Advertisement` and monitoring Ingress manifests.
  - Documented `/etc/hosts` or DNS mapping for `grafana.airgap.local` and `prometheus.airgap.local`.
  - Verified `make 05-prometheus-grafana-external-access-verify`.

## Verification Result
- `metallb-system` controller and speakers are Running.
- `ingress-nginx-controller` Service type is `LoadBalancer`.
- Assigned LoadBalancer IP: `10.10.20.240`.
- `monitoring/grafana` Ingress host: `grafana.airgap.local`.
- `monitoring/prometheus` Ingress host: `prometheus.airgap.local`.
- Host-header checks succeeded:
  - `http://grafana.airgap.local -> 10.10.20.240`
  - `http://prometheus.airgap.local -> 10.10.20.240`

## Done Criteria
- `metallb-system` controller and speaker are ready.
- `ingress-nginx-controller` service is `LoadBalancer` and has an external IP from the configured MetalLB pool.
- Prometheus and Grafana Ingress resources exist in the `monitoring` namespace.
- Host-header checks for Grafana and Prometheus succeed through the ingress-nginx LoadBalancer endpoint.
