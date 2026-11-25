# Pattern: Container Images, Runtime and Compose Discipline
Status: optional | Applies only when containers are the approved packaging | Sources: Docker & Container full recovered text E23 (26 sections; deep blocks completed 2026-11-11); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 재현 가능하고 작고 안전한 컨테이너 이미지와 로컬/배포 실행 구성을 만든다. |
| When to Use | Dockerfile, Compose, 이미지 빌드/배포, 컨테이너 디버깅, 로컬 개발 환경을 다룰 때. |
| When Not to Use | 컨테이너를 쓰지 않는 배포(관리형 플랫폼, 서버리스 zip 등) 또는 단순 스크립트. |
| Alternatives | 플랫폼이 빌드하는 PaaS, VM 이미지, 언어 런타임 직접 배포. |
| Implementation Rules | 고정 태그, 멀티스테이지, 비루트, 시크릿은 이미지 밖, 볼륨으로 상태 분리, healthcheck. |
| Trade-offs | 환경 일관성과 배포 단위를 얻지만 이미지 관리, 네트워크/볼륨 이해, 스캔 부담이 생긴다. |
| Security Considerations | 비루트, 시크릿 레이어 누출, 이미지 스캔, 소켓 마운트 금지, 포트 노출 최소화. |
| Testing & Acceptance Criteria | 클린 빌드, 캐시 재빌드 시간, 컨테이너 재생성 후 데이터 보존, 비루트 확인, 헬스, 이미지 크기. |
| Resource & Token Cost | 이미지 크기, 빌드 시간, 레지스트리 저장, 메모리/CPU 제한, 디스크 정리 필요. |
| References | E23 (source-derived [S]); Kubernetes 배포 규칙은 `kubernetes.md`. |

## Guardrails
Pushing images, opening ports to the network, deleting volumes/images in bulk and running privileged or socket-mounting containers need approval. Do not run `prune --volumes` or `compose down -v` on data that matters. Labels: [S] Source-derived, [R] Engineering recommendation.

### Image
- [S] An image is immutable; the same image should run everywhere, with environment differences injected at run time. Pin base image tags (no `latest` in production) and tag releases with a version or commit id so rollback is a tag change.
- [S] Order Dockerfile steps from least to most frequently changing: dependency manifests, dependency install, then source. A `.dockerignore` (build output, VCS, dependency folders, env files) keeps context small, preserves cache and keeps secrets out.
- [S] Multi-stage builds: build with the full toolchain, ship only the runtime artifact on a smaller runtime image. Frontend builds ship static files on a web server image; SPA servers need a fallback to the index page for client routes; build-time variables are baked in at build time and visible to users, so no secrets and prefer relative API paths proxied by the server.
- [S] Layers are append-only: deleting a file in a later layer does not remove it from the image. Do install and cleanup in one `RUN`; pass build secrets with the builder's secret mount, never `COPY`/`ENV` secrets.
- [S] Run as a non-root user. Prefer standard runtime images first; minimal or musl-based images can introduce compatibility and debugging cost.
- [S] Cache mounts for package managers and registry-based build cache speed up CI without bloating layers.

### Runtime
- [S] Distinguish stopped from removed containers; `ps -a` shows stopped ones. Container data disappears with the container: put required state on named volumes; use bind mounts for development only.
- [S] Port mapping is host:container; a listening address of 127.0.0.1 inside a container is unreachable from outside; inside a container `localhost` is the container itself, so services on the same user-defined network are addressed by service name. Publish database ports only to the host loopback, or not at all.
- [S] Initialization variables and init scripts of database images run only on an empty data directory; changing them later has no effect. Major database version upgrades need dump and restore, not just a new tag.
- [S] Set memory and CPU limits; exit code 137 usually means out-of-memory. Runtimes should be told the container limits (heap as a percentage of the memory limit; thread and worker counts set explicitly).
- [S] Log to standard output with log rotation; define a healthcheck with a start period; a start-order dependency should wait for healthy, not merely started.
- [S] Scan images in CI; never mount the container runtime socket into app containers; consider a read-only root filesystem.
- [S] Harden the runtime as well as the image: use a non-root UID, drop all Linux capabilities and add back only the required ones, set `no-new-privileges`, prefer a read-only root with explicit writable tmpfs/volumes, and cap PIDs. Test the application under these restrictions instead of assuming it still starts.

### Compose and diagnosis
- [S] Compose captures multi-container setups declaratively; use an override file for development (source mounts, debug ports, admin tools) and profiles for optional tools; keep the same image for production.
- [S] Diagnosis order: container state and exit code, then logs, then inspected configuration (ports, env, mounts), then a shell inside. Read the log's first lines before changing options; reduce to the smallest run command to localize faults.
- [S] Housekeeping: check disk usage first; prune stopped containers, dangling images and build cache; treat volume pruning as data deletion and list volumes first.
- [R] Back up database volumes by logical dump (portable across versions) and test the restore; a volume is not a backup.

### Checks
Rebuild with only source changed reuses dependency layers; image history shows no secrets; container runs as non-root; data survives container recreation; app reaches DB by service name; healthcheck turns healthy; stop/remove semantics understood; restore from dump works.
