# Pattern: Retrieval Improvement by Measured Failure
Status: optional | Source: RAG Pipeline pasted course; Vector DB course curriculum summary

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | RAG retrieval 실패 원인을 측정한 뒤 가장 작은 tuning을 선택한다. |
| When to Use | Known relevant passage miss or poor ranking가 재현될 때. |
| When Not to Use | Baseline failure가 없거나 parsing and ACL 오류가 아직 확인되지 않은 경우. |
| Alternatives | Parsing fix, metadata correction, chunk change, dense, sparse, hybrid, reranking. |
| Implementation Rules | Fixed queries and source IDs, stage diagnosis, one change at a time, keep or reject decision. |
| Trade-offs | 품질 개선 가능성과 함께 index, latency, parameter, maintenance 복잡성이 증가한다. |
| Security Considerations | 모든 후보 방식에서 ACL과 tenant filter를 유지하고 benchmark data를 보호한다. |
| Testing & Acceptance Criteria | Recall, movement, faithfulness, p95, cost, version and ACL regression. |
| Resource & Token Cost | Candidate count, reranker calls, index storage and query latency를 비교한다. |
| References | Header Source; pasted RAG course and Vector DB outline. |

## Trigger
Baseline RAG misses known relevant passages or ranks weak evidence ahead of correct documents.

## Do in order
1. Reproduce with fixed query, expected source IDs, source version and ACL.
2. Check parsing (tables, headers, page boundary), chunk size/overlap and metadata correctness.
3. Inspect whether candidate recall is poor or good candidates are badly ordered.
4. Only then compare Dense, Sparse/BM25, Hybrid, metadata filtering and reranking.
5. Measure quality against cost/latency and decide to retain or reject the change.

## Evaluation record
Query ID | expected sources | retrieved IDs | recall | rerank movement | answer faithfulness | p95 | cost | recommendation.

## Explicit exclusions
- Do not hardcode HNSW/IVF/BM25 tuning constants as universal best settings.
- Do not claim Graph RAG or Self-RAG is always superior; each adds indexing/latency/debugging costs.
- Do not use benchmark output or citations as if experimentally verified until tests actually ran.
