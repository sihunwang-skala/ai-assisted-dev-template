# Testing / CI / Regression Guide (On demand)

## Feedback loop
1. Known-good commit/baseline를 확인한다.
2. 재현 가능한 문제와 Expected/Actual을 작성한다.
3. 영향 범위가 좁은 테스트를 먼저 실행한다 (빠른 Feedback).
4. Fix 후 Targeted Tests + 영향을 받는 Regression + 필요 시 Full Suite.
5. `git diff --check`, `git diff --stat`, 삭제/시크릿/Schema/API/UI Contract 확인.
6. 검증되지 않은 상황은 명시한다. 실패가 남아도 성공이라고 하지 않는다.

## Test types
- Unit: pure logic, error handling, edge cases.
- Integration/Contract: storage, API, auth, event schema.
- E2E/Smoke: 가장 중요한 사용자 시나리오 한 개부터.
- Visual/Accessibility: 승인된 기준 UI와 비교, keyboard/responsive.
- AI Eval: Golden Set, Tool authorization, Injection, evidence quality, latency & cost.

## CI
- Stack 결정 후 Test/Lint/Typecheck/Build를 Pull Request에 자동화한다.
- 필수 Checks/Branch Protection 설정은 저장소 권한과 GitHub 설정에 따라 달라진다. 실제 설정 확인 전 '차단됨'이라 말하지 않는다.
- CI가 없는 Docs-only Template에는 비작동하는 가짜 Workflow를 추가하지 않는다.

## Consumer/provider contract testing (conditional)
- Use when independently deployed consumers and providers exchange APIs or events. Record the contract owner, schema/version, authentication assumptions, errors, idempotency semantics and compatibility/deprecation policy.
- Consumer expectations must be executable examples; the provider verifies every supported consumer contract in CI before release. Prefer additive changes and test both old and new consumers during the migration window.
- Contract tests catch interface drift, not deployment wiring, network policy, shared-data mistakes or complete user journeys. Keep a small integration/E2E smoke and observability evidence; do not replace every cross-service test with mocks.
- For events, verify envelope, required/optional fields, units, null/default meaning, ordering/duplication expectations and replay compatibility. A schema-registry check alone does not prove semantic compatibility.
- When a breaking change is unavoidable, version it, publish the migration/deprecation window, identify all consumers with `rg`, traces or registry evidence, and get approval before removing the old contract.

## Performance and load testing (conditional)
Run only for a stated performance goal, never as a default. It does not replace functional tests. Needs a test environment and approval before any load against shared or paid systems (never against production without explicit approval).
- Write the target first: scenario, load, duration, pass thresholds (p95/p99, error rate, resource headroom), environment. Base load on the busiest observed minute, not the average. Without thresholds there is no pass/fail.
- Always report throughput, latency percentiles and error rate together; averages hide tails, and percentiles cannot be averaged (aggregate the raw data or histogram buckets). If errors rise, latency numbers are not meaningful (failures are often fast; compare successful requests).
- Choose the shape by question: smoke (script correctness), load (target held), stress (find the limit), spike (sudden surge and recovery), endurance (leaks; latency drifting upward).
- Make load realistic: varied users and keys (a single repeated request is all cache hits), realistic think time, read/write mix from logs, production-like data volume, whole user journeys.
- Closed model (fixed users) slows its own arrival rate when the server slows and under-reports tail latency; open model (fixed arrival rate) matches internet traffic and surfaces queueing. Use open for public APIs and SLO checks; check the tool's dropped/insufficient-VU warnings. Cross-check results with Little's law (concurrency = rate x time).
- Rule out the generator first (CPU, file descriptors, ports, target rate warnings; split across machines to confirm). Network distance and a shared environment also contaminate results.
- Find bottlenecks by narrowing: no-op endpoint, no-DB endpoint, real endpoint; split request time into connect/wait/receive; then check CPU, DB sessions and slow queries, pools, locks. Typical causes: per-item repeated calls (N+1), pool exhaustion, fixed external latency, resource leaks. In multi-service systems add distributed tracing first and count downstream calls per request.
- Reading curves: below saturation throughput rises with load; at saturation throughput flattens and latency climbs; beyond it errors rise. Operate well below the saturation point (for example 50-70%). More load past saturation only lengthens queues; limit admission instead.
- Tag requests so URLs with ids aggregate; keep thresholds in code; keep results (commit, environment, load, throughput, percentiles, errors) to compare over time; vary one thing at a time; repeat noisy runs and use the median; start CI with a short smoke and trend-only recording, make it blocking only after the noise is known.
- Load tests miss real data skew, odd clients, neighbouring services, accumulation over time and bad days of external services; pair with production observability and canary rollout.
- AI/LLM-backed services: latency varies with output length; track time to first token, time per token, model calls per request, tokens, 429 rate and cost per request. One user request fans out into several model and tool calls, so provider rate limits are usually the first limit. Test your own code against a mock model that reproduces latency distribution, output length, errors and rate limits (measured from a small real sample); a mock that answers instantly is useless. Real-model load needs a separate key, provider-side spend cap, hard iteration cap, cost-based abort and a pre-computed budget. Limiting concurrency at the front usually beats failing at the back. Report cost per load level with throughput.

## Blocking-path and revert-to-fail checks (from a real project, CBAM)
- A requirement sentence is the acceptance criterion: copy it verbatim, do not summarize. Conditions such as "only if", "if any error, reject all", "once per message id" are the blocking side and are the first to disappear in a summary.
- Verify the allowed case and the blocked case. Examples: confirm is blocked for an ineligible record; one bad row rejects the whole batch (the good rows are not stored); the same message id is accepted once. Passing only the happy path is half a check.
- When adding a guard or validation, revert to the pre-fix state and confirm the test actually fails; a test that passes without the guard catches nothing. Report the failing output.
- For AI-assisted features test failure paths first (unknown unit, encrypted/unsupported file, unregistered sender or item, model timeout falling back to a default). Unknown values are left empty with a recorded reason, never filled plausibly.
- Give the AI the exact state/enum names from the spec; otherwise it invents names (`ACTIVE`/`PENDING`).
