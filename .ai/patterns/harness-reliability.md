# Pattern: LLM Harness and Reliability Envelope
Status: optional | Source: recovered Harness Engineering E45 (23 sections), AI Agent E43; MSA E21

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | LLM과 Tool 호출을 timeout, validation, retry, fallback, observability 경계 안에서 운영한다. |
| When to Use | User-facing model service, multiple model calls, external tools. |
| When Not to Use | One-off offline experiment or deterministic function with no model dependency. |
| Alternatives | Single bounded call, deterministic workflow, manual fallback. |
| Implementation Rules | Global deadline, schema validation, safe retry, explicit partial failure, trace metrics. |
| Trade-offs | Reliability layer는 latency와 code complexity를 늘리지만 failure containment를 제공한다. |
| Security Considerations | PII redaction, tool authorization, untrusted output handling, safe fallback을 적용한다. |
| Testing & Acceptance Criteria | Provider errors, timeout, malformed output, denied action, budget exhaustion tests. |
| Resource & Token Cost | Per-hop token, retry, latency, provider and logging cost를 측정한다. |
| References | Header Source; user-pasted Harness Engineering material plus recommendations. |

## Trigger
Moving from notebook/demo to user-facing service, using multiple model calls or external tools.

## Layers
1. Input constraints / access checks.
2. Context assembly with token budgets and source provenance.
3. Model route and bounded call with timeout/rate budget.
4. Structured parse and validation, limited repair only if economical.
5. Tool authorization/execution or safe final answer.
6. Output checks and trace/cost metrics.

## Failure policy
- Specify whole-request deadline plus per-hop timeout; do not stack retries beyond global budget.
- Retry transient safe operations with bounded attempts/backoff/jitter; do not retry irreversible side effects blindly.
- Use circuit breaker/fallback only when justified by operational needs; fallback must respect data and policy constraints.
- Invalid structured output: validate locally, then if permitted repair or ask user; never silently accept malformed output.
- Expose failures/partial status, don't silently substitute invented data.
- Stop repeated or non-progressing tool/model actions using step, repeated-state, token, wall-time and cost limits. A stop is an explicit terminal state, not a fabricated success.
- Validate syntax/schema locally, then deterministic content and policy invariants, before any model-as-judge check. A repair call receives bounded error feedback and has a strict attempt limit.
- Give retriable workflow steps an idempotency key or durable checkpoint. Model routing and fallback must preserve data residency, permissions and minimum quality requirements.

## Cache and guardrail boundaries (E43/E45)
- [S] Separate exact/prompt, semantic and tool/result caches. Key them by model/prompt/schema/policy/data versions and authorization scope; define TTL and invalidation rather than treating cache hits as timeless truth.
- [S] Input guardrails, tool authorization and output validation are separate controls. Treat model, retrieved and tool output as untrusted; no single classifier or prompt is a security boundary.

## Operations
Collect request ID, model/version, token usage, latency by stage, retry count, tool outcome, validation failures and estimated cost. Redact PII/secrets.

## Test cases
429/5xx, slow provider, broken JSON, missing tool, empty evidence, denied action, model unavailable, cost exceeded, repeated tool calls and cancellation.

## Service-to-service call resilience (conditional; added v1.10, E21)
Applies to any remote call (HTTP, RPC, queue publish), LLM or not, when a dependency can be slow or down. Labels: [S] Source-derived, [R] Engineering recommendation.
- [S] Slow dependencies cause more outages than dead ones. Every remote call gets connect and read timeouts, bounded from the outside in (client > gateway > service call > DB query). Choose values from measured latency percentiles, then verify under load with a deliberately slowed dependency.
- [S] Retry only connection failures, 503/504, 429 (after waiting) and idempotent operations; never 4xx; use exponential backoff with jitter; retry at one layer only (nested retries multiply). A read timeout on a non-idempotent request needs an idempotency key before it may be retried.
- [S] Circuit breaker: count only infrastructure failures and slow calls, not business exceptions (such as "sold out"); require a minimum call count before judging; match window type to traffic volume; log state transitions and alert on open.
- [S] Isolate resources (bulkhead, separate pools) so one dependency cannot consume all threads; size DB pools against the database connection limit at maximum replica count.
- [S] Fallback only for non-critical data (stale cache marked stale, default list, queued notification); correctness-critical operations such as payment or capacity fail clearly. Fallbacks must not call the failing dependency and must be logged and counted.
- [S] Shed load early with a clear 503 and retry-after rather than queueing work the client has abandoned.
- [S] Observability: propagate a trace id across HTTP and message boundaries (including async hops), use structured logs with that id and no sensitive data, record rate/errors/duration per service and business-level counters (for example pending backlog), sample traces with errors and slow requests retained, alert on user impact rather than every metric. Liveness checks exclude external dependencies; readiness includes them; shut down gracefully.
- [S] During incidents, check for recent deployments first and roll back before analysis.
- [R] Do not claim any threshold is correct until it has been exercised by a fault-injection or load test.
