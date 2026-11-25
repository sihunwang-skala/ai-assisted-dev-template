# Architecture / Product Decision Log

**Append-only history:** 기존 결정을 지우거나 조용히 고치지 않는다. 새 결정이 과거 결정을 대체하면 명시적 연결.

## ADR-000: Decision template
- Status: Proposed | Accepted | Rejected | Superseded
- Date / approver: [ ]
- Context: [문제/제약]
- Decision: [결정과 범위]
- Alternatives: [대안과 Trade-off]
- Consequences: [성능/비용/유지보수/보안]
- Affected requirements / files: [ ]
- Supersedes: [none or ADR-ID]
- Migration / Rollback: [필요한 경우]
- Evidence of approval: [대화/PR/이슈 링크 또는 승인 기록]

## Pending Change Requests
### CR-001: [제안]
- Proposed change: [기존 -> 새 동작]
- Why: [ ]
- Impact: [REQ/BASE/API/DB/UI/security/cost]
- Alternatives: [ ]
- Rollback: [ ]
- **Status: Awaiting user approval**

User approval is not assumed from silence, successful tests, or an agent's opinion.

## Writing rules (added from CBAM practice)
- Write the record before implementing; writing it afterwards justifies the choice instead of weighing it.
- Compare at least two real alternatives and record why the rejected ones were rejected; that reasoning is the value of the record.
- Use one when the choice is hard to reverse: schema shape, AI response schema, library adoption, resolving an open item in the requirements. Not for a column addition, wording or a bug fix.
- Resolving an open item means two edits: add the decision and delete that row from the requirements' open-items list. Doing only one makes the next person reopen it.
- Check the next number on the latest main before branching; parallel branches can pick the same number and git will not flag it.
