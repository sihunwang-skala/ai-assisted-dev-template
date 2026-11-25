# User Approval Policy (Template-level)

## Changes requiring explicit consent BEFORE editing
- Alter approved feature behavior, product requirements, user-facing UX policy, Design System or accepted Architecture.
- Add/delete Agent topology, external paid API, long-running job, database schema/data migration, auth permissions, public API contract.
- Send project or user data to a new external service, introduce additional monetary cost, or adopt a Framework/Pattern that conflicts with an accepted design.
- Delete existing functionality, release to production, send messages, pay, purchase, publish, remove data, overwrite history or run destructive commands.
- Install Git Hooks/`core.hooksPath`, add CI workflows, change branch rules/Rulesets, or rewrite Git history (예: Secret Scan kit 설치, `git-filter-repo`, 강제 Push).
- Modify dependency/runtime versions or resource budgets beyond the project's accepted limits.

## The user's own request counts as approval
- 사용자의 현재 요청이 특정 변경(대상과 계약이 명확한 API/스키마/권한/비용/외부 행동)을 직접 지시했다면 그 요청이 승인이다. 같은 변경에 대해 다시 승인을 묻지 않는다.
- 재승인은 (a) 요청이 모호해 변경 범위를 특정할 수 없을 때, (b) 요청에 없던 파급(다른 Consumer 깨짐, 비용 증가, 민감 데이터 노출, 파괴적 작업)이 구현 중 새로 드러났을 때, (c) 요청 범위를 넘는 추가 변경이 필요할 때만 한다.
- 승인은 해당 요청 범위에만 유효하다. 다른 작업, 세션, 파일, 대상으로 일반화하지 않는다.

## Small tasks not requiring new approval by default
- Narrow implementation details already inside accepted feature scope, non-breaking local refactoring and safe formatting with test coverage.
- Isolated test addition, deterministic error message typo fix (subject to UI contract) or local code cleanup that does not change behavior.
- Approved scope 안의 버그 수정과 내부 구현 개선. 단, Contract, Security Policy, 비용, 외부 데이터 흐름은 바꾸지 않는다.

## Proposal template
- Current behavior and linked Requirement ID
- Suggested behavior and why now
- Alternative: keep existing architecture
- Files/contracts/risks/rollback and measurable value
- Advantages, disadvantages, direct/operational cost and affected features
- What exact approval is requested

## Decision state
`proposed` is not `approved`; `approved` is not `executed`; `executed` is not `verified`.
After approval, update project REQUIREMENTS/DECISIONS and test criteria. When accepting an optional new pattern, activate only that pattern for the affected feature.
