# Pattern: Spring Boot API and Module Integrity
Status: optional | Sources: Spring Boot Backend recovered full text E49 (47 sections), Java 54-section curriculum E11

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Spring Boot API, module, transaction, authorization 계약을 보존한다. |
| When to Use | Spring Controller, Service, Repository, DTO, JPA, MyBatis 변경. |
| When Not to Use | 비 Spring 프로젝트 또는 단순 정적 UI 변경. |
| Alternatives | 현재 프로젝트 구조, modular monolith, framework-native conventions. |
| Implementation Rules | Stable DTO, validation, service transaction boundary, resource authorization. |
| Trade-offs | 계층 분리는 명확성을 높이지만 class count와 indirection을 늘릴 수 있다. |
| Security Considerations | JWT 검증 외에 resource and tenant authorization을 domain layer에서 시행한다. |
| Testing & Acceptance Criteria | Unit, web layer, transaction rollback, contract, permission tests. |
| Resource & Token Cost | 일반적으로 model token 비용은 없으며 build and integration test 시간이 증가한다. |
| References | Header Sources; curriculum-derived guidance, not a verified full textbook. |

## Trigger
Java Spring Boot controller/service/repository, JPA, MyBatis, DTO, auth or transaction changes.

## Service boundary
- Prefer clear Controller -> Service -> Repository responsibilities; use constructor injection and stateless singleton beans. A circular dependency is a design signal—split responsibility or publish an event rather than hiding it with lazy injection.
- Define request/response DTO and validation/exception contract; never expose persistence entities as the public contract. Keep HTTP status and error fields consistent, document success and failure, and preserve compatibility when evolving them.
- Never alter public API payloads, paths, auth scope or database schema without impact analysis and explicit approval.
- Keep transaction boundaries on public service methods. Verify proxy semantics: self-invocation/private/final methods bypass advice, checked exceptions do not roll back by default, and swallowed exceptions may commit. Inspect retry/idempotency for network-exposed actions.
- For JPA, default associations to deliberate lazy loading, inspect generated SQL, and count queries on important list endpoints. Fix N+1 with a measured fetch join/entity graph/batch/projection choice; collection fetch joins plus pagination can load excessive rows. For complex read/report SQL, MyBatis or explicit projections may be clearer, but parameters remain bound and transactions remain owned by the service.
- JWT is signed, not encrypted: keep sensitive data out of claims; verify algorithm, signature, issuer/audience and expiry. Token storage is a threat-model choice—browser-readable storage increases XSS exposure, cookies require HttpOnly/Secure/SameSite and CSRF controls. Authentication is not authorization: enforce resource/tenant ownership in domain logic and make refresh revocation/logout testable.

## Configuration and diagnostics (E49)
- [S] Project-selected Java/Spring/dependency versions and generated build files are authoritative. Separate local/test/production profiles, inject secrets externally, and fail startup when required configuration is missing; never copy course version numbers blindly.
- [S] For startup/wiring failures read the first root `Caused by`, condition/auto-configuration report and active profile before changing dependencies. Do not log secrets or enable SQL bind-value tracing in production.
- [S] AOP/proxy behavior is part of correctness. Add a regression test when a transaction, authorization or other advice boundary fixes an escaped defect.

## Testing
Use the smallest test that proves the boundary: plain unit test for business logic, web slice for mapping/validation/serialization, data slice for queries/mappings, full integration only for wiring, and a real database container when dialect/index behavior matters. Cover role/tenant denial, transaction rollback (including proxy/exception cases), query-count regression, contract compatibility, invalid DTO, duplicate requests and refresh/logout. Do not make every test a full application test.

## Change discipline
Respect project-selected Java/Spring versions; don't upgrade from book references without authorization.

## Transaction pitfall found by running the real server (CBAM)
- [R] If a method saves a failure record and then throws, a rollback-on-exception transaction rolls the failure record back too: the call correctly returns an error but the history shows nothing. Use `noRollbackFor` for that exception or write the record in a separate transaction, and verify by calling the real endpoint and reading the history back. Also map invalid request parameters to 400, not 500, and check each end-to-end failure path once with a real request.
