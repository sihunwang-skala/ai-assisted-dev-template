# Pattern: Recommendation Systems from Exposure to Feedback Loop
Status: optional | Applies to personalized ranking or recommendation | Sources: Recommendation System full recovered course (E38, reviewed 2026-11-11); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 노출 편향과 피드백 루프를 통제하며 후보 생성부터 온라인 실험까지 검증 가능한 추천 시스템을 만든다. |
| When to Use | 개인화 추천, 피드/검색 순위, 후보 생성, 랭킹 모델, 추천 A/B 테스트, 콜드 스타트. |
| When Not to Use | 정렬 규칙이 명확하거나 데이터·트래픽이 부족해 규칙/인기순 기준선으로 충분한 경우. |
| Alternatives | 규칙, 최신/인기순, 콘텐츠 기반, 편집 큐레이션, 검색 필터. |
| Implementation Rules | Eligibility → candidate generation → ranking → policy/rerank → serving을 분리하고 노출 로그와 버전을 남긴다. |
| Trade-offs | 개인화는 관련성을 높일 수 있지만 편향, 지연, 설명 가능성, 운영·실험 비용과 피드백 루프를 만든다. |
| Security Considerations | 동의·목적·보존 기간·삭제를 지키며 민감 속성을 직접 또는 대리 변수로 부당하게 사용하지 않는다. |
| Testing & Acceptance Criteria | 시간 분할 오프라인 평가, 후보 recall, 랭킹 품질/커버리지, 안정적 온라인 할당과 guardrail을 검증한다. |
| Resource & Token Cost | 특징/임베딩 계산, 후보 저장, 온라인 랭킹 지연, 캐시, 실험 트래픽과 탐색 비용. |
| References | E38 [S]. 모델·통계·제품별 수치는 실제 데이터와 공식 문서로 재확인. |

## Guardrails
New personal-data collection, sensitive attributes, external data/model providers, user-visible exploration, online experiments, automated high-impact decisions, or production rollout need approval. Do not claim lift without a predeclared experiment and actual evidence. Labels: [S] Source-derived, [R] Engineering recommendation.

### Objective, data and logging
- [S] Define the user/session/item unit, eligibility constraints, one primary product outcome and guardrails before choosing a model. Keep hard constraints separate from preference ranking.
- [S] Log impressions/exposures with user or cohort, item, position, candidate source, score/model/policy version, context and timestamp, then join outcomes. Unexposed items are unknown, not valid negatives; account for position and selection bias.
- [R] Record consent, purpose, retention, deletion path, feature provenance and training snapshot. Avoid features unavailable at serving time and any future information leakage.

### Pipeline and baselines
- [S] Separate candidate generation from ranking. Evaluate candidate Recall@K first; a ranker cannot recover an item that never entered the candidate set. Remove ineligible/blocked/seen items at the appropriate stage and test that policy explicitly.
- [S] Start with a measurable popular/rules/content baseline. Add collaborative, embedding or learned ranking only when it improves the declared objective within latency and coverage constraints.
- [S] Treat new-user and new-item cold start separately. Use staged fallbacks such as onboarding/context, popularity by segment and content features; replace hand-chosen thresholds with measured criteria.

### Offline and online evaluation
- [S] Split by time and, when needed, by user/group; deduplicate entities before splitting. Report candidate recall, ranking metrics such as NDCG, coverage/diversity/novelty and latency together. Offline gains can fail online through leakage, exposure bias, drift or objective mismatch.
- [S] For A/B tests, assign users stably, choose sample size and duration in advance, declare one primary metric plus guardrails, and do not repeatedly peek and stop on a favourable fluctuation. Check sample-ratio mismatch and exposure integrity.
- [R] Use counterfactual methods such as propensity weighting only when exposure propensities and assumptions are auditable; always report uncertainty and sensitivity.

### Serving, cache and degradation
- [S] Allocate a latency budget to retrieval, features, scoring, policy and response. Define an explicit fallback for unavailable features/models and measure fallback rate and quality; do not hide degradation.
- [S] Include model, feature and policy versions in cache keys. Invalidate or age entries when user/item state changes; prevent an old cache from mixing with a new model.
- [S] Prevent N+1 feature/item calls through batch fetches or precomputation. Observe candidate count/source, each-stage latency, cache hit rate, errors and model/version distribution.

### Feedback loops and safety
- [S] Monitor concentration, catalogue/user coverage, new-item exposure delay, diversity, exploration rate and segment outcomes, not CTR alone. Optimizing only clicks can promote sensational or repetitive content and suppress unseen items.
- [S] Give exploration an explicit bounded budget and product safety constraints. Keep a non-personalized fallback and a way to disable a model/policy quickly.
- [R] Review outcomes by meaningful cohorts for quality and harm, but do not infer or store sensitive group membership without an approved lawful purpose.

### Checks
Exposure-to-outcome join is reproducible; time split has no future leakage; only exposed items form negatives; candidate Recall@K meets its target before ranker tuning; eligibility and seen-item rules are tested; model/version is present in logs and cache keys; offline report includes coverage and latency; A/B assignment is stable with declared primary/guardrails; fallback and rollback work; concentration and new-item delay are monitored.
