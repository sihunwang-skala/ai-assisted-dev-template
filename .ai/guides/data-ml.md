# Data / Statistics / Recommendation / ML Guide (On demand)

1. 비즈니스 목표와 Prediction/Ranking/Decision 목적, 단위(User/Session/Item)를 먼저 정의한다.
2. Source, Consent, Retention, Dataset version, Schema, missingness, leakage, duplication, identity resolution을 점검한다.
3. Rules / Content-based Baseline부터 시작하고, Collaborative Filtering / Embedding / LLM Ranking은 데이터와 평가 근거가 있을 때 추가한다.
4. Time-based split, group leakage, selection bias, class imbalance를 확인하고 사용 가능한 Offline Metric을 정한다.
5. 추천에서는 Eligibility/Hard Constraints와 Preference Ranking을 분리, 취소/조회 등 행동을 다른 Signal로 취급한다.
6. Cold Start, sparse data, missing data, fairness/coverage, fallback 시나리오를 문서화한다.
7. 실험 결과는 Baseline vs Candidate, Data size, Seeds, Confidence/uncertainty, Latency/Cost를 함께 보고한다.
8. 통계적 유의성이나 개선 수치는 실제 결과 없이 주장하지 않는다.

벡터를 저장·재색인하거나 임베딩 모델을 바꾸면 `.ai/patterns/vector-store-lifecycle.md`를 연다. 개인화 후보 생성·랭킹·온라인 실험이면 `.ai/patterns/recommendation-systems.md`를 열고, 노출 로그가 없는 클릭 데이터는 미노출 항목을 음성 표본으로 간주하지 않는다.

결측·이상치·조인 정제, KPI/코호트 분석, 신뢰구간·가설검정 또는 A/B 실험이면 `.ai/patterns/analysis-statistics.md`를 연다. 엔티티·관계·키·정규화·이력·스타 스키마를 설계하면 `.ai/patterns/data-and-transactions.md`를 연다.

예측/분류/회귀 모델을 새로 개발하거나 배포·드리프트를 다루면 `.ai/patterns/ml-model-development.md`를 연다. sLLM 선택, LoRA/QLoRA, 양자화 또는 파인튜닝이면 `.ai/patterns/model-finetuning.md`를 열고 Prompt/RAG/Tool과 단순 모델 기준선을 먼저 비교한다.
