# Pattern: Git / CI / Controlled Delivery
Status: optional | Sources: E07 DevOps full 32-section user-provided text reviewed 2026-11-10, E08 Project Methodology full 40-section text, past Claude collaboration guide

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 변경, 검증, release, rollback을 추적 가능하고 복구 가능하게 관리한다. |
| When to Use | Git, CI, shared branch, release, deployment 작업. |
| When Not to Use | 단순 설명 작업이나 현재 환경에 Git 또는 CI가 없는 경우 해당 기능을 강제하지 않는다. |
| Alternatives | Local checkpoint, manual verified commands, existing CI/release process, managed CI, self-hosted CI or GitOps reconciler. |
| Implementation Rules | Bounded changes, frequent integration, stack-specific checks, one immutable artifact promoted across environments, risk-based approval and rehearsed rollback. |
| Trade-offs | CI와 review는 시간을 추가하지만 regression과 release risk를 줄인다. GitOps와 progressive delivery는 auditability와 recovery를 높이는 대신 운영 복잡성과 infrastructure cost를 추가한다. |
| Security Considerations | Secrets를 repository와 logs에서 분리하고, least privilege, short-lived credentials, pinned dependencies and isolated runners를 적용한다. |
| Testing & Acceptance Criteria | Lint, typecheck, test, build, artifact identity, deployment verification, migration and rollback checks as applicable. Failure paths must be exercised. |
| Resource & Token Cost | CI minutes, build time, artifact storage and deployment cost를 측정한다. |
| References | Header Sources; user-supplied curriculum and prior collaboration guide. |

## Trigger
Git changes, CI setup, release, shared branch or deployment.

## Working loop
- Inspect current branch/status; do not overwrite uncommitted changes.
- Make one bounded change in feature/fix branch; use diff review and related tests.
- Add CI for the selected stack only when commands and environment are actually known.
- Prefer branch protection, review and required checks for shared `main` when available.
- Keep release/rollback instructions and environment secrets separate from repository.
- For existing projects, migrate instructions by compare-and-merge, never replace the whole repository with this template.

## Source-derived delivery rules
- DevOps는 특정 도구나 전담 직함이 아니라 Development와 Operations가 Delivery 결과와 운영 품질을 공동 책임하는 방식이다.
- Pipeline은 `code -> build -> verify -> artifact -> deploy -> verify` 흐름과 각 단계의 실패 동작을 명시한다. 성공 경로만 존재하는 Pipeline은 완료로 보지 않는다.
- CI는 단순히 Build Server를 실행하는 것이 아니라 변경을 자주 통합하고 자동 검증하는 Practice다. 장기 Branch가 통합을 지연하면 CI 도구만으로 해결되지 않는다.
- Continuous Delivery는 언제든 배포 가능한 Artifact를 유지하되 운영 반영에 승인 Gate를 둘 수 있다. Continuous Deployment는 검증 통과 후 운영까지 자동화하며 신뢰할 수 있는 Rollback과 Monitoring이 전제다.
- Build once, promote the same immutable artifact. 환경마다 다시 Build하지 않고 동일한 Image/Digest를 승격하며, 환경 차이는 Configuration과 Secret으로 분리한다.
- 운영 Artifact는 `latest` 같은 mutable tag만으로 식별하지 않는다. Commit SHA, immutable digest 또는 release version을 기록하고 실행 중인 Version을 조회할 수 있게 한다.
- 환경을 `dev`, `stage`, `prod` Branch로 장기간 분기해 Drift를 만들지 않는다. 코드와 Artifact는 같게 유지하고 환경 차이는 명시적인 Configuration으로 표현한다.
- Cache, matrix, parallelism, concurrency cancellation과 artifact retention은 측정된 Build time과 비용 병목에 맞춰 사용한다. 빠르지만 결과가 달라지는 Cache는 허용하지 않는다.
- 배포 후 Health와 핵심 Acceptance Signal을 자동 확인한다. 실패 시 중단, 이전 Artifact 또는 Git revision으로 복구, 상태 확인까지 하나의 Recovery Procedure로 정의한다.
- GitOps를 선택하면 Git의 Desired State와 실제 Runtime State의 Drift를 관찰하고 Reconcile한다. `prune`, `selfHeal`, empty-state 허용, 긴급 변경 절차는 삭제와 자동 복구 영향을 검증한 뒤 켠다.
- Rolling, Blue/Green, Canary, Feature Flag는 변경 위험, rollback time, 추가 자원과 관측 가능성을 비교해 선택한다. Deployment와 Feature Release는 필요하면 분리한다.
- DORA의 Deployment Frequency, Change Lead Time, Change Failure Rate, Recovery Time을 함께 관찰한다. 단일 Metric을 개인 성과 목표로 만들거나 숫자만 Gaming하지 않는다.

