# Pattern: AWS Account, Network, Data and Cost Discipline
Status: optional | Applies only when AWS is the approved platform | Sources: AWS Basics (E22) and AWS EKS (E25) full user-provided texts, reviewed 2026-11-10; engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | AWS 위에서 계정 보안, 네트워크 경계, 데이터 보호, 비용 사고를 예방한다. |
| When to Use | AWS 리소스를 만들거나 IAM, VPC, 컴퓨팅, DB, S3, 비용, 모니터링을 설계/검토할 때. |
| When Not to Use | 다른 클라우드/온프레미스를 쓰거나 클라우드 선택 전. 특정 클라우드를 기본값으로 정하지 않는다. |
| Alternatives | 다른 클라우드, PaaS, 단일 서버, 로컬/데모 환경. |
| Implementation Rules | 임시 자격증명, 최소 권한, 프라이빗 데이터 계층, 코드화된 인프라, 만들기 전 삭제 절차 기록. |
| Trade-offs | 관리형 서비스는 운영 부담을 줄이나 비용, 종속, 설정 책임이 생긴다. |
| Security Considerations | 루트 보호, 키 비사용, 공개 차단, 암호화, 감사 로그. |
| Testing & Acceptance Criteria | 정책 시뮬레이션, 공개 노출 점검, 복구 훈련, 비용 알림 동작, 정리 후 잔여 리소스 조회. |
| Resource & Token Cost | 유휴 시간 과금, 전송/NAT 처리량, 스냅샷/버전 누적을 사전 추정한다. |
| References | E22 (source-derived [S]); 가격, 서비스명, 기본값은 시점 의존적이므로 공식 문서와 현재 요금표로 재확인. |

## Guardrails
Creating cloud resources, spending money, or changing IAM/network/security settings requires user approval (`AGENTS.md`). Never enter or store credentials for the user. Labels: [S] Source-derived, [R] Engineering recommendation.

### Account and identity
- [S] Shared-responsibility: most incidents are customer-side configuration (open storage, leaked keys). Protect the root account (MFA, no access keys, not for daily work); set up a budget alert, an audit trail and a default region before building.
- [S] Prefer roles with temporary credentials: instance/task/function roles for workloads, federated or single-sign-on identities for people, OIDC federation for CI. Long-lived access keys are a last resort and must be rotated; a leaked key is deactivated first, investigated through the audit log across all regions, then replaced.
- [S] Policy evaluation: explicit deny wins; with no allow the default is deny; organization limits, permission boundaries, resource policies and conditions also apply. Diagnose with the policy simulator and the audit log before broadening anything. Avoid wildcard action plus wildcard resource.
- [S] Reach least privilege iteratively: start from narrow managed policy, review last-accessed data after real use, replace with a scoped customer policy, add conditions, test in a non-production account first.

### Network and compute
- [S] Public subnets hold only entry points (load balancer, NAT); applications and databases live in private subnets across at least two availability zones. "Public" is defined by routing to an internet gateway, not by name.
- [S] Reference security groups by security group (app allows load balancer group, DB allows app group), not by IP. Do not open SSH/RDP to the world; prefer a managed session service. Reachability debugging order: security group, routes, public IP, network ACL, host firewall.
- [S] Plan non-overlapping address ranges before peering; document the subnet scheme.
- [S] A NAT gateway bills hourly plus per GB and has no free tier. Use gateway endpoints for object storage and key-value DB (no charge), interface endpoints where cheaper, one NAT in dev, and delete lab NATs.
- [S] Do not store state on instances managed by auto scaling; uploads go to object storage and sessions to a shared store. Choose compute by operational burden versus control (VM, container service, serverless); serverless is not automatically cheaper at steady high volume.
- [S] Purchase order: switch off unused resources, right-size from measured use, then commit (savings plans/reservations), then interruptible capacity for fault-tolerant jobs.

### Data
- [S] Managed DB: private subnet, security group from app only, forced TLS, encryption at creation (cannot be added later in place), secrets in a secrets manager with rotation, backups with a retention above zero and a final snapshot before deletion. Test a restore; point-in-time restore creates a new instance.
- [S] Multi-AZ is for availability and does not add read capacity; read replicas add read capacity with replication lag. After writes, read from the primary where staleness matters.
- [S] Object storage: block public access at account level; serve public files through a CDN with origin access control while the bucket stays private; deny unencrypted uploads; use versioning with a lifecycle rule for old versions and aborted multipart uploads; enable access logging before an incident, not after.
- [S] Choose block, file or object storage by access pattern; do not put uploads on instance disks. A non-relational store requires known access patterns up front; start relational when patterns are unsettled.

