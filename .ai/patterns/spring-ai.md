# Pattern: Spring AI Integration (Java/Spring projects only)
Status: optional | Sources: Spring AI full recovered text E20 (95 sections; deep blocks completed 2026-11-11); earlier study excerpts

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 승인된 Spring Boot 서비스에 LLM, RAG, Tool 기능을 단계적으로 통합한다. |
| When to Use | Existing Spring project needs model, embedding, memory, Tool or MCP. |
| When Not to Use | Non-Spring project 또는 단순 model call에 Spring AI 추가가 불필요한 경우. |
| Alternatives | Direct provider SDK, ordinary REST client, deterministic service. |
| Implementation Rules | Start with minimal ChatClient; add memory, retrieval, Tool, MCP only by requirement. |
| Trade-offs | Framework integration은 일관성을 주지만 version coupling과 abstraction cost가 있다. |
| Security Considerations | Runtime tool auth, tenant memory isolation, ACL retrieval, secret configuration을 적용한다. |
| Testing & Acceptance Criteria | DTO, memory isolation, retrieval ACL, tool denial, provider failure, budget tests. |
| Resource & Token Cost | Model, embedding, vector store, network and framework operation cost를 측정한다. |
| References | Header Sources; E20 for the Operating rules section; project lockfile outranks course versions. |

## When to read
Existing Spring Boot service needs LLM chat, embeddings/vector retrieval, memory, local Java Tools or MCP.

## Progressive approach
- Start with service API and `ChatClient`/model call where sufficient.
- Add structured output and clear DTO contracts.
- Add Memory/Advisor only for explicit conversation continuity requirements; scope by conversation and tenant.
- For document QA add ingestion, Embedding, VectorStore, retriever and evidence handling.
- For live actions use defined `@Tool`/tool schema; LLM selects, Spring runtime executes with auth/validation/HITL.
- Introduce MCP client or more advanced Agent orchestration only when integration/workflow demands it.

## Tests
DTO and controller contract; memory isolation; corpus version and tenant-filtered retrieval; tool authorization and denial; model failures; request budget and API fallbacks.

## Note
Study records mention differing Spring AI/Spring Boot versions. Resolve versions against the project's lockfile/build configuration rather than replacing them from a generic course example.

## Operating rules (conditional; added v1.10, E20)
Applies only to an approved Spring AI integration. Version numbers, starter names and property keys in the source were snapshot-specific (a 2026-08 snapshot using Spring AI 2.x and Spring Boot 4.x); take the project's build file as authoritative and verify names against official docs before copying. Prompt/RAG/tool/memory design rules live in `structured-output.md`, `rag-pipeline.md`, `tool-contracts.md`, `context-memory.md`, `mcp.md`, `harness-reliability.md`; this section adds Spring-specific points only. Labels: [S] Source-derived, [R] Engineering recommendation.
- [S] Keep controller (HTTP), service (prompt + business flow) and client configuration separate; services depend on `ChatClient`, so changing provider is a configuration change. Model-specific options (for example unsupported sampling parameters on some models) belong in per-profile configuration, not in global defaults.
- [S] Put always-on instructions and output limits in the client builder defaults; override per request only for that feature.
- [S] Prefer object mapping (`entity`) over parsing text, then still validate values (ranges, non-empty lists); mapping success proves shape, not truth. Small local models may break schemas more often.
- [S] Advisors wrap the call on the way out and back; their order changes behavior (memory before retrieval makes follow-up questions searchable; logging last shows the final prompt). Custom advisors for streaming must handle partial chunks; do whole-response work after aggregation.
- [S] Memory: scope by conversation id per user, keep system messages outside the window trimmed, decide persistence and retention, mask sensitive data before storing. Tool-call intermediate messages may not be stored by default memory, so audit separately.
- [S] Embedding model, dimension and distance metric are part of the stored-data contract; changing any requires re-embedding. Store the embedding model name in metadata. Replace documents by source before re-ingesting to avoid duplicates; set similarity threshold from measured pairs of relevant and irrelevant text, not by feel; build the vector index after bulk load.
- [S] Tool descriptions are prompts: say when to use, argument meaning, limits. Enforce row, period and size caps in Java; return compact DTOs; keep read and write tools separate; set an iteration and token budget, and do not retry tools with side effects. The model never receives free SQL authority.
- [S] MCP: move a tool to a separate server only if several apps share it, deployment differs, or it is third-party; keep in-process tools for single-app, transactional or high-frequency use. A separate server needs its own least-privilege credentials; prefer the current recommended transport for the framework version.
- [S] Streaming: proxies may buffer responses (disable buffering for stream routes), cancel upstream generation when the client disconnects, and add heartbeats and a timeout; if a stream breaks, continue from what was delivered rather than restarting.
- [S] Retry only transient errors (rate limit, 5xx) with backoff; do not retry client errors or over-length input; timeouts may have already executed side effects.
- [S] Record token usage from response metadata per request type; estimate monthly cost with a formula using current provider prices (do not hardcode prices); lever order: output cap, smaller model for simple tasks, input trimming, caching.
- [S] Test deterministic parts normally (controllers, tools, repositories, retrieval hit rates); evaluate model text by structure, required facts and forbidden content, not exact strings.
- [S] Unit/CI tests must not call paid live providers by accident: inject a fake/local implementation or mark explicit integration tests separately. Keep development and production credentials/limits separate, prevent retries at multiple layers, count tokens before sending large context, and enforce per-request loop/token/output budgets in code plus an account-level spending cap where the provider supports it.
- [R] Add one capability at a time (chat, then memory, then retrieval, then tools) and print the final prompt after each addition.
