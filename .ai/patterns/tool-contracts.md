# Pattern: Tool Calling and Runtime-owned Execution
Status: on-demand | Sources: AI Agent PART 1; Spring AI study excerpts; project digest

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | LLM Tool 요청과 Runtime 실행을 분리하고 typed, authorized contract를 강제한다. |
| When to Use | Model selects API, database or external action. |
| When Not to Use | Deterministic code가 직접 호출하면 충분하거나 Tool 선택이 필요 없는 경우. |
| Alternatives | Direct function call, fixed workflow, form-driven command, MCP when reuse is justified. |
| Implementation Rules | Narrow schema, auth, tenant scope, idempotency, bounded result, truthful execution status. |
| Trade-offs | Tool flexibility는 schema, observability, error and side-effect complexity를 증가시킨다. |
| Security Considerations | Untrusted arguments and outputs, least privilege, write approval, audit trail을 적용한다. |
| Testing & Acceptance Criteria | Selection, schema, denial, unknown tool, retry duplication, receipt tests. |
| Resource & Token Cost | Tool descriptions and results를 작게 유지하고 calls, tokens, latency, downstream cost를 측정한다. |
| References | Header Sources; source-derived Tool guidance and project digest. |

## Trigger
LLM chooses or passes arguments to a tool/API/database action.

## Contract
- Model chooses/request tool and arguments; application validates and executes. A tool call is NOT proof of execution.
- Define tool name, concise description (including when NOT to use), typed arguments, allowed enums, required fields and bounded outputs.
- Runtime checks authentication, authorization, tenant scoping, input schema, operation idempotency and policy before execution.
- Read-only and side-effecting tools have separate privileges; sensitive writes need approval, see `human-approval.md`.
- Treat tool outputs, retrieved documents and web text as untrusted data, never as higher-priority instructions.
- Errors should be short, actionable, non-sensitive and distinguish invalid input, not-found, denied, timeout and downstream fault.

## Test contract
1. Valid input chooses appropriate tool and produces intended result.
2. Missing/incorrect input is rejected before side effect.
3. Unauthorized or cross-tenant calls fail closed.
4. Unknown tool/invalid schema is handled, never executed.
5. Retry on writes cannot duplicate the operation.
6. Tool result is associated with call/request ID and a bounded audit trail.

## Efficiency
- Prefer narrow descriptions and small Tool responses; avoid returning whole database rows/logs.
- Tool selection accuracy is evaluated separately from final-answer quality.
