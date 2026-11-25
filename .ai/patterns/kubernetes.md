# Pattern: Kubernetes Workload, Network, Config and Operations Discipline
Status: optional | Applies only when Kubernetes is the approved platform | Sources: Kubernetes full user-provided text (E24, reviewed 2026-11-10); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 승인된 Kubernetes 클러스터에서 워크로드, 네트워크, 설정, 보안, 운영을 예측 가능하게 구성하고 진단한다. |
| When to Use | 매니페스트 작성/검토, 배포 전략, 프로브, 리소스, 스케일링, RBAC, 장애 진단. |
| When Not to Use | 서버 한 대, 소규모 서비스, 관리형 PaaS/서버리스/Compose로 충분한 경우. Kubernetes를 기본값으로 정하지 않는다. |
| Alternatives | Compose on one host, PaaS, serverless, VM + systemd, managed container service. |
| Implementation Rules | 선언형 매니페스트, Deployment 기반, requests/limits, 프로브 역할 분리, 비루트, 최소 권한, 이미지 태그 고정. |
| Trade-offs | 자동 복구와 확장을 얻지만 학습/운영 복잡도, 클러스터 비용, 디버깅 층이 늘어난다. |
| Security Considerations | RBAC 최소 권한, Secret 취급, NetworkPolicy, Pod 보안 설정, 감사 로그, 컨텍스트 오조작 방지. |
| Testing & Acceptance Criteria | 롤아웃 중 요청 실패 0, 프로브 동작, 자원 제한 확인, 정책 차단 시험, 복구/롤백 훈련. |
| Resource & Token Cost | 노드, 로드밸런서, 볼륨, 컨트롤 플레인 비용, 운영 인력, 이미지/로그 저장. |
| References | E24 (source-derived [S]). 버전별 API/기본값은 시점 의존적이므로 사용 중인 클러스터 버전의 공식 문서로 재확인. |

## Guardrails
Running `kubectl` against a real cluster, applying/deleting resources, forcing deletion, removing finalizers, editing RBAC/secrets and scaling production are approval-gated actions (`AGENTS.md`). Always state the current context and namespace first; prefer a read-only context for inspection. Labels: [S] Source-derived, [R] Engineering recommendation.

### Mental model and delivery
- [S] Declare desired state; controllers reconcile continuously. `apply` only stores the object; real creation happens asynchronously, so wait with `rollout status` and read events instead of assuming. Prefer `apply` over `create`/`replace`; use server-side dry run and `diff` before applying to shared clusters; generate skeletons with client dry run rather than hand-writing YAML.
- [S] Do not deploy bare Pods; use Deployment (stateless), StatefulSet (stable identity/storage), DaemonSet (per node), Job/CronJob (batch; set concurrency policy and retry limits). The Deployment selector must match template labels. A single replica cannot be zero-downtime.
- [S] Pin image tags; roll back with `rollout undo`; with Helm, rollback restores only what Helm recorded, so manual edits create drift. Prefer Git as the single source of truth (GitOps) and avoid hand-editing live objects; if an emergency edit is made, back-port it to the manifest.
- [S] Helm suits packaged third-party software; Kustomize suits per-environment differences of your own manifests. Do not set `replicas` in a manifest that an autoscaler also manages.

### Rollouts, probes and availability
- [S] Rolling update availability = replicas - maxUnavailable; compute it. `maxUnavailable: 0` with `maxSurge >= 1` keeps capacity but needs spare node room. Add `minReadySeconds` so a pod that starts then dies stops the rollout instead of proceeding.
- [S] Probes have different jobs: startup (slow boot grace), readiness (take out of traffic only), liveness (restart). Liveness must not depend on external services (a DB blip would restart every pod); put dependencies in readiness only. Use separate endpoints. Without readiness, traffic reaches booting pods; without startup grace, slow apps are killed in a loop. No liveness is better than a wrong one.
- [S] Terminating pods race with endpoint removal: add a short `preStop` sleep, graceful shutdown in the app and an adequate termination grace period. Terminating forever is usually a finalizer or dead node; investigate the owning controller before removing a finalizer or forcing deletion (orphaned volumes/load balancers).
- [S] PodDisruptionBudget covers voluntary disruptions (drain, upgrade, rollout) only. `minAvailable` equal to replicas blocks drains; prefer `maxUnavailable` or percentages and at least 3 replicas for critical services. Spread replicas with topology spread constraints (zone, then node); `DoNotSchedule` can leave pods Pending when zones are fewer than required, so check capacity first.