## Source-derived pipeline security baseline
- Pipeline 기본 권한은 deny/minimum으로 두고 Job별로 필요한 권한만 연다. Build와 Deploy identity를 분리하고 Production에는 risk-based approval을 둔다.
- Cloud 접근은 가능한 경우 장기 Access Key 대신 Repository와 Branch 조건이 제한된 OIDC short-lived credential을 사용한다.
- Third-party Action, plugin and build dependency는 신뢰 경계다. 보안 수준에 따라 immutable commit SHA 또는 검증된 version으로 고정하고 자동 Update와 Review 절차를 둔다.
- Secret을 코드, Artifact 또는 Log에 출력하지 않는다. Fork PR과 untrusted code가 privileged secret이나 self-hosted runner 자산에 접근하지 못하게 한다.
- Secret scan 시작점: `.ai/kits/secret-scan/`(Gitleaks workflow + pre-push Hook + 로컬 테스트). 필수 검사는 Ruleset에서 `Secret Scan` status check로 지정하고, 배포 Job은 `needs: secret-scan`으로 연결한다(별도 배포 워크플로는 성공 조건을 명시해야 함).
- Secret scan, dependency/license scan, SBOM, artifact signing and provenance는 배포 위험에 비례해 도입한다. 문서에 적었다는 이유만으로 구성됐다고 주장하지 않는다.
- CI가 Cluster credential을 직접 가져야 하는지 검토한다. GitOps를 사용할 때는 CI가 signed artifact와 manifest update까지만 담당하고 deployment credential은 reconciler에 격리할 수 있다.

## Source-derived tool selection
- GitHub Actions: Repository와 밀접한 일반 신규 Project의 낮은 시작 비용이 중요한 경우.
- Jenkins: 폐쇄망, legacy integration, 복잡한 self-hosted control이 실제로 필요한 경우. Plugin, backup, disk retention and RBAC 운영 비용을 포함해 비교한다.
- ArgoCD 또는 다른 GitOps reconciler: Kubernetes Desired State, drift detection, audit history and pull-based deployment가 필요한 경우.
- 세 도구는 교육 예시일 뿐 모두 설치할 기본 조합이 아니다. 기존 CI/CD가 요구사항을 충족하면 유지한다.

## Engineering recommendation: verification evidence
1. 일부러 Test 또는 Build를 실패시켜 Merge/Release가 실제로 차단되는지 확인한다.
2. Artifact의 Commit SHA 또는 Digest가 Build record, Registry and Runtime에서 동일한지 확인한다.
3. 권한이 없는 Branch, Repository 또는 Fork가 Deploy credential을 얻지 못하는지 확인한다.
4. Staging에서 Deployment verification과 Rollback을 실행하고 recovery time과 결과를 기록한다.
5. GitOps를 사용하면 Drift, `selfHeal`, `prune`와 긴급 변경 절차를 안전한 환경에서 검증한다.
6. 실행하지 않은 검증은 `Not run`으로 보고하고 Production readiness를 주장하지 않는다.

## Report
Changed files, requirement IDs, actual test commands and outcomes, migration/rollback, unresolved risks, commit SHA. Do not claim merge or deployment without executing it.