### Cost and operations
- [S] Billing axes: compute time, storage, data transfer (NAT, cross-AZ, cross-region, internet egress), and always-on hourly items. Typical surprises: forgotten NAT/load balancer, unattached addresses and volumes, orphaned snapshots, unbounded log retention, versioned buckets, resources in another region.
- [S] Tag every resource (environment, owner, service, cost center) and enforce tags; use budgets and anomaly detection; set log retention; list unattached addresses/volumes and old snapshots periodically.
- [S] Alarm at least on: forecast spend, load balancer 5xx, DB free storage, instance status checks. Keep audit logs in a protected location outside the workload's reach.
- [S] Define infrastructure as code for anything beyond a lab and review the plan output for unintended destroys. Before creating lab resources write down the delete steps in dependency order and verify nothing remains, in every region used.
- [R] Never state prices as fact; compute estimates from the provider's current price list and state the date.

### Checks
Root MFA and no root keys; no static keys in code or CI; public-access block on; no world-open admin ports; DB not publicly reachable; encryption defaults on; budget and anomaly alerts fire in a test; restore drill completed; teardown leaves zero billable resources.

## EKS specifics (conditional; E25)
Applies only when Amazon EKS is approved; general Kubernetes rules are in `kubernetes.md`. Most EKS faults are at the AWS/Kubernetes seam (IAM, IP addresses, load balancers). Control-plane fees accrue while a cluster exists; node, NAT and load-balancer fees add up, so delete lab clusters, then check for leftover load balancers, volumes and addresses. Delete ingresses and claims before the cluster so controllers can clean up AWS resources. Labels: [S] Source-derived, [R] Engineering recommendation.
- [S] Two permission systems meet: AWS IAM authenticates, a mapping (access entries, or the older aws-auth ConfigMap, which can lock everyone out if edited wrongly) maps to Kubernetes RBAC. For "Unauthorized": confirm the caller identity first (wrong profile is common), then the mapping, then refresh the kubeconfig. Enable the OIDC provider at cluster creation if workload roles are needed.
- [S] Give pods AWS permissions through a service-account-bound role (IRSA, or the newer Pod Identity), never node-role breadth or static keys. The trust policy's subject must match `system:serviceaccount:<namespace>:<name>` exactly; a typo only yields AccessDenied. Verify by calling the identity API from the pod: an assumed node role means the binding silently failed (also old SDKs ignore web-identity tokens).
- [S] The default CNI gives every pod a VPC IP, so subnet size and instance type cap pod count; plan CIDRs from the maximum pod count before creating the cluster. Remedies: larger node subnets, prefix delegation (also raise max pods), secondary CIDR with custom networking. Symptom: pods stuck creating with an IP assignment failure.
- [S] Install the load balancer controller (with its own scoped role) for ingress; subnets need the role tags for public/internal load balancers; use IP target mode (no extra hop, no cross-zone traffic) and share one load balancer across ingresses with a group name. Pair it with deregistration delay and `preStop` for zero-downtime rollouts. Leftover load balancers keep billing.
- [S] Use a storage class with `WaitForFirstConsumer`; otherwise volumes may be created in a zone where the pod cannot run. Block volumes are zone-bound and single-node; use a file system service for shared access.
- [S] Node scaling: horizontal pod autoscaling needs node capacity to follow. Cluster Autoscaler scales predefined groups; Karpenter provisions fitting instance types directly and consolidates idle nodes. Bound it with CPU limits per pool, use spot only for interruption-tolerant, PDB-protected workloads, and remember pods without requests defeat both.
- [S] CI: push images to a registry with lifecycle rules and scan-on-push, authenticate CI through OIDC role assumption (no stored keys), tag images by commit id (a reused `latest` tag does not trigger a rollout).
- [S] Observability is not on by default: enable the metrics server and a metrics/log add-on, and set log retention. Enable control-plane audit/authenticator logs, restrict API endpoint CIDRs, keep nodes in private subnets, encrypt secrets with a managed key, and plan version upgrades because supported versions expire.
- [S] Cost levers beyond the AWS basics: consolidate load balancers, schedule non-production node groups to zero off-hours, right-size from measured usage, prefer same-zone traffic (topology-aware routing), move volumes to the cheaper generation, and expose cost per namespace with a cost tool.
