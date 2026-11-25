# Pattern: Requirement Traceability and Decision Preservation
Status: always conceptually; read when requirements, architecture, release or handoff changes
Sources: E08 Project Methodology & Deliverables, full 40-section user-provided text reviewed 2026-11-09; E16 Agile, full 24-section user-provided text reviewed 2026-11-10; established collaboration workflow

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Requirements, Decisions, Baseline, implementation, test evidence, release and handoff의 연결을 보존한다. |
| When to Use | Requirement, architecture, contract, policy, baseline, release 또는 운영 절차를 변경할 때. |
| When Not to Use | 동작과 결정에 영향 없는 일회성 설명이나 탐색. 제출용 분량만 늘리는 문서에는 사용하지 않는다. |
| Alternatives | Issue tracker, ADR, executable specification, generated API/schema docs, concise current-state record. |
| Implementation Rules | Before/after, source, verification method, affected contracts, approval, bidirectional traceability and test/release evidence. |
| Trade-offs | 유지 비용이 생기지만 omission, decision loss, unauthorized scope와 handoff failure를 줄인다. |
| Security Considerations | Security/privacy 요구사항, 외부 반출, 권한, 보관/파기 결정을 설계와 Test에 연결한다. Secret 자체는 문서화하지 않는다. |
| Testing & Acceptance Criteria | 각 Accepted Requirement가 design, implementation, verified test evidence로 연결되고 역방향 범위 확인도 통과한다. |
| Resource & Token Cost | ID와 변경된 행만 갱신한다. 전체 문서를 매 작업 Context에 적재하지 않는다. 자동 생성은 Stack 선택 후 도입한다. |
| References | Source-derived: E08 full 40-section text, reviewed 2026-11-09, and E16 full 24-section text, reviewed 2026-11-10. Engineering recommendations are labeled below. |

## Single source of truth
- `docs/REQUIREMENTS.md`: approved current desired behavior and acceptance criteria.
- `docs/DECISIONS.md`: why choices were made, alternatives, superseded decisions (never silently erase rationale).
- `docs/BASELINE.md`: verified existing behavior, code links, tests and known limitations.
- `docs/CURRENT_STATE.md`: last verified status only; never promote speculation to completion.

## Source-derived rules
- 방법론은 단계 이름보다 가장 큰 불확실성을 언제 확인할지로 선택한다. Requirement가 불확실하면 짧은 Review Cycle, 기술이 불확실하면 Walking Skeleton, 일정이 불확실하면 조절 가능한 Scope를 우선한다.
- 산출물은 결정, 연결 또는 인수인계를 보호해야 한다. 무엇을 보호하는지 설명할 수 없는 문서는 축소 후보다.
- Requirement에는 기능/비기능 구분, 출처, 확인 방법, 예외, 변경 이력을 둔다. 확인 불가능한 표현은 승인된 Requirement로 취급하지 않는다.
- Traceability는 Requirement -> Design -> Implementation -> Test를 양방향으로 확인한다. 빈칸은 누락 후보이고 Requirement 없는 구현은 Scope Expansion 후보다.
- ADR은 선택지, 결정, 근거, 감수하는 점, 재검토 조건을 남긴다. 과거 ADR을 고치지 않고 새 ADR이 이전 결정을 Supersede한다.
- 화면은 Normal뿐 아니라 Empty, Loading, Error, Permission, Partial Failure 상태를 정의한다.
- Test Plan에는 Entry, Suspension, Resumption, Exit Criteria를 둔다. 결함에는 환경, 재현 절차, Expected/Actual, 빈도와 영향을 기록한다.
- Release/Migration은 시각별 절차, 확인값, Rollback Decision Time, Decision Owner, 실제 리허설 시간을 포함한다.
- 운영 Handoff는 장애 증상, 첫 확인, 대응, Escalation, Batch 재실행의 Idempotency를 중심으로 작성한다.
- 코드에서 생성할 수 있는 API/Schema/Test Report는 생성과 Drift Detection을 우선한다. ADR과 회의 기록은 Append-only History로 유지한다.
- Agile 적용 여부는 유행이나 Ceremony가 아니라 불확실성과 Feedback 지연으로 결정한다. Requirement와 사용자 반응의 불확실성이 높을수록 작동하는 작은 Increment를 더 빨리 검증한다.
- Timebox는 날짜를 고정하고 Scope를 조절하는 학습 단위다. 기간 중 새 작업을 무제한 추가하지 않고, 긴급 변경은 명시적으로 우선순위와 교환한다.
- Backlog에는 명확한 우선순위와 단일 책임 Owner를 둔다. 사용자 Story는 사용자, 목표, 가치와 Acceptance Criteria가 확인될 만큼만 구체화한다.
- Definition of Done은 Review 가능한 Increment의 공통 품질 계약이다. 자동 검증 가능한 항목은 실제 Test 또는 Gate와 연결하고, 단순히 작업 상태를 `Done`으로 옮긴 것을 완료로 보지 않는다.
- WIP를 제한하고 Lead Time, Cycle Time, Throughput, Blocked Time을 관찰한다. 개인 생산성 순위를 만들기보다 Flow의 병목과 대기 시간을 찾는 데 사용한다.
- Retrospective는 비난이나 감상으로 끝내지 않는다. 다음 주기에 실행할 소수의 개선 항목마다 Owner, Due Date, Verification Method를 두고 다음 회고에서 효과를 확인한다.

