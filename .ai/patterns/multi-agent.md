# Pattern: Multi-Agent (Proposal-only by default)
Status: optional / not enabled | Approval: REQUIRED before introducing agents/topology
Sources: recovered Agentic AI/AI Agent/Architecture texts E42-E44; previous course material

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 독립 역할이 측정 가능한 이점을 줄 때만 여러 Agent topology를 제안한다. |
| When to Use | Distinct tools, permissions, context, parallel work or verifiable review가 필요한 경우. |
| When Not to Use | Single Agent, router 또는 fixed Workflow가 동일 품질을 더 싸게 제공하는 경우. |
| Alternatives | Single Agent, deterministic workflow, conditional router, human review. |
| Implementation Rules | Explicit ownership, bounded delegation, stop rules, authority isolation, fallback. |
| Trade-offs | 추가 호출과 병렬성은 latency variance, cost, merge and debugging complexity를 높인다. |
| Security Considerations | Agent 간 권한 위임을 금지하고 tool and data boundary를 runtime에서 강제한다. |
| Testing & Acceptance Criteria | Single-Agent negative control, conflicts, partial failure, isolation, cancellation tests. |
| Resource & Token Cost | Expected calls, tokens, wall time, provider and orchestration cost를 승인 전에 제시한다. |
| References | Header Sources; mixed source-derived topology notes and engineering recommendations. |

## Consider only if
- Independent specialized roles have a measurable reason to exist (distinct tools/permissions, separated context, verifiable reviewer, or useful parallelism).
- A simple Workflow, conditional router or single Agent has been considered as baseline.
- Extra model calls, latency, orchestration complexity and debugging costs are acceptable within budget.

## Ask user before implementation
"현재 [기존 방식]으로 [작업]을 수행 중입니다. [독립성/전문성/병렬성] 때문에 [제안 토폴로지]가 유리할 가능성이 있습니다. 예상 추가 호출, 권한 경계, 성공 기준과 회귀 위험은 [요약]입니다. 구조 변경을 검토할까요?"

## Options (not defaults)
- Router + specialists: predictable domain dispatch.
- Supervisor: dynamically delegates, coordinates and may request revisions; not equivalent to simply having several Agents.
- Parallel fan-out + aggregator: independent work with merge rules; only when tasks can be separated.
- Planner / executor / reviewer: longer tasks with bounded replanning and explicit acceptance.
- Hierarchical supervisor: only when nested ownership and escalation are explicit; otherwise it adds opaque delegation.
- Shared board / peer collaboration / debate: only with conflict resolution, contribution limits and a deterministic final owner. Never use debate as a substitute for factual verification.

## Design obligations
- Record ownership of each Tool, State, data and side effect.
- Decide when agents can communicate and how to stop/deadlock/replan.
- No agent can grant another agent authority or bypass user approval.
- Bounded max delegations, overall token/time budget, trace IDs and fallback to single-agent/manual path.
- Delegated tasks carry the minimum scoped context and permissions, an expected output contract and a deadline. Results are untrusted inputs until validated by the receiving boundary.

## Evaluation / negative controls
- Compare with single-Agent and fixed Workflow on identical dataset, success, correctness, latency, dollars and variance.
- Validate failing agents, conflicting advice, partial results, cross-tenant isolation, cancellation and retries.
- If value is not demonstrated, keep simpler baseline.
