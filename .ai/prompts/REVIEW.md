# Prompt: Independent Diff Review

Repository/branch/commit: [ ]
User-approved scope: [ ]
Requirements/BASE: [ ]
Declared risk: [Low / Medium / High / Critical] - [reason]

현재 코드를 수정하지 않고 우선 검토하라.
- Diff가 사용자 승인 범위를 벗어나는가?
- 기존 REQ/BASE/ADR, 공개 API, Schema, UI Flow, Permissions를 훼손하는가?
- 테스트가 실제로 실행되었는가? 실패/누락이 있는가?
- Security/Privacy/Cost/Dependency/License 위험은?
- 구현된 기능과 보고된 기능이 일치하는가?
- 공유 Return Shape, 저장값 의미, 외부 노출 필드의 Consumer와 호환성이 확인되었는가?
- Critical Boundary에 필요한 Idempotency, Retry, Reconciliation, Rollback, Observability가 실제로 검증되었는가?

결과는 `Blocker / Major / Minor`와 파일 위치/증거/수정 방향으로 정리.
각 지적은 `파일:줄` 또는 실행 출력을 근거로 인용한다. 근거 없는 의심은 `추정`, 확인하지 못한 항목은 `확인 불가`로 따로 적고 통과로 처리하지 않는다.
승인이 필요한 항목과 즉시 수정 가능한 항목을 분리하고, 필요 시 다음 Claude/Codex Prompt를 작성하라.

## Review depth by risk
| Risk | Required review |
|---|---|
| Low | 작성자의 Diff Review와 관련 확인만 수행한다. 독립 Agent를 기본 실행하지 않는다. |
| Medium | 관련 Pattern과 기존 코드 비교, Targeted Test, 영향받는 Regression을 확인한다. |
| High | 작성자와 분리된 Independent Review, 관련 Test Suite, Contract와 Security 영향을 확인한다. |
| Critical | 사용자 승인, Independent Security/Correctness Review, 가능한 Staging 또는 Preview, Rollback/Reconciliation 계획을 확인한다. |

Risk는 변경된 파일 수가 아니라 실패 시 영향, 복구 가능성, 외부 Contract와 데이터 노출을 기준으로 판정한다.

## Review procedure for a pull request (added from CBAM practice)
1. Read the PR body and diff. 2. Only for Medium or higher risk (or when the diff alone cannot settle a claim): fetch the head into a separate worktree, build and run it; remove the worktree afterwards. For Low risk, a diff read plus the existing test results is enough; do not spend a run on it. A diff-only review yields "this could happen", which is speculation, not a finding. 3. Compare with the requirement, the repository conventions and `AGENTS.md`. 4. Exercise the blocking case of each "only if" condition and paste the real response. 5. If it could not be run, write "could not run" in the review; never leave it blank or imply it was checked.
- Label each finding: must fix before merge / may split into a separate issue / trivial. Unlabeled findings read as equal weight and none gets fixed.
- The agent comments only. Approve, merge and close are human actions.
