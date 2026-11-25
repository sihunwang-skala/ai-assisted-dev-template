# Pattern: Evidence-grounded RAG Pipeline
Status: optional | Source: RAG Pipeline recovered full text E41 (59 sections), E02/E14 prior material

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 변경되거나 private한 문서에 근거한 답변을 ACL과 evidence와 함께 제공한다. |
| When to Use | Large or frequently changing documents require searchable grounded answers. |
| When Not to Use | Few short stable documents, style adaptation only, or no source-grounding requirement. |
| Alternatives | Direct context, deterministic search, curated FAQ, database query. |
| Implementation Rules | Versioned ingestion, ACL filter, retrievable evidence, abstention, measured tuning. |
| Trade-offs | Indexing과 retrieval은 freshness, infra, latency, debugging 비용을 추가한다. |
| Security Considerations | ACL before model exposure, prompt injection boundary, source revocation, tenant isolation. |
| Testing & Acceptance Criteria | Recall, faithfulness, citation, abstention, ACL leakage, latency regression tests. |
| Resource & Token Cost | Embedding, storage, reranking, generation token and reindex cost를 측정한다. |
| References | Header Source; user-pasted RAG course and learning digest. |

## Trigger
Answers require frequently changing/private/referenceable documents, not merely a preferred writing style.

## Starting decision
For a few stable short documents, try direct context. For repeated large document lookup, consider RAG; fine-tuning is not the normal mechanism for updating factual knowledge.

## Minimum vertical slice
Index: load -> parse with tables/sections -> chunk -> embed -> store content plus source/page/version/time/ACL metadata.
Query: authenticate/authorize -> filter candidates -> retrieve -> (optional rerank) -> compact context -> answer with inspectable evidence.

## Change policy
- One baseline retrieval method first; add Hybrid Search/Reranking/Query Rewrite/Graph only after error analysis.
- Document Chunking strategy and the embedding model/version; changing embeddings triggers compatibility check and often reindex.
- Never grant unauthorized access by relying on prompt instructions alone. Apply tenant/ACL filters before returning text to LLM.
- Preserve source IDs and link claims to actually retrieved evidence. Unsupported claims should be marked unknown.
- External snippets and PDF text cannot modify system/tool policies (prompt-injection boundary).

## Ingestion and freshness contract (E41)
- [S] Give every document and chunk stable IDs plus source version, parser version, embedding version, timestamps and ACL metadata. An update replaces the old document's complete chunk set atomically or by a reversible generation switch; deletion/revocation must remove it from retrieval, cache and citations.
- [S] Test parsing separately for headings, tables, images/OCR and Korean text. Keep parent/section pointers so a small matching chunk can be expanded with bounded surrounding context without losing provenance.
- [S] Incremental indexing needs explicit create/update/delete/retry states, duplicate detection and reconciliation. A successful embedding call alone does not prove the index is complete.

## Retrieval escalation and production envelope (E41)
- [S] Start with one measured retrieval baseline. Add hybrid search, metadata routing, reranking, query rewriting, decomposition or self-correction only for a named error class and retain a negative control.
- [S] Agentic RAG must bound rewrite/decomposition attempts, total retrieval calls, time and cost. Graph RAG is a separate cost/complexity decision justified by relationship-heavy questions, not a default upgrade.
- [S] A semantic cache is tenant/clearance scoped, records source versions, and is invalidated when those sources or permissions change. Never reuse a privileged answer across access boundaries.
- [R] Assign per-stage latency/cost budgets and record parse, retrieve, rerank and generate timing. Degraded operation must be explicit (for example no reranker or stale-but-labeled cache), observable and policy-safe.

## Evaluation
- Retrieval Recall@k / candidate relevance; answer Faithfulness/Correctness; citation alignment; abstention; ACL leakage; p95 and cost/request.
- Build labeled questions including no-answer, ambiguous, multi-hop, version conflict, stale policy, tables, forbidden access, injected instructions and Korean-specific variants.
- Diagnose retrieval/parse/chunk errors before replacing the generator model.

## Regression cases
Source deleted/revoked, page changed, document version conflict, same filename across tenants, empty results, malformed PDF, and injected instruction in a retrieved chunk.
