# Backend / Server Guide (On demand)

1. 기존 routes/controllers/services/repositories, DB schema, event names, consumers를 먼저 찾는다. 중복 Endpoint 금지.
2. Presentation(API), Domain/Service, Storage/Infrastructure 책임을 필요 수준에서 분리. MVP에 Microservices, CQRS 등을 자동 도입하지 않는다.
3. Request/Response Schema로 입력을 검증하며 Type-safe DTO(Pydantic/TypeScript 등)는 선택한 Stack에 맞춘다.
4. Authorization은 UI가 아닌 Server에서 강제. Object ownership/tenant isolation 확인.
5. DB 변경에는 Migration, Backfill, Compatibility, Rollback을 검토하고 승인 전 파괴적 변경 금지.
6. Side effect에는 필요에 따라 Idempotency Key, Transaction, Concurrency control을 적용.
7. Timeout, bounded retry/backoff, Rate Limit, graceful errors; 에러를 삼키거나 무한 Retry하지 않는다.
8. API 키는 Server-side 환경변수로만 관리, .env.example은 Placeholder만 사용.
9. Contract/Integration Tests와 에러 및 권한 테스트를 우선 추가. 비용을 발생시키는 실 API는 Test Double 사용.
10. 배포 및 외부 시스템 실행은 사용자 승인 전 수행하지 않는다.

## Working in an existing or parallel codebase (from CBAM practice)
- Name a reference module (the most complete existing package) and tell the AI to copy its structure, naming and error handling. Matching an existing convention is faster and safer than a new design.
- With several people or agents in parallel, avoid editing shared hot files (common error enum, shared config). Give each domain its own error codes/exceptions/error response.
- Never duplicate an entity or table mapping that already exists in another module: two entities on one table can stop the application context from starting. Import and reuse.
- If another domain is not merged yet, depend on a small interface (port) with a not-implemented stub, and leave a note saying who replaces it. In tests register a fake implementation of that port for the success path; otherwise the "success" test silently exercises the failure path and still passes.
- Irreversible transitions (confirm, reject, close): if a required input cannot be obtained, block with an explicit error. Do not store a placeholder; a value with no source becomes permanent.
- Do not add checks, uniqueness rules or fields the specification does not state; record any assumption instead (see the report format in `prompts/FEATURE.md`).
- Test setup: wrap integration tests in a rolled-back transaction so data from one test cannot collide with another. If the web-layer test harness is flaky, test the service layer plus at least one real HTTP call against a running instance; check the port is free first. After adding exception handling or API docs, open the generated API docs endpoint once (a global exception advice has broken it in some version combinations).
