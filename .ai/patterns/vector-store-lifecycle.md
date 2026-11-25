# Pattern: Vector Store Lifecycle and Retrieval Integrity
Status: optional | Applies when embeddings are persisted or searched | Sources: Vector DB full recovered course (E37, reviewed 2026-11-11); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 벡터 저장소를 재현 가능하고 접근 통제가 유지되며 모델 교체 시 안전하게 전환 가능한 검색 자산으로 운영한다. |
| When to Use | 임베딩 적재, 벡터 인덱스/컬렉션 설계, 메타데이터 필터, 모델 교체, 재색인, 검색 품질 장애. |
| When Not to Use | 임베딩을 저장하지 않는 일회성 계산이나 키워드 검색만 쓰는 경우. RAG 답변 품질 전반은 `retrieval-tuning.md`. |
| Alternatives | 관계형/전문 검색, 키워드 검색, 소규모 exact scan, 하이브리드 검색. |
| Implementation Rules | 모델·차원·거리·정규화·청크·ID·메타데이터 계약을 먼저 고정하고 원문에서 언제든 재생성 가능하게 한다. |
| Trade-offs | ANN은 지연을 줄이는 대신 recall과 운영 복잡도를, 하이브리드는 품질 가능성과 튜닝 비용을 늘린다. |
| Security Considerations | ACL/tenant 조건은 검색 쿼리 내부에서 적용하고 원문·메타데이터의 민감도와 보존 기간을 지킨다. |
| Testing & Acceptance Criteria | 동일 평가 집합으로 Recall@k와 p95를 비교하고 ACL 누출, 삭제/갱신, 재색인, 전환/복귀를 검증한다. |
| Resource & Token Cost | 임베딩 생성, 이중 인덱스, 저장 공간, 검색/필터 지연, 재색인 시간. |
| References | E37 [S]. 제품별 인덱스·필터 동작과 제한은 사용 중인 버전 공식 문서로 재확인. |

## Guardrails
Index/collection deletion, mass re-embedding, model or distance changes, tenant/ACL changes, external embedding services, and production cutover need approval. Keep the original documents, metadata and a repeatable reindex path; the vector index is derived data. Labels: [S] Source-derived, [R] Engineering recommendation.

### Ingestion contract
- [S] Before loading data, record embedding provider/model/version, dimension, distance metric, normalization, chunking version, deterministic ID scheme and required metadata. Equal dimensions do not make embeddings from different models compatible; never mix them in one searchable space.
- [S] Use stable IDs such as `document_id#chunk_index` and make a document update replace or invalidate every old chunk. Store source, document/version, chunk position, updated time and access-control attributes needed to reproduce a result.
- [R] Treat embedding and chunking versions as schema. Reject writes with an unexpected version instead of silently producing a mixed index.

### Search, filters and collection boundaries
- [S] Apply tenant, permission and eligibility filters inside the database/ANN query. Fetching unrestricted neighbours and post-filtering can leak candidates and can return fewer than `k`; test selective filters explicitly.
- [S] Split collections only when data is never searched together, uses incompatible models, has different lifecycle/access boundaries, or scale measurements require it. Prefer metadata filters over premature physical separation.
- [S] Add hybrid keyword/vector retrieval only after error analysis shows complementary failures. Fuse ranks (for example reciprocal-rank fusion), not incomparable raw scores.

### Model migration and recovery
- [S] Build a parallel index/column/collection for a new model, backfill from the source of truth, run the same evaluation set, shadow or canary traffic, switch through a reversible pointer, observe, and remove the old index only after the rollback window.
- [S] Preserve original documents and metadata plus scripts for full, changed-since and single-document reindex. A backup of vectors alone is not sufficient; prove recovery by rebuilding and rerunning evaluation.
- [R] Log query version, applied filters, retrieved IDs/scores, index/model version, latency and result count with privacy controls so a retrieval failure can be reproduced.

### Evaluation and operations
- [S] Measure retrieval quality (for example Recall@k on labelled queries) and latency percentiles together using representative queries and filters. ANN tuning without a recall target is incomplete.
- [S] Monitor zero/short result rates, filter selectivity, ingestion lag, stale/orphan chunks, index size, error rate and p95/p99. Investigate data/model-version mismatch before changing ANN parameters.
- [R] Keep a small exact-search baseline where feasible to estimate ANN loss, and define cutover and rollback thresholds before a migration.

### Checks
Contract rejects wrong dimensions/model versions; update removes stale chunks; delete is complete; two tenants cannot retrieve each other's IDs; selective filters still return valid `k` behavior; exact-versus-ANN recall and p95 are recorded; parallel-model comparison uses the same corpus/queries; full and one-document rebuilds work; cutover can return to the old index.
