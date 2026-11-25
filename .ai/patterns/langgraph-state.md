# Pattern: LangGraph State, Routing, Checkpoint
Status: on-demand | Sources: AI Agent PART 4, prior LangGraph studies

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 분기, durable state, pause and resume가 필요한 workflow를 명시적으로 모델링한다. |
| When to Use | Conditional routing, checkpoint, retry, parallel state merge, HITL resume. |
| When Not to Use | Single call 또는 단순 linear sequence에 durability requirement가 없는 경우. |
| Alternatives | Plain functions, finite-state workflow, queue and database state, simpler orchestrator. |
| Implementation Rules | Typed state, node responsibility, reducer, terminal and error paths, stable run identity. |
| Trade-offs | Graph abstraction은 traceability를 높이지만 state and debugging complexity를 추가한다. |
| Security Considerations | Checkpoint data minimization, authorization revalidation, side-effect idempotency를 적용한다. |
| Testing & Acceptance Criteria | Route, resume, replay, merge, timeout, rejection and duplicate-write tests. |
| Resource & Token Cost | Checkpoint storage, node model calls, retries, trace volume를 예산화한다. |
| References | Header Sources; source-derived LangGraph study guidance. |

## Trigger
Conditional edges, durable workflow state, pausing/resuming, retries, or controlled multiple steps are actually needed.

## Design
- Define typed State and each Node's input/output responsibility before building the graph.
- Document State update semantics and Reducers for fields written by concurrent branches. Don't implicitly overwrite shared state.
- Conditional Edges represent explicitly bounded routing; define terminal and error paths.
- Checkpoints enable resumability, not automatically correct business behavior. Select a stable thread/run identifier and avoid storing sensitive raw data unless justified.
- Human approval should pause execution BEFORE the side effect and resume with validated human input; revalidate permission on resume.
- Parallel branches require merge/reducer rules and deterministic conflict handling.
- Prefer few Nodes initially, isolate tool boundary, and trace transitions for debugging.

## Tests
- Branch A/B + unknown inputs land on correct routes.
- State updates survive checkpoint/resume without lost values.
- Replay/retry does not duplicate a write.
- Parallel updates merge as intended.
- Timeout or approval rejection ends safely.

## Decision warning
Do not introduce LangGraph for a single API call or purely linear sequence unless requirements justify durability/branching.
