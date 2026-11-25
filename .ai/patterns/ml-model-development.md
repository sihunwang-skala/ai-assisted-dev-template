# Pattern: ML Model Development and Release
Status: optional | Approval: data use and production decision changes may require approval | Source: recovered ML/DL E48 (23 sections)

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 재현 가능한 데이터 분할·평가·운영 계약으로 ML/DL 모델을 개발하고 배포한다. |
| When to Use | Rules are insufficient, labels/signals exist, and prediction quality can be measured. |
| When Not to Use | Deterministic rules solve it, labels are undefined, sample is inadequate, or decisions need causal proof. |
| Alternatives | Rules/heuristics, descriptive analysis, manual workflow, vendor API. |
| Implementation Rules | Problem/label contract, leakage-safe split, simple baseline, cost-aware metrics, versioned pipeline. |
| Trade-offs | Better offline fit can increase latency, opacity, data and operational burden. |
| Security Considerations | Legal data use, minimization, sensitive-feature review, access control and deletion propagation. |
| Testing & Acceptance Criteria | Reproducible baseline comparison, slice/leakage tests, serving parity, drift/fallback/rollback evidence. |
| Resource & Token Cost | Training, feature computation, inference capacity and monitoring/labeling cost are budgeted. |
| References | E48; selected library/model documentation at implementation time. |

## Problem and data contract
- [S] Define prediction unit, target/label, observation time, prediction horizon, action taken from the score and error costs. Do not train merely because data exists.
- [S] Split before fitting preprocessing. Use time-based or entity/group splits when future records or repeated users/items would leak; keep test data untouched and use cross-validation only when compatible with the data-generating process.
- [S] Version raw snapshot, feature code, preprocessing artifacts, labels, split IDs, seeds and environment. The same transformation contract must run at training and serving.

## Baseline and evaluation
- [S] Start with a rule or simple model. Choose metrics for the error costs and imbalance (for example precision/recall, PR-AUC, calibration), not accuracy by habit; select decision thresholds on validation data.
- [S] Report overall and important slice results with uncertainty, sample size, latency and cost. Feature importance/explanations describe model behavior and are not causal proof.
- [R] Promote only if the candidate beats the baseline by a predeclared material threshold without unacceptable safety/fairness/slice regressions.

## Production contract
- [S] Validate inputs, handle missing/out-of-range features, log model/data versions and expose a safe rule/manual fallback. Shadow/canary before broad rollout and retain rollback artifacts.
- [S] Monitor input/schema drift, prediction distribution, performance when delayed labels arrive, latency, failures and business outcomes. Retraining needs a trigger, approval boundary, fresh evaluation and rollback—not an automatic reaction to any drift alarm.

## Evidence labels
- `[S]` Source-derived from E48. `[R]` Conservative engineering recommendation.