## Engineering recommendations
- Hackathon은 Project Charter, 핵심 Requirements, RTM, ADR, Test Evidence만으로 시작하고 실제 Risk가 생길 때 문서를 확장한다.
- Product는 Critical Boundary, 외부 Interface, Migration, Release/Handoff 문서를 Risk에 비례해 추가한다.
- 특정 Git platform, CI, Coverage 비율, Branch Model은 이 Pattern이 강제하지 않는다. 프로젝트 Stack과 운영 조건에 맞춰 선택한다.
- Scrum, Kanban, XP, Sprint 길이와 회의 형식은 강제하지 않는다. 불확실성이 낮고 변경 비용이 매우 높은 작업은 계획 중심 방식이 더 적합할 수 있다.
- Metric은 학습과 Flow 개선에 사용한다. Velocity나 Story Point를 사람 간 성과 비교 또는 목표 할당에 사용하면 Gaming을 유발할 수 있다.

## Change request
1. Link proposed change to one or more Requirement IDs.
2. List before/after behavior and impacted UI/API/DB/permissions/cost.
3. Separate bug fix preserving contract from product-policy changes.
4. Ask for explicit approval of incompatible behavior, public contract, data migration, design system or architecture changes.
5. Once approved, update spec and tests, implement on bounded branch, verify and record decision/status.

## Minimal traceability procedure
1. Accepted Requirement마다 Source와 Verification Method를 확인한다.
2. RTM의 Design, Implementation, Test 칸을 실제 ID나 경로로 연결한다.
3. 왼쪽에서 오른쪽으로 누락을 찾는다.
4. 오른쪽에서 왼쪽으로 승인되지 않은 구현을 찾는다.
5. 변경된 Requirement의 연결 항목만 Regression 범위로 확장한다.

## Acceptance
Requirement -> design/decision -> implementation -> test evidence -> reviewer decision. Missing evidence is not a pass. Unlinked implementation is not automatically approved scope.

Agile 운영을 선택했다면 Increment의 Feedback 시점, 현재 WIP, Done 기준, Blocker, 다음 개선 Action을 확인할 수 있어야 한다. Ceremony를 수행했다는 사실만으로 통과하지 않는다.

## Correction notes (from CBAM practice)
- [R] When the source specification cannot be edited, keep a short correction/reconciliation note next to the code, and state in it the condition for deleting it (for example, "delete when the source is fixed"). A correction note that outlives the source becomes the stale side. When the original and the note disagree, the original wins; say so in the note.
