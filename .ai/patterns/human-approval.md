# Pattern: Human-in-the-Loop Approval and Action Receipt
Status: optional | Approval: REQUIRED for creating automation of side effects
Sources: AI Agent/Harness pasted materials, user-approved HITL design discussion

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 중대한 외부 행동 전에 사용자 승인과 실행 증거를 분리해 보존한다. |
| When to Use | Payment, message, delete, publish, access grant, third-party write. |
| When Not to Use | Read-only lookup 또는 이미 구체적으로 승인된 reversible low-risk operation. |
| Alternatives | Manual execution, preview-only mode, scoped standing authorization with revocation. |
| Implementation Rules | Preview, explicit decision, payload integrity, revalidation, idempotency, receipt. |
| Trade-offs | Human latency와 UX friction이 생기지만 잘못된 side effect를 제한한다. |
| Security Considerations | Identity, role, approval scope, expiry, replay protection을 실행 직전에 검증한다. |
| Testing & Acceptance Criteria | Denied, edited, expired, replay, timeout, double-submit, unauthorized tests. |
| Resource & Token Cost | Approval storage와 audit 비용이 있으며 추가 model call은 필수가 아니다. |
| References | Header Sources; source-derived and user-approved HITL design discussion. |

## When mandatory
Actions that spend money, send emails/messages, modify third-party systems, delete data, publish/deploy, grant access, or trigger irreversible customer-visible consequences without prior scoped authorization.

## Execution protocol
1. Prepare a preview with target, action, exact payload/amount, identity, risks and expiry.
2. Show user meaningful approve/reject/edit choice. Absence of approval is rejection for that operation.
3. Runtime verifies identity, role, approval scope, payload hash/version and freshness immediately before execution.
4. Execute exactly once where practical with idempotency key; log success/failure distinctly from approval granted.
5. Produce durable receipt: request ID, actor, approved payload fingerprint, decision, execution status, time and downstream confirmation ID where available.

## Tests
Approved valid payload, denied, edited-after-approval, expired, replayed, network timeout after uncertain execution, unauthorized tenant, revoked permission, double-click approval.

## Don't
- Approval of a plan is NOT blanket permission for unrelated later actions.
- Never call a dry run 'completed action'.
