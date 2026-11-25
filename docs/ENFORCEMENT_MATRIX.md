# Rule Enforcement and Evidence Matrix

## Purpose
`AGENTS.md`의 자연어 규칙만으로 준수를 보장할 수 없다. 이 문서는 중요한 규칙을 판정 가능한 Check, Evidence, Failure Behavior에 연결한다. 실제 Stack이 정해지기 전에는 CI, Hook, Staging이 구성되었다고 가정하지 않는다.

우선순위는 다음과 같다.

1. 승인된 Requirements, Decisions, Baseline과 사용자 승인
2. 결정론적 Test, Type Check, Lint, Schema/Contract Check, Security Scan
3. Independent Review와 수동 QA Evidence
4. Agent 지침

## Risk classification
| Risk | Typical scope | Minimum evidence |
|---|---|---|
| Low | 문서, 주석, 격리된 비동작 변경 | Self Diff Review, 관련 확인 |
| Medium | 되돌릴 수 있는 내부 구현 변경 | Targeted Test, 영향받는 Regression, QA 절차 |
| High | API/Schema/Security/외부 노출/다수 Consumer | 승인 필요성 판정, Independent Review, Contract 또는 관련 Test Suite |
| Critical | 결제, 자격 증명, 파괴적 작업, Production Migration, 복구 어려운 외부 Write | 명시적 승인, Independent Security/Correctness Review, 가능한 Staging/Preview, Rollback 또는 Reconciliation Evidence |

## Critical path inventory
프로젝트 시작 시 실제로 존재하는 항목만 등록한다.

| Boundary | Path or component | Owner | Verification | Rollback or reconciliation | Status |
|---|---|---|---|---|---|
| Payment/Webhook | [not selected] | [ ] | [ ] | [ ] | Not configured |
| Authentication/Credentials | [not selected] (Secret scan: pre-push + Actions + Ruleset) | [ ] | `test-local.sh`, Actions run | 키 폐기/재발급, 이력 정리 | Not configured |
| Database Migration | [not selected] | [ ] | [ ] | [ ] | Not configured |
| Public API/MCP/Tool | [not selected] | [ ] | [ ] | [ ] | Not configured |
| External Write/Deploy | [not selected] | [ ] | [ ] | [ ] | Not configured |

## Default enforcement matrix
| Rule | Risk | Enforcement option | Required evidence | Failure behavior | Template status |
|---|---|---|---|---|---|
| Secret 파일 접근 또는 Credential 노출 금지 | Critical | Agent permission, Hook, Secret Scan (kit: `.ai/kits/secret-scan/`) | Denial log, `test-local.sh` 결과, Actions 실행 기록, Ruleset 필수 검사 | Block | Kit available, not installed |
| 공유 Return Shape 변경 전 모든 Consumer 확인 | High | Consumer search, Contract Test | Consumer list, test result | Unknown consumer면 중단 | Manual until stack selected |
| 저장값 의미/형식/단위/Null 처리 변경 금지 | Critical | Migration plan, Compatibility Test, approval | 승인 ID, migration/rollback test | Block | Manual |
| 저장 필드의 새 외부 노출 금지 | High | Data Exposure Review, response/permission test | 승인 ID, inspected data, test result | Block | Manual |
| 번호형 QA와 실제 결과 기록 | Medium | Completion check, CI artifact when available | `docs/TEST_PLAN.md` 절차와 결과 | 완료로 보고하지 않음 | Documentation gate |
| Build, Lint, Type Check, Test 통과 | Stack-dependent | Local command, CI required check | Command 또는 CI log | 구성된 경우 Block | Not configured |
| Critical Side Effect의 중복/부분 실패 방지 | Critical | Idempotency, Transaction/Durable Event, Retry/Reconciliation Test | Test log, operation receipt, recovery evidence | Block | Manual until implemented |
| Incident 재발 방지 | Medium or higher | Characterization/Regression Test | 실패 재현과 통과 결과 | 미검증 위험 보고 | Manual |

## Adoption rules
- Stack과 배포 환경을 선택한 뒤 실제 명령과 Gate를 채운다. 존재하지 않는 CI, Hook, Staging을 문서만으로 활성화된 것처럼 표시하지 않는다.
- 모든 규칙을 자동화할 필요는 없다. 빈도, 영향, 복구 비용이 큰 실패부터 deterministic enforcement로 이동한다.
- GitHub 사용은 필수가 아니다. Local Script, 다른 CI, Agent Hook, 수동 승인과 Evidence도 사용할 수 있다.
- 기존 프로젝트에 적용할 때는 현재 Gate와 충돌을 비교하고 승인된 항목만 병합한다.
