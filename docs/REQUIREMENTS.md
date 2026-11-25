# Active Requirements (현재 효력이 있는 제품 계약)

규칙: 과거 채팅의 모든 문장을 누적하지 않는다. 사용자가 확정한 **현재 요구사항**만 유지한다.
기능마다 ID, Status, 버전/변경일, 성공 조건, 관련 테스트를 기입한다. 미합의는 Draft다.

## Template
### REQ-001: [기능명]
- Status: Draft | Accepted | Superseded
- Type: Functional | Performance | Availability | Security | Scalability | Operations | Compatibility
- Owner/approved on: [ ]
- Behavior: [사용자 관점의 관찰 가능한 동작]
- Detailed rules and exceptions: [동시성, 중단, 외부 장애, 권한, 경계값, 취소/복구]
- Boundaries: [하지 말아야 할 것]
- Source: [사용자 요청, 회의, 계약, 규정과 날짜]
- Verification method: [측정값, 시험 절차 또는 관찰 가능한 판정]
- Acceptance Criteria:
  - AC-001: Given [context], when [action], then [observable result].
  - AC-002: [오류/빈 결과/권한/모바일 등]
- Tests: [파일/명령/수동 체크, 미작성 상태 표기]
- References: [관련 ADR ID, 외부 계약]
- Change history: [date, request/change ID, before -> after, approver]

모호한 표현인 `빠르게`, `안정적으로`, `사용하기 쉽게`, `대용량`은 숫자, 부하 조건, 사용자 과업 또는 확인 절차가 없으면 Accepted로 만들지 않는다.

## Requirement Traceability Matrix
왼쪽에서 오른쪽으로 누락을 찾고, 오른쪽에서 왼쪽으로 승인되지 않은 범위 확장을 찾는다. 프로젝트 규모에 맞게 파일 경로나 Issue ID만 기록하고 문서를 중복 작성하지 않는다.

| Requirement | Design / ADR / Interface | Implementation | Test / QA evidence | Status |
|---|---|---|---|---|
| REQ-001 | [ ] | [ ] | [ ] | Draft |

판정 규칙:
- Accepted Requirement에 Design, Implementation 또는 Test 연결이 없으면 `Missing`으로 보고한다.
- 어느 Requirement에도 연결되지 않은 구현은 범위 밖인지 확인한다.
- Requirement가 변경되면 연결된 API, Schema, UI, Test와 운영 문서의 영향도 함께 검토한다.

## Unresolved requests
- [정식 승인 전 후보. 구현의 근거로 삼지 않음]

## Change protocol
- 기존 Accepted 항목과 충돌하는 요청이 오면 바로 수정하지 않는다.
- `docs/DECISIONS.md`에 변경 제안의 Before/After, 위험, Migration, Rollback을 적어 보여주고 사용자에게 승인받는다.
- 승인 후에만 Active Requirement와 Tests를 함께 갱신한다.
- 동작을 바꾸지 않는 Internal Refactor도 기존 테스트 통과 및 최소 Diff 확인은 필요하다.

## Open items (아직 정해지지 않은 것)
정해지기 전에는 구현하지 않고 임의로 채우지 않는다. 확정되면 `docs/DECISIONS.md`에 기록하고 이 표의 줄을 지운다.

| 어디(REQ) | 무엇이 정해지지 않았나 | 정해야 하는 시점 |
|---|---|---|
