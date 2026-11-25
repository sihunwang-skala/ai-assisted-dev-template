# Pattern: ReAct / Bounded Agent Loop
Status: on-demand | Source: AI Agent course PART 2, PART 5, PART 7 (pasted)

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Agent의 반복 Tool loop를 bounded progress와 safe stop으로 제한한다. |
| When to Use | 다음 행동이 observation에 따라 달라지는 iterative tool task. |
| When Not to Use | Ordered predictable task 또는 single tool call. |
| Alternatives | Fixed workflow, conditional router, manual plan and execute. |
| Implementation Rules | Iteration, time, token, money ceilings; no-progress detection; typed observations. |
| Trade-offs | 유연성 대신 nondeterminism, repeated calls, latency and debugging risk가 증가한다. |
| Security Considerations | Authorization and approval은 loop 밖 Runtime에서 강제하고 secrets를 Context에서 제거한다. |
| Testing & Acceptance Criteria | Termination, duplicate loop, deadline, tool failure, unsafe action tests. |
| Resource & Token Cost | Max steps, tokens, wall time, retry and provider cost를 hard budget으로 둔다. |
| References | Header Source; user-pasted AI Agent course material. |

## Trigger
An Agent needs iterative decision -> tool execution -> observation -> new decision.

## Runtime requirements
- Explicit completion, step/iteration limit, wall-clock deadline, token and monetary ceilings.
- Detect repeated identical tool calls, no-progress loops and repeated failures.
- Keep observations compact and typed; don't expose raw tracebacks or secrets in model context.
- Handle tool exceptions at the boundary. Retry only safe, transient failures with limits, backoff and a global deadline.
- Stop with honest partial result or escalation rather than fabricate success.
- Never allow model-side assertions to override authorization, user approval or enforced budgets.

## Design gate
For an ordered and predictable task prefer a fixed Workflow. ReAct is not an unconditional default.

## Tests
- Successful multi-step task terminates.
- Duplicate/repeated steps hit no-progress guard.
- Deadline/budget exhaustion leads to safe stop.
- Tool failure does not silently create side effects or falsely claim completion.
- Unsafe/unknown action is blocked even after multiple model attempts.
