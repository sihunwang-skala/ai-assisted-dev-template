# Pattern: Ontology, RDF and Knowledge Graph (only when semantic integration is the goal)
Status: optional | Applies only when an ontology/RDF/knowledge-graph project is approved | Sources: Data Ontology full user-provided text (E27, reviewed 2026-11-10); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 시스템마다 다른 용어의 의미를 명시하고 연결해 통합 질의, 추론, 검증을 가능하게 한다. |
| When to Use | 여러 시스템 간 개념 불일치, 깊고 다양한 관계 질의, 분류 체계/동의어, 표준 기반 데이터 교환. |
| When Not to Use | 거래 처리/집계 중심 업무, 단순 검색 개선만 필요한 경우(분류 체계/동의어 사전으로 충분), 질문이 정해지지 않은 전사 모델링. |
| Alternatives | 용어집, 택소노미/시소러스, 관계형 뷰와 코드 테이블, 속성 그래프, 검색엔진 동의어 사전. |
| Implementation Rules | 능력 질문 먼저, 필요한 만큼만 올리기(용어집 → 분류 → 스키마 → 추론), 기존 어휘 재사용, SHACL 검증. |
| Trade-offs | 의미 통합과 추론을 얻지만 모델링/운영 비용, 전문 인력, 질의 성능 문제가 생긴다. |
| Security Considerations | 그래프 단위 권한, 개인정보는 참조만, 질의 프록시, LLM 생성 질의 검증. |
| Testing & Acceptance Criteria | 능력 질문 질의 회귀, SHACL 검증, 멱등 적재, 개체 식별 근거 기록. |
| Resource & Token Cost | 추론 후 저장 증가, 트리플스토어 운영, LLM 추출/질의 생성 호출. |
| References | E27 (source-derived [S]). 제품 선택/버전/성능은 자체 데이터로 시험. |

## Guardrails
Choosing a triple store, loading data, merging identities (`sameAs`) and sending text to an LLM for extraction are approval-gated (cost, data transfer, hard-to-reverse merges). Labels: [S] Source-derived, [R] Engineering recommendation.
- [S] Start from the questions to be answered (competency questions, 5-8 first), not from "model everything". They define scope and completion; write each as a query to validate the model; keep them as regression tests. Ladder: glossary, taxonomy/SKOS, schema (RDFS), then OWL only when inference creates value. Most needs stop at SKOS synonyms feeding search.
- [S] Ontology does not replace the relational database for transactions and aggregation; it is a semantic layer over several systems. Renaming columns does not fix differing meanings; state the meanings and relations.
- [S] Facts are subject-predicate-object triples; anything that may later gain properties or links should be an IRI, not a literal. IRIs must be stable, free of department/system/version/meaning, and hard to change after publication; keep schema and instance namespaces separate; deprecate rather than delete and keep an equivalence link.
- [S] Reuse existing vocabularies (SKOS, FOAF/organization, Dublin Core, schema.org, PROV, units) and extend only the gaps. Name classes UpperCamel singular, properties lowerCamel, tag labels with languages, keep the ontology in version control with changelog and semantic versioning.
- [S] RDF uses an open-world assumption: missing means unknown, domain/range are inference not validation, and violating a functional property can merge entities. Use OWL to derive knowledge and SHACL to validate data; decide whether validation runs before or after inference; start with a light profile (OWL RL) before heavier logics. "No result" must be reported as "not recorded", not "does not exist".
- [S] Relation attributes (periods, sources) use an intermediate node class (most portable); model history only for properties that questions require. Rarely-needed richness costs triples and query complexity.
- [S] Mapping: declare relational-to-RDF mappings (for example R2RML) instead of burying them in scripts; use source keys in IRIs; skip NULLs; convert codes to IRIs. Materialize for inference and path queries; virtualize for fresh, simple queries; hybrid is common.
- [S] Entity resolution: block to limit comparisons, score with several weighted signals, auto-merge only above a conservative threshold, route the grey zone to review, record score, method and time, store links in a separate graph, and prefer weaker link predicates until accuracy is proven (a wrong `sameAs` propagates and is hard to undo).
- [S] Pipeline: extract, map, resolve, validate, load into named graphs by source/time/trust, regenerate inferred graph, run competency-query regression; stop on validation violations; replace whole graphs rather than patching. Record provenance (PROV) at graph level.
- [S] Queries: path queries are powerful but unbounded ones explode; limit depth, start from the narrowest set, precompute hot paths, use a text index for substring search, and inspect plans. Compare stores on your own query mix; consider an RDF layer for meaning with a property graph for traversal analytics.
- [S] Access control is usually per graph: separate graphs by audience or put a query-rewriting proxy in front; keep personal data in source systems and store identifiers only.
- [S] LLM combination (GraphRAG): vector search answers descriptive questions, graph queries answer multi-hop, list, count and history questions; use both. For natural-language-to-query give the model a compact schema, reject update keywords, parse, check every term against the ontology (invented properties are the main failure), enforce limits and allow a bounded retry with the error. For extraction use a closed predicate list, require verbatim evidence and check it exists in the source, keep confidence, and load results into a separate review graph.

### Checks
Competency queries return results; shapes catch seeded violations; pipeline rerun yields identical graphs; every merge has recorded evidence and is reversible by dropping the link graph; path queries bounded; generated queries rejected on unknown terms.
