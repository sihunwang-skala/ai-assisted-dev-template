# Repository Instructions (AI Coding Agents)

## Priority
1. 최신 사용자 요청을 확인한다. 확정된 요구사항/승인 기록은 `docs/REQUIREMENTS.md`, `docs/DECISIONS.md`, `docs/BASELINE.md`에 있다.
2. 충돌이 생기면 **임의로 기존 결정을 덮어쓰지 않는다**. 변경안을 제안하고 사용자에게 명시적 승인을 요청한다.
3. 프로젝트의 현재 구현/테스트를 관찰한 사실과 추측을 구분한다. 문서와 코드가 다르면 보고한다.

## Mandatory Selective Context Loading
- 작업 시작 시 `AGENTS.md`, 최신 사용자 요청, `docs/PROJECT.md`에서 현재 작업에 필요한 부분만 읽는다. 보호된 결정 확인이 필요할 때만 관련 `REQUIREMENTS`, `DECISIONS`, `BASELINE`, `ARCHITECTURE`, API/Schema/Security 문서를 추가로 연다.
- `.ai/ROUTER.md`를 인덱스로 사용해 현재 기술과 작업에 맞는 Guide와 Pattern만 선택한다. 전체 Repository, 전체 전자책, 모든 Markdown, 과거 대화 전체를 기본 Context로 읽지 않는다.
- 기존 코드 수정은 관련 파일, 인접 호출부, 관련 테스트, 현재 Diff를 우선 확인한다. 영향 분석에 필요한 주변 코드만 단계적으로 확장한다.
- 같은 파일이나 검색을 반복하지 않는다. 파일이 변경됐거나 필요한 내용이 누락된 경우에만 다시 읽는다.
- 간단한 작업에 Multi-Agent, Subagent, 장시간 Planning, 다수 모델 호출을 사용하지 않는다. 복잡도와 독립 병렬 작업의 실질적 이점이 있을 때만 제안한다.
- Context 압축이나 Handoff 시 확정 Requirements/Decisions, 미완료 작업, 변경 파일, 승인 대기 항목, 실제 검증 상태를 보존한다.
- Token 절약을 이유로 필수 Security Check, Contract Test, Regression Test 또는 Diff Review를 생략하지 않는다.

## Before editing
- 위 Selective Context Loading 순서로 요청에 관련된 파일만 읽고 필요한 Guide는 `.ai/ROUTER.md`로 찾는다.
- 기존 구현, 중복 모듈, 의존 API/DB/UI/테스트를 파악하고 수정 범위를 최소화한다.
- 변경이 승인된 기능, 공개 API, DB Schema, Permissions, 개인정보 처리, UX Policy, Security Policy, 비용, Architecture에 영향을 준다면 **중단 후 승인 요청**.
- 새로운 유료 서비스, 외부 데이터 전송, 추가 비용, 또는 기존 설계와 충돌하는 Framework/Pattern 도입은 구현 전에 승인받는다.
- 승인 범위 밖의 삭제, 리팩터링, 대규모 라이브러리 교체, 외부 발송/결제/배포를 하지 않는다.

## Verifiable change guards
- 공유 Service/Repository 함수, API Response, Event 또는 Tool Output의 형태를 바꾸기 전에 `rg` 등으로 모든 Consumer를 검색하고 UI, Public API, MCP/Tool, Workflow, Webhook 영향을 기록한다. Consumer를 확인할 수 없으면 변경을 중단하고 미확인 위험으로 보고한다.
- 저장된 값의 의미, 형식, 단위, Null 처리 또는 상태 전이를 조용히 바꾸지 않는다. 변경이 필요하면 호환성 또는 Migration 계획, 승인, 관련 테스트를 먼저 확보한다.
- 기존 저장 필드를 Public API, MCP/Tool, Webhook 또는 외부 응답에 새로 노출하는 것은 Data Exposure 변경이다. 기존 데이터의 민감도와 실제 저장값을 확인하고 승인받는다.
- Payment, Webhook, Authentication, Credentials, Migration, Public API, 외부 Write 같은 Critical Boundary는 해당되는 경우 Idempotency, Atomic 또는 Durable State, Retry, Reconciliation, Observability, Rollback을 설계하고 검증한다.
- Incident 또는 Escaped Defect 수정에는 가능한 한 최소 재현과 Regression Test를 추가한다. 반복 가능하거나 영향이 큰 실패만 공통 규칙 또는 자동 Gate 후보로 승격한다.
- 규칙은 가능한 한 통과 또는 실패를 판정할 수 있게 작성하고 `docs/ENFORCEMENT_MATRIX.md`에 Enforcement와 Evidence를 연결한다. 자동화되지 않은 규칙은 자동 검증된 것처럼 보고하지 않는다.

## Implement & verify
- Requirement 확인 -> Impact Analysis -> 최소 변경 -> 관련 테스트 -> Regression 검증 -> Diff Review -> 변경 보고 순서를 따른다.
- 하나의 작은 Vertical Slice씩 진행하고 기존 동작을 유지한다.
- 가능한 테스트를 변경 전후 실행한다. 버그 수정에는 재발 방지 테스트를 추가한다.
- `git diff`에서 무관한 변경, 비밀정보, 예상치 못한 파일 삭제를 확인한다.
- 변경 Risk를 Low / Medium / High / Critical로 분류하고 `docs/TEST_PLAN.md`의 재현 가능한 QA 절차와 Evidence를 남긴다.
- 검증하지 않은 상태를 '성공'으로 보고하지 않는다. 사용자 승인 전 `main` merge/push, force push, destructive commands 금지.

## Context & cost
- 호출 횟수만이 아니라 재작업, 실패, 검증을 포함한 전체 작업 완료 비용을 최적화한다.
- 캐싱은 현재 Agent/API 환경에서 실제 지원되고 유효성이 확인된 경우에만 사용한다.
- 응답은 변경 파일, 검증 결과, 위험, 승인 필요 항목 중심으로 짧게 쓴다.

## Completion
변경 요약 | 바뀐 파일 | 관련 Requirement ID | Test(실행/미실행) | Diff 위험 | 다음 단계 | Commit ID(있을 때).

## Opt-in patterns from past e-books
- If the task specifically calls for a known pattern, consult `.ai/PATTERN_CATALOG.md` and only the relevant file. Never ingest the whole knowledge library as default context.
- Optional advanced architecture (Multi-Agent, RAG/Agentic RAG, new MCP, provider/cost changes) must first be compared with the existing simpler baseline; propose, do not silently install.
- Pattern content is not a new user requirement and cannot override approved project decisions.
