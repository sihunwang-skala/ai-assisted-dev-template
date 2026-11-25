# Pattern: Choose Single Call, Workflow, or Agent
Status: optional | Approval: only for architecture change | Source: recovered Agentic AI/AI Agent/Architecture texts E42-E44, LLM/Transformer E50; MSA E21

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | LLM 기능에 Single Call, Workflow, Agent 중 가장 단순한 충분한 구조를 선택한다. |
| When to Use | 새 LLM 기능, Tool loop, branching, autonomy를 설계할 때. |
| When Not to Use | 규칙, SQL, deterministic API 또는 고정 Workflow로 충분한 경우 Agent를 도입하지 않는다. |
| Alternatives | Deterministic code, single model call, fixed workflow, bounded router. |
| Implementation Rules | Baseline과 실패 비용을 기록하고 Runtime이 권한과 실행 상태를 소유한다. |
| Trade-offs | 자율성이 늘수록 latency, token, debugging, failure surface가 증가한다. |
| Security Considerations | Tool과 data access는 선택한 topology와 무관하게 Runtime authorization을 적용한다. |
| Testing & Acceptance Criteria | 동일 dataset에서 success, latency, cost, error rate, observability를 비교한다. |
| Resource & Token Cost | 호출 수와 orchestration 비용을 사전 예산화한다. |
| References | Header Source and linked patterns; source-derived plus engineering recommendation. |

## Trigger
A feature seems to need LLM/AI, tools, multiple steps, or autonomy. Read only for architectural choice, not every code edit.

## Decision order
1. Can rules, SQL, a deterministic API, or a single LLM call solve this? Prefer that baseline.
2. Are the steps predetermined? Use code-owned workflow. Retrieval-then-answer RAG usually starts here.
3. Are there only a few known branches? Use routing/conditional logic.
4. Only if the next action genuinely depends on observations, tools are needed, and mistakes are recoverable, consider an Agent.
5. Multi-Agent is a separate decision; see `multi-agent.md`.

## Autonomy and control-plane gate (E42-E44)
- [S] Classify each action by impact, reversibility, data sensitivity and failure cost. Increase autonomy only when the runtime can constrain, observe, cancel and recover it; high-impact or irreversible actions require preview/approval according to `human-approval.md`.
- [S] Separate model reasoning from the control plane: runtime owns identity, permissions, budgets, durable state, tool execution, retries and final completion. Instructions do not grant authority.
- [S] Long-running work needs a durable job/state model, idempotent resume, cancellation and a user-visible status. Do not keep an unbounded chat/tool loop alive as the persistence mechanism.
- [R] Record the selected topology, state owner, trust boundaries, failure placement, simpler alternative, acceptance metrics and review triggers in an ADR. Revisit it when permissions, traffic, latency/cost or failure modes materially change.

## Implementation contract
- Record problem, baseline, branching complexity, latency/price budget, unacceptable failures, rollback plan.
- The LLM may propose decisions, but runtime owns tool execution, authorization, and completion state.
- Introduce no framework solely because its name appears in the course.

## Model and inference selection (E50)
- [S] Choose on the real task set, not model size or benchmark reputation: required quality, language/domain fit, context actually used, structured/tool support, latency, privacy/residency and cost. Use the smallest model that clears the acceptance gate and route harder cases only after measured need.
- [S] Token count affects input cost, latency and available output; count the selected tokenizer before sending. A large advertised context window is not a reason to paste whole documents—attention and KV-cache cost still grow with sequence length and concurrency.
- [S] Sampling controls variance, not truth. For extraction/classification keep a measured stable setting; change one of temperature/top-p at a time. Allow an explicit unknown/null outcome and use evidence/runtime checks instead of treating token probability or model confidence as factual proof.
- [R] Pin model, tokenizer, prompt and inference settings in evaluation/release evidence. A provider/model change is a behavior change and must rerun the same regression set.

## Verification
- Compare task success, latency, request cost, error rate, and observability with the simpler baseline.
- Ensure deterministic tasks remain deterministic when possible.
- If changing an accepted Architecture, propose Before/After/alternatives and ask before editing.

## Do not
- Call a fixed multi-step workflow a dynamic multi-agent system.
- Assume additional Agents improve accuracy without measuring.

## Service decomposition gate (conditional; added v1.10, E21)
Applies when someone proposes splitting a system into multiple deployable services (microservices). The default is not to split. Any adoption changes Architecture and needs approval per `AGENTS.md`. Labels: [S] Source-derived, [R] Engineering recommendation.
- [S] Alternatives in order: single deployable; modular monolith with enforced module boundaries; extract only the one part with a concrete pain (independent scaling, deployment conflicts between teams, isolation of failure, different runtime needs). Rewriting everything at once is high risk; extract incrementally behind a routing layer and keep the ability to route back.
- [S] Reasons that do not justify a split: messy code, fashion, résumé value. Conditions that argue against: very small team, domain boundaries not yet understood, no CI/CD or observability, strong immediate-consistency requirements, low traffic.
- [S] Cut by business capability / bounded context, not by technical layer or table. Signals of a bad cut: one feature requires changes in several services; services call each other many times per request; frequent distributed transactions; shared tables; always deployed together. Merging services back is a valid decision.
- [S] Each service owns its data and has an owning team. A shared domain model library couples deployments; share only technical utilities, accept some duplication.
- [S] Prerequisites to check before approving: owner per service, automated pipeline, centralized logs/metrics/tracing, timeouts and failure policy for every remote call, and agreement with product on user-visible intermediate states (for example "received" before "confirmed").
- [R] Record a decision with the pain being solved, the simpler alternative, expected operating cost (pipelines, dashboards, on-call, network failures) and a reversal plan. Count calls per request using traces after the split and reconsider if the number is high.
- [S] Team structure shapes the architecture; splitting systems without changing ownership rarely yields independent deployment.

## Distributed-system acceptance bundle (conditional; E21)
Approving a service split is not enough to make it operable. Before extraction, combine this pattern with `data-and-transactions.md`; apply `harness-reliability.md` to every remote boundary and the contract-testing section of `.ai/guides/testing.md`. Do not duplicate their retry/idempotency rules here.
- [S] Every synchronous API and asynchronous event has a versioned contract, owner, compatibility policy and deprecation window. Prefer additive evolution; verify providers against consumer expectations before deployment and keep a minimal cross-service E2E smoke for wiring.
- [S] Propagate trace context through HTTP/RPC and message boundaries; correlate structured logs, traces and RED metrics (rate, errors, duration) with business state such as pending backlog. Redact sensitive data and clear request context when threads/tasks are reused.
- [S] Demonstrate failure isolation: a slow/down dependency respects deadlines, bounded queues/pools and an explicit user-visible partial/failure state. Demonstrate rollback or traffic return before removing the original path.
- [R] Treat pipeline, dashboard, alert, on-call ownership, contract verification and recovery evidence as part of the extraction cost. If the team cannot operate that bundle, retain the modular monolith baseline.
