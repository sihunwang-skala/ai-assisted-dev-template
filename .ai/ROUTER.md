# Mandatory Selective Context Router

이 파일은 전체 문서를 읽기 위한 목차가 아니라 Context를 제한하기 위한 Router다. `AGENTS.md` + 최신 요청 + 관련 문서/코드만으로 충분하면 추가 Guide나 Pattern을 열지 않는다.

## Loading sequence
1. 현재 작업의 Requirement, 예상 변경 지점, 검증 기준을 한 문장씩 정한다.
2. 관련 구현 파일, 인접 호출부, 관련 테스트와 현재 Diff를 먼저 확인한다.
3. 아래 표에서 직접 관련된 Guide만 연다.
4. 기존 방식으로 해결되지 않거나 명시적 설계 판단이 필요할 때만 Catalog에서 관련 Pattern을 연다.
5. Security, Contract, Regression 영향이 발견되면 필요한 범위만 추가 로드한다.

이미 읽은 파일은 변경되었거나 증거가 부족할 때만 다시 연다. Context가 커지면 확정 결정, 미완료 작업, 검증 상태를 요약하고 원문 전체를 중복 적재하지 않는다.

| Trigger | Read only |
|---|---|
| UI, CSS, client, UX, responsive | `.ai/guides/frontend.md`, 필요 시 `docs/DESIGN_SYSTEM.md`, `.ai/patterns/frontend-web.md` (Vue: `frontend-vue.md`) |
| Queue/stream/high-volume ingestion; connection or DNS/TLS failures | `.ai/patterns/data-pipeline.md`; `.ai/patterns/network-troubleshooting.md` |
| API, server, DB, auth | `.ai/guides/backend.md` |
| Python project/code | `.ai/guides/python.md` |
| Java language/collections/exceptions/Stream/date | `.ai/patterns/java-core.md` |
| Spring Boot | `.ai/guides/backend.md`, `.ai/patterns/backend-spring.md`; Java 언어 규칙도 필요하면 `java-core.md` 추가 |
| C/C++ source, native boundary, pointer/RAII/memory/sanitizer issue | `.ai/patterns/c-systems.md` |
| FastAPI | `.ai/guides/python.md`, 필요 시 `.ai/patterns/python-fastapi.md` |
| Database, transaction, migration | `.ai/guides/backend.md`, 필요 시 `.ai/patterns/data-and-transactions.md`; SQL/PostgreSQL: `.ai/patterns/sql-postgresql.md` |
| LangGraph, Agent, Tools, RAG | `.ai/guides/ai-agent.md` |
| LLM/Transformer, model/inference selection, tokenizer/context limits | `.ai/guides/ai-agent.md`, 설계 판단이면 `.ai/patterns/architecture-selection.md` |
| Embedding persistence, vector index/filter, model migration or reindex | `.ai/patterns/vector-store-lifecycle.md`; RAG retrieval quality까지 다루면 `.ai/patterns/retrieval-tuning.md` 추가 |
| Data cleaning, KPI/cohort analysis, statistics, A/B experiment | `.ai/guides/data-ml.md`, `.ai/patterns/analysis-statistics.md` |
| Data entity/relationship/cardinality, normalization, history, analytical schema | `.ai/guides/backend.md`, `.ai/patterns/data-and-transactions.md` |
| ML/model development, leakage, model deployment/drift | `.ai/guides/data-ml.md`, 필요 시 `.ai/patterns/ml-model-development.md` |
| sLLM selection, fine-tuning, LoRA/QLoRA, quantization | `.ai/guides/data-ml.md`, `.ai/patterns/model-finetuning.md` |
| Recommendation, personalization, candidate/ranking, recommender A/B test | `.ai/guides/data-ml.md`, `.ai/patterns/recommendation-systems.md` |
| Service split/MSA/distributed boundary | `.ai/patterns/architecture-selection.md`, `.ai/patterns/data-and-transactions.md`; remote call이면 `.ai/patterns/harness-reliability.md`, contract면 `.ai/guides/testing.md` 추가 |
| Secret, identity, permission, compliance | `.ai/guides/security.md`; Secret Scan 설치/검증이면 `.ai/kits/secret-scan/README.md` |
| Bugs, tests, regressions, CI | `.ai/guides/testing.md` |
| Deployment, operations, logging | `.ai/guides/operations.md`; if containers: `.ai/patterns/container-docker.md`; if Kubernetes: `.ai/patterns/kubernetes.md`; if AWS: `.ai/patterns/cloud-aws.md` |
| Token/latency/cloud budget, caching | `.ai/guides/cost-performance.md` |
| 성능 병목, "Rust로 바꾸자"는 제안 | `.ai/guides/cost-performance.md`, 병목이 측정된 CPU-bound면 `.ai/patterns/rust-hotspot.md` |
| Context, memory, long input | `.ai/patterns/context-memory.md` |
| Harness, retry, timeout, fallback | `.ai/patterns/harness-reliability.md` |
| Evaluation, release quality gate | `.ai/patterns/evaluation.md` |
| HITL, consequential external write | `.ai/patterns/human-approval.md` |

주의: 파일을 읽었다는 사실만으로 기능 구현/승인/검증이 된 것은 아니다.

## Deep implementation patterns (only when needed)
- See `.ai/PATTERN_CATALOG.md` for topic-to-pattern mapping. The catalog is **index only**, not a command to load all files.
- `_master/`(전자책 추적, Pattern 작성 표준, 템플릿 변경 이력)는 템플릿 관리자 전용이다. 프로젝트 복사본에는 없을 수 있으며 일반 개발 작업에서는 읽지 않는다.
- If a new optional pattern would materially improve the design, use `.ai/prompts/PROPOSE_PATTERN.md` and ask for user approval where required.
- Never automatically add Multi-Agent, LangGraph, RAG, MCP, vector databases, recommendation infrastructure, microservices, Kubernetes or cloud infra.
- 필요한 파일을 최소화하더라도 Security 검증과 관련 Regression 범위는 축소하지 않는다.
