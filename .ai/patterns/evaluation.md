# Pattern: LLM/Agent Evaluation and Regression
Status: optional | Sources: AI Agent PART 7; Harness Engineering; RAG course; Prompt Engineering completed deep blocks E17; LLM/Transformer E50

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | LLM, RAG, Tool, Agent 변경의 품질과 Regression을 재현 가능하게 평가한다. |
| When to Use | Prompt, model, retrieval, routing, tooling, architecture 변경. |
| When Not to Use | 명확한 deterministic unit test 하나로 충분한 비 AI 로직. |
| Alternatives | Golden Set, rule-based checks, human review, online monitoring, A/B test. |
| Implementation Rules | Pinned baseline, stage metrics, calibrated judges, failure reporting. |
| Trade-offs | 평가 범위가 커질수록 비용과 시간은 증가하지만 잘못된 개선 채택을 줄인다. |
| Security Considerations | 평가 데이터의 privacy, label leakage, judge injection과 access를 통제한다. |
| Testing & Acceptance Criteria | Golden Set regression, edge cases, human calibration, release gate. |
| Resource & Token Cost | Dataset size, judge calls, tokens, latency, human review cost를 기록한다. |
| References | Header Sources; mixed source-derived and engineering recommendation. |

## Baselines
Define business success plus failure cost before changing prompt, model, retrieval, routing, tooling or architecture. Maintain a small Golden Set with expected outcomes, relevant evidence and edge cases.

## Measure by stage
- Retrieval: relevant document Recall@k and candidate quality.
- Generation: factual correctness, faithfulness to evidence, abstention and response format.
- Tooling: tool-selection precision, argument validity, permission violations, tool completion and duplicate side effects.
- Agent trajectory: success, bounded iterations, routing/replanning, unnecessary calls and HITL respect.
- System: p50/p95, error rate, tokens/request, cost/request and cache hit rate.

## Release gate
- Compare changed system with pinned baseline on the same dataset and conditions.
- Record judge version/rubric if LLM-as-Judge is used and calibrate with human-reviewed examples.
- Report failures and uncertainty; do not label unrun tests as pass.
- Regression tests for previously fixed bugs are mandatory before accepting an architectural improvement.

## Guard against gaming
Do not optimize only the judge's score, hardcode Golden Set responses, leak test labels into prompts, or claim significance from tiny samples.

## Prompt measure-and-fix loop (conditional; added v1.7, E17)
Use when a prompt or model setting is changed for a recurring task. Skip for one-off prompts. Labels: [S] Source-derived, [R] Engineering recommendation.
- [S] Build the evaluation set and scorer before editing the prompt; record a baseline from the simplest instruction. About 20-30 cases is enough to start; it is a smoke signal, not proof.
- [S] Change one element per iteration (role, format, example, criterion, setting), re-run the same set, record the score, and revert changes that lower it. Keep the names of cases that regressed, not only the total.
- [S] Run each case several times when sampling is non-deterministic and report instability separately from accuracy. Count invalid-format outputs as failures.
- [S] Compose the set from ordinary cases from real logs, borderline cases, previously failed cases and adversarial/injection cases; human-label the borderline ones. Include unanswerable cases where abstention is expected.
- [S] Cluster failures by type (format, boundary, fabrication, dropped instruction, length, instability, tone) and fix the largest cluster first. A prompt that keeps growing by exceptions suggests splitting the task.
- [S] Repeat evaluation when the model or task changes; a prompt is paired with a model. A set built for one task cannot grade another.
- [R] Small sets cannot distinguish close scores. Compute the needed sample size for the margin you care about, use a paired comparison for two prompt versions, and do not claim an improvement inside the noise.
- [R] Keep prompts as versioned files with a registry of model, settings, evaluation set and score per version, so a prompt-only change is a reviewable diff and rollback is a file change. Do not mandate a specific directory layout or tool.
- [R] Never grade a model with answers produced by the same model without human calibration on the hard cases.
- [S] When an LLM judge is unavoidable, prefer pairwise criteria over vague 1-10 scores, blind candidate identity, swap A/B order to expose position bias, and randomize presentation. Keep deterministic format/evidence/allow-list checks outside the judge and report ties/disagreement rather than forcing a winner. Calibrate each judge/model/rubric version against human-labeled hard cases before using it as a release gate. [E50]
