# Optional Engineering Pattern Catalog

**Do not load all patterns.** Always read `AGENTS.md`, relevant project constraints, then open the smallest matching set. Most tasks need one or two patterns; an explicitly listed bundle may need more. Each pattern is dormant until a task warrants it; architecture-changing patterns require user approval.

모든 Pattern은 필수 Pattern Card와 Evidence Label(`[S]` Source-derived, `[R]` Engineering recommendation 등)을 따른다. Pattern Card는 적용 권한이 아니라 비교와 검증을 위한 metadata다.

| User request / observed need | Read | Default decision |
|---|---|---|
| LLM or Agent needed? | `patterns/architecture-selection.md` | single call / deterministic workflow first |
| Tool parameters or external action | `patterns/tool-contracts.md` | explicit schema, runtime auth |
| Repeated Agent tool loop | `patterns/react-loop.md` | bounded loop + stop rules |
| Graph state, branching, pause/resume | `patterns/langgraph-state.md` | only with justified branching/durability |
| Specialized/parallel Agents | `patterns/multi-agent.md` | propose, **DO NOT enable** without approval |
| Source-backed answers | `patterns/rag-pipeline.md` | evidence/ACL first |
| Retrieval accuracy low | `patterns/retrieval-tuning.md` | baseline -> error analysis |
| Persisted embeddings, vector metadata/ACL, reindex or model migration | `patterns/vector-store-lifecycle.md` | immutable version contract; parallel reversible migration |
| Recommendation candidates, ranking, cold start, online experiment | `patterns/recommendation-systems.md` | popularity/rules baseline; exposure-aware evaluation |
| Data cleaning, descriptive/inferential analysis, A/B experiment | `patterns/analysis-statistics.md` | analysis contract and integrity gates before results |
| Supervised ML/DL, leakage-safe evaluation, model deployment/drift | `patterns/ml-model-development.md` | rules/simple-model baseline; versioned train/serve contract |
| sLLM selection, LoRA/QLoRA/fine-tuning/quantization | `patterns/model-finetuning.md` | prompt/RAG/tool baseline first; tune only a measured stable behavior gap |
| Memory/long input/caching | `patterns/context-memory.md` | compact context with source pointer |
| User-facing LLM reliability | `patterns/harness-reliability.md` | timeouts/validation/metrics |
| Machine-readable model output; single-call prompt design | `patterns/structured-output.md` | type/schema validation; measure before rewriting prompts |
| Email/booking/payments/deletes/writes | `patterns/human-approval.md` | preview + explicit approval + receipt |
| Agent quality, eval regression | `patterns/evaluation.md` | golden set and baseline |
| Shared tools / MCP | `patterns/mcp.md` | ordinary function/API if simpler |
| Existing Spring + LLM | `patterns/spring-ai.md` | phased ChatClient/Tool/RAG |
| Web UI fundamentals, accessibility, CSS/JS, design tokens, usability tests | `patterns/frontend-web.md` | native elements, tokens, all states; keyboard check |
| High-volume pipeline, message buffer, stream vs batch, backfill | `patterns/data-pipeline.md` | batch/DB first; only if volume or latency demands it |
| Connectivity failure, DNS, firewall, TLS, MTU, intermittent timeouts | `patterns/network-troubleshooting.md` | read-only checks by layer; approval for rule changes |
| Vue frontend | `patterns/frontend-vue.md` | preserve UI/UX baseline |
| Spring Backend | `patterns/backend-spring.md` | stable DTO/auth/transaction |
| C/C++ code, native memory/buffer/RAII/ownership, compiler or sanitizer failure | `patterns/c-systems.md` | explicit ownership/lifetime; warning-clean + sanitizer-backed checks |
| Java values, collections, exceptions, Stream, date/number contracts | `patterns/java-core.md` | immutable explicit contracts; standard library first |
| Python/FastAPI | `patterns/python-fastapi.md` | schema/async/DB boundary |
| Git, CI, release | `patterns/devops-git.md` | small branches, actual checks |
| 측정된 CPU 병목을 Rust로 이전할지 | `patterns/rust-hotspot.md`, `guides/cost-performance.md` | profile first; non-Rust alternatives first; port one hotspot only |
| Secret leak scan (Hook/Actions/Ruleset) | `kits/secret-scan/README.md`, `guides/security.md` | optional kit; install only after approval |
| Requirements/decisions change | `patterns/project-traceability.md` | approve Before/After first |
| Permissions/security | `patterns/app-security.md` | runtime access control |
| Entity/relationship/cardinality, keys, normalization, history, analytical schema; DB migration/consistency; cross-service events/outbox | `patterns/data-and-transactions.md` | constraints and compatibility first; single DB first |
| Splitting into services | `patterns/architecture-selection.md` + `patterns/data-and-transactions.md`; add `patterns/harness-reliability.md` and `guides/testing.md` for remote/contract boundaries | modular monolith first; accept the operational bundle before extraction |
| Remote-call timeouts/retries/circuit breaker | `patterns/harness-reliability.md` | timeouts first; test under load |
| AWS resources, IAM, VPC, S3, cost | `patterns/cloud-aws.md` | only if AWS is approved; no new resources without approval |
| SQL, PostgreSQL, indexes, concurrent updates, slow queries | `patterns/sql-postgresql.md` | measure with the plan first |
| Ontology, RDF, SPARQL, knowledge graph | `patterns/ontology-rdf.md` | only for semantic-integration goals; competency questions first |
| Load, stress, performance testing | `guides/testing.md` (performance section) | only with a stated goal; approval for load |
| Dockerfile, Compose, image/runtime issues | `patterns/container-docker.md` | only if containers are approved |
| Kubernetes manifests, probes, rollout, RBAC, cluster debugging | `patterns/kubernetes.md` | only if Kubernetes is approved; confirm context before any kubectl |

## Activation policy
- If current working approach is adequate, don't mention new patterns unprompted unless a material risk is discovered.
- When a pattern can materially improve success or reduce risk, make a **brief proposal**: existing baseline / option / benefit / cost / acceptance criterion / approval required.
- Never create extra Agent, Vector DB, Kafka, Kubernetes, service or dependency just because corresponding pattern exists.
- For simple local changes, use existing `AGENTS.md` instructions and current code only.

## Coverage gaps worth adding only when needed
- Standalone Java application patterns beyond Spring
- Standalone SRE pattern beyond the MSA observability bundle (SLO, error budget and incident response)
- Cost governance patterns covering per-request budgets and model/provider fallback
- Database migration patterns beyond transaction boundaries

새 파일을 먼저 만들지 말고 기존 Guide/Pattern으로 충분한지 확인한다. 실제 프로젝트에서 반복되는 요구와 검증 기준이 생길 때 추가한다.