### Resources and scaling
- [S] The scheduler places by requests (sum), not live usage; missing requests lets nodes be overpacked and leaves autoscaling without a baseline. Always set requests; set memory limits always; CPU limits are a trade-off (throttling inflates tail latency; many teams set requests only for trusted workloads). Set requests from measured p50/p95 usage.
- [S] Over-memory-limit means OOMKilled (exit 137); node pressure means eviction ordered by QoS (Guaranteed last, BestEffort first); critical services use requests=limits. Tell runtimes the container limits (heap percentage, processor count, thread pool sizes); otherwise they read the node.
- [S] HPA: desired = ceil(current x current metric / target); needs metrics-server and requests; CPU is a poor signal for I/O-bound services (use rate, queue lag); scale up fast, down slowly; node capacity must follow (cluster autoscaler); DB connections x max replicas must fit the database.

### Networking and traffic
- [S] Pods are ephemeral; use Services. An empty endpoint list (selector/label mismatch) gives a healthy-looking Service that connects to nothing; check endpoints first, then target port. Cluster DNS uses search domains and `ndots`, so external names may trigger extra lookups; use FQDNs or lower `ndots` after confirming the cause.
- [S] An Ingress object does nothing without an installed controller and matching ingress class; check controller, class, address, backend endpoints, path type and rewrite rules in that order. Avoid one LoadBalancer per service.
- [S] Namespaces do not isolate network traffic; everything is open by default. NetworkPolicy is enforced only if the network plugin supports it, and a default-deny must explicitly allow DNS egress. Verify that traffic is actually blocked after applying policy.

### Configuration, secrets and storage
- [S] Environment-variable config never updates in running pods; mounted files update after about a minute and need app reload; restart the rollout or use content-hashed ConfigMap names. Immutable ConfigMaps reduce API load.
- [S] Secrets are encoded, not encrypted: restrict reads with RBAC, enable encryption at rest or an external secret store, prefer file mounts with tight modes over env vars, and never commit secret manifests.
- [S] Persistent data: PVC requests, StorageClass provisions; `WaitForFirstConsumer` Pending is normal; volumes are zone-bound; ReadWriteOnce means one node; each StatefulSet replica needs its own claim template; PVCs survive StatefulSet deletion and scale-down by design. Use Retain for data that matters; claims can grow but not shrink. Initialization directories should be a subfolder when the volume root may contain `lost+found`.
- [S] A volume is not a backup; run logical backups and test restore. [S] Production databases are usually better on a managed service than on StatefulSets unless the team will own backup, failover and upgrade.

### Security
- [S] Run non-root, no privilege escalation, drop capabilities, read-only root filesystem with explicit writable volumes, default seccomp profile. Avoid privileged, host network/PID and host path; enforce with namespace-level pod security labels. Containers share the node kernel.
- [S] RBAC is allow-only; verify with `auth can-i` (including `--as`). Treat as dangerous: reading secrets, `pods/exec`, and `escalate`/`bind`; grant by resource name where possible (not possible for list/watch). Service-account tokens are short-lived and pod-bound; disable automount when the pod does not call the API.
- [S] Enable API audit logging before an incident; log metadata for secrets, request detail for RBAC and exec.
- [S] Guard against wrong-cluster mistakes: show context in the shell prompt, set default namespaces per context, use read-only contexts by default.

### Diagnosis order
- [S] State is a symptom, not a cause: `get`, then `describe` events, then `logs --previous`, then events timeline, then a debug pod or ephemeral container. Pending: read the scheduler reasons (insufficient resources, taints, selectors, topology, volume affinity). ImagePullBackOff: tag, credentials, network. CrashLoopBackOff: exit code (1 app error, 137 killed/OOM, 139 crash). Running but unreachable: endpoints, readiness. ContainerCreating stuck: network plugin (IP exhaustion) or storage attach before suspecting the app. If every deployment suddenly fails, check admission webhooks. Slow API: check client throttling and request volume before blaming the control plane.
- [S] Start small (Deployment, Service, Ingress, ConfigMap) and add GitOps, observability, mesh and operators only when a measured need appears; build an operator only for continuous reconciliation, not one-off tasks.

### Checks
Context/namespace confirmed; selectors match; replicas and PDB consistent; requests/limits set and QoS known; probes separated; rollout under load shows zero failed requests; endpoints non-empty; default-deny plus DNS verified; secrets not in Git; RBAC denies a probe request; backup restore tested; rollback tested.
