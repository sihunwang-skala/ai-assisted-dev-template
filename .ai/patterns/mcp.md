# Pattern: MCP for External Tool and Data Integration
Status: optional | Source: recovered AI Agent Capstone/MCP E46 (43 sections), AI Agent E43; verify selected implementation against current official spec

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 여러 client가 재사용할 Tool, Resource, Prompt integration contract를 제공한다. |
| When to Use | Supported clients across runtime boundaries need reusable integration. |
| When Not to Use | Local function이나 ordinary API client가 더 단순하고 충분한 경우. |
| Alternatives | Local function, SDK, REST or event interface. |
| Implementation Rules | Capability scope, versioned schema, server-side auth, timeout, redaction, audit trail. |
| Trade-offs | 표준화 이점 대신 server lifecycle, compatibility, auth complexity가 생긴다. |
| Security Considerations | Read and write privilege separation, runtime authorization, malicious output handling. |
| Testing & Acceptance Criteria | Discovery, schema, denial, timeout, retry, revocation, version mismatch tests. |
| Resource & Token Cost | Server hosting, network latency, tool payload, model selection token 비용을 기록한다. |
| References | Header Sources; course material and current selected spec documentation when implemented. |

## Trigger
Reusable integrations expose Tools/Resources/Prompts across supported clients or runtime boundaries.

## Architecture
- First ask whether a local function/ordinary REST client is simpler. MCP is a standard integration interface, not a reason to create extra Agents.
- Explicitly scope Tools, Resources and Prompts; document who may call each operation.
- Validate tool inputs and enforce authorization on the MCP server/runtime, not just through tool descriptions.
- Separate read-only lookup and write actions. Require approval for consequential side effects.
- Timeouts, limits, output redaction, audit trail, failure handling and versioned contract apply equally to MCP tools.
- Choose transports/auth/session semantics per currently selected deployment and spec version; do not assume every SDK supports every capability.

## Remote operating contract (E46)
- [S] Treat discovery metadata, Tool results, Resources and Prompt content as untrusted inputs. Capability discovery does not imply authorization; enforce user/tenant identity and per-operation policy on every request.
- [S] Define ownership and lifecycle for connections, sessions and any server-side state. Support cancellation/disconnection, bounded progress reporting and durable task IDs only when the selected spec/SDK actually supports them.
- [S] Elicitation or interactive UI cannot collect secrets casually or bypass approval. State exactly what is requested, why, where it is sent and what happens on refusal.
- [S] Isolate tenants, credentials and filesystem/network access. Run risky local tools in a sandbox with explicit roots/egress and keep read operations distinct from consequential writes.
- [R] Use a gateway/hub only when centralized identity, policy, discovery or audit justifies another failure boundary. Record server/client/spec versions, trace IDs, payload size, latency, outcome and redacted audit evidence.
- [R] Deployment needs compatibility tests, canary/rollback, credential revocation and incident disablement. Do not claim support for a course snapshot capability until verified against current official documentation and the selected SDK.

## Verify
Capability discovery, schema compatibility, parameter validation, cross-tenant denial, timeout/cancellation, safe retries, malicious tool/resource output, access revocation, version mismatch, client disconnection and rollback/disablement.

Test at three distinct layers: ordinary Tool function logic and security limits deterministically; protocol discovery/call/lifecycle with a real client/server pair; model Tool selection on a labeled repeated evaluation set. Push checks to the cheapest deterministic layer and do not let a stochastic end-to-end demo substitute for server-side limit, path traversal or sensitive-field tests. [S, E46]
