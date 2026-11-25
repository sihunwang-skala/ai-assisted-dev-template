# Pattern: Reproducible Data Analysis and Statistical Decisions
Status: optional | Applies to descriptive analysis, inference and controlled experiments | Sources: Data Analysis & Basic Statistics full recovered course (E40, reviewed 2026-11-11); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 질문·모집단·분모부터 데이터 검사, 추정, 실험, 보고까지 재현 가능하고 과잉 해석 없이 수행한다. |
| When to Use | KPI/코호트 분석, 데이터 정제·조인, 그룹 비교, 신뢰구간·가설검정, A/B 테스트, 분석 보고서. |
| When Not to Use | 단순한 결정적 집계만 필요하고 추론·표본·실험 해석이 전혀 없는 경우. |
| Alternatives | 검증된 운영 리포트, 규칙 기반 모니터링, 질적 조사, 추가 데이터 수집. |
| Implementation Rules | 질문과 분석 계획을 먼저 고정하고 데이터 품질 검사 → 기술통계/시각화 → 추론 → 한계·행동 순서로 진행한다. |
| Trade-offs | 엄격한 검사와 사전 계획은 속도를 늦추지만 선택 편향, 거짓 양성, 재현 불가 결론을 줄인다. |
| Security Considerations | 최소 데이터, 승인된 목적·동의·보존·삭제·비식별화, 소집단 재식별 위험과 결과 접근 통제를 적용한다. |
| Testing & Acceptance Criteria | 조인/결측/중복 검사, 재실행 결과, 효과크기·구간, 실험 무결성, 다중검정과 보고 한계를 검증한다. |
| Resource & Token Cost | 스냅샷 저장, 정제·부트스트랩/검정 계산, 실험 트래픽, 리뷰 시간. |
| References | E40 [S]. 임계값·검정 선택은 질문, 표본 설계와 가정을 재확인하고 필요 시 통계 전문가 검토. |

## Guardrails
New personal/sensitive data collection, joining datasets that changes identifiability, external upload, user-facing experiment, or high-impact automated decision needs approval. Do not delete/overwrite the only raw dataset, stop an experiment after peeking, or claim causality/lift without the required design and evidence. Labels: [S] Source-derived, [R] Engineering recommendation.

### Analysis contract
- [S] Write the decision/question, target population, unit of analysis, numerator/denominator, observation window, outcome, segments, inclusion/exclusion and what action could change before touching results. Separate confirmatory hypotheses from exploration.
- [S] Record data sources, extraction time/query, schema/units/time zones, snapshot or immutable version, consent/retention and known coverage gaps. A notebook without its input version is not reproducible.
- [R] Predeclare the primary metric and practically meaningful minimum effect when a decision depends on inference; avoid inventing precision or a success threshold after seeing data.

### Data audit and transformation
- [S] Inspect shape, types, units, ranges, duplicates, missingness by relevant group and impossible values before analysis. Missingness can be signal; document whether deletion/imputation is plausible and retain a missingness indicator where useful.
- [S] Do not automatically remove outliers. Classify collection/unit errors, mixed populations and genuine extreme events; report sensitivity with and without justified treatment and preserve the transformation/exclusion log.
- [S] Assert join cardinality (`1:1`, `m:1`, etc.), key uniqueness, match/unmatched counts and row counts before/after every merge. A left join that grows rows usually means duplicated right-side keys; do not silently `drop_duplicates` without resolving ownership.
- [S] Keep raw data immutable and transformations executable in order. Fix parsing/type/category/date problems explicitly, retain source columns when conversion can fail, and test aggregate invariants before and after cleaning.

### Description and visualization
- [S] Match summaries to measurement scale and distribution. Report denominator and sample size; for skewed/mixed data show median/quantiles and distribution, not only the mean. Use percentiles for tail behaviour rather than averages that hide it.
- [S] Plot the data before choosing a model or test. Check nonlinear relationships, subgroups and influential observations; correlation summarizes association, not causation, and can hide different shapes or Simpson's paradox.
- [S] Keep chart axes, scales, binning, time windows and missing categories honest and labelled. Do not truncate axes or use area/3D effects to exaggerate differences; show uncertainty where the conclusion depends on estimates.

### Inference and uncertainty
- [S] Report the estimate/difference, confidence interval and practical effect size with the p-value. A p-value is the probability of data this extreme under the null assumptions, not the probability the hypothesis is true or the magnitude/reproducibility of an effect.
- [S] Match independent/paired, numeric/categorical and parametric/robust methods to sampling design and assumptions. Failure to reject is not proof of equality; low power means the analysis may be unable to detect a meaningful effect.
- [S] Determine sample size from baseline, minimum detectable effect, error tolerance, power and allocation before data collection. If many metrics/segments/times are tested, pre-register a primary result or apply an appropriate family/FDR correction; exploratory findings require confirmation.
- [R] Treat conventional cutoffs and effect-size labels as context-dependent heuristics, not universal pass/fail rules. Prefer sensitivity analysis and domain consequences when assumptions are uncertain.

### Experiments and causal claims
- [S] Observational association alone does not establish causality. For an experiment, randomize at a stable unit that prevents cross-exposure, keep assignment stable, define primary and guardrail metrics, exclusions, duration and stopping rule in advance, and run A/A validation when the platform is new.
- [S] Before reading outcomes, test sample-ratio mismatch, pre-treatment balance, duplicate units, cross-group exposure, logging loss and eligibility/exposure consistency. A failed integrity gate blocks the result; it is not repaired by a more sophisticated statistical test.
- [S] Do not repeatedly peek and stop on significance. Use the fixed plan or an approved sequential design; label post-hoc segments as exploratory and correct for multiplicity.

### Reproducibility and communication
- [S] Save code, environment/dependency versions, random seeds, data snapshot/query and ordered transformations. A rerun from the same inputs must reproduce tables and figures or explain nondeterminism.
- [S] Lead the report with decision and result, then evidence: population/period/sample, integrity checks, method, absolute and relative effect with interval, sensitivity/segments, limitations and recommended next action. State who or what is missing and what the result cannot establish.
- [R] Add executable gates for recurring high-impact analyses: unique-key/join assertions, denominator checks, missingness/range tests, SRM/balance/cross-exposure checks and a block on publishing when integrity fails.

### Checks
Question and denominator predeclared; immutable input/version recorded; duplicate/missing/outlier decisions reproducible; joins assert cardinality and row/match counts; summaries include distribution and sample size; chart scales are truthful; estimate/CI/effect/p-value semantics are correct; power/MDE and multiplicity handled; experiment assignment and SRM/balance/duplicate/cross-exposure gates pass; same inputs rerun to the same outputs; report states limitations and causal boundary.
