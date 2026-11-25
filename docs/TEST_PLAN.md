# Quality and Verification Plan

## Required minimum (Hackathon)
- 핵심 Demo path 1개 End-to-end 또는 수동 Smoke Test.
- 영향받는 기존 BASE/REQ의 Regression 확인.
- 변경 파일에 관련된 Unit / Integration Tests (가능할 때).
- UI는 모바일/데스크톱 핵심 화면, 데이터는 경계값/에러 확인.
- 권한이나 외부 행동은 승인 전 실행되지 않는지 검증.

## Product mode extension
- CI on Pull Request, lint/typecheck/test/build, migration/rollback 검증.
- Contract Tests, permission tests, E2E, accessibility, security scan, monitoring.
- Test isolation and deterministic fixtures. 외부 유료 API는 기본적으로 Mock.

## Test control criteria
프로젝트 규모에 맞게 필요한 항목만 채우되, Product release 또는 외부 Demo 전에는 시작과 종료 판정 기준을 명시한다.

### Entry Criteria
- [ ] 대상 Requirement와 Acceptance Criteria가 승인되었다.
- [ ] Test Environment, Fixture, Account/Role과 필요한 Mock이 준비되었다.
- [ ] 대상 Build와 Unit Test 상태가 식별되었다.
- [ ] 외부 연계가 있다면 Test Environment 또는 대체 검증 방법이 준비되었다.

### Suspension Criteria
- [ ] 주요 흐름을 막는 결함 때문에 후속 결과를 신뢰할 수 없다.
- [ ] 잘못된 Build, Fixture 또는 장시간 환경 장애가 발견되었다.
- [ ] Security 또는 Data Integrity 위험이 확인되어 추가 실행이 안전하지 않다.

### Resumption Criteria
- [ ] 중단 원인이 해결되었고 Smoke Test가 통과했다.
- [ ] 중단 이후 신뢰할 수 없는 Test 범위가 식별되어 다시 실행되었다.

### Exit Criteria
- [ ] 계획한 Test와 QA가 실행되었거나 미실행 위험이 승인되었다.
- [ ] 합의한 Severity 이상의 미해결 결함이 없다.
- [ ] 영향받는 Regression과 Requirement Traceability가 확인되었다.
- [ ] High/Critical 변경은 필요한 Review, Rollback 또는 Reconciliation Evidence가 있다.

## Traceability
| Requirement / Baseline | Test path or exact manual procedure | Last result | Evidence |
|---|---|---|---|
| REQ-001 / BASE-001 | [unwritten] | Not run | - |

## Executable QA procedure
코드 변경마다 아래 형식을 복사한다. Reviewer가 작성자에게 추가 설명을 묻지 않고 같은 결과를 재현할 수 있어야 한다.

**Change ID:** [ ]  
**Risk:** [Low / Medium / High / Critical] - [reason]  
**Preconditions:** [environment, fixtures, account/role, feature flags]  

1. [ ] [setup or navigation]
2. [ ] [exact action, command, input]
3. [ ] [observable verification]

**Expected Result:** [ ]  
**Actual Result:** [Pass / Fail / Not run] - [observed result]  
**Regression Scope:** [related BASE/REQ and unchanged behavior checked]  
**Evidence:** [command log, screenshot, test report, artifact path]  
**Not Tested:** [reason, affected risk, follow-up owner or condition]

Rules:
- "Works" 또는 "checked"만 쓰지 말고 명령, 입력, 화면 이동, 관찰값을 구체적으로 적는다.
- 변경된 경로를 검증하지 못했다면 `Not run`으로 기록한다. 추정 결과를 Pass로 바꾸지 않는다.
- 외부 Side Effect는 안전한 Sandbox, Mock, Preview가 없으면 실행하지 않고 미검증 위험과 승인 필요 여부를 보고한다.
- High/Critical 변경은 Independent Review 결과와 실패 시 복구 또는 Reconciliation 절차를 Evidence에 연결한다.

## Reporting format
- Commands executed: [ ]
- Passed / failed / skipped: [ ]
- Unverified risks: [ ]
- Screens / artifacts (if available): [ ]
- CI status: not configured until stack is chosen.

금지: 테스트하지 않은 코드를 '검증 완료'라고 주장하거나 테스트가 없는 항목을 자동 합격 처리.
