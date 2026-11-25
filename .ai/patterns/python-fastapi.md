# Pattern: Python / FastAPI Service Discipline
Status: optional | Sources: FastAPI full text E19; Python recovered full text E55; prior API discussions

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Python, FastAPI, Pydantic boundary와 async, DB, side-effect 계약을 안정적으로 유지한다. |
| When to Use | Python service, API, pipeline, CLI, schema work. |
| When Not to Use | Python이 아닌 프로젝트 또는 framework 선택 전. |
| Alternatives | Plain Python module, existing framework conventions, synchronous worker, other approved API stack. |
| Implementation Rules | Pinned runtime, typed boundaries, domain separation, explicit async and transaction handling. |
| Trade-offs | Type and validation discipline은 code를 늘리지만 runtime ambiguity를 줄인다. |
| Security Considerations | Parameterized query, secret isolation, auth and tenant checks, logging redaction. |
| Testing & Acceptance Criteria | Schema, status, permission, DB failure, timeout, compatibility tests. |
| Resource & Token Cost | Dependency, worker, DB and test runtime 비용을 기록하며 model 비용은 보통 없다. |
| References | Header Sources; E19 for the FastAPI section and E55 for language/runtime guidance; Source-derived [S] vs Engineering recommendation [R] labeled inline. |

## Trigger
Python API, data pipeline, CLI automation, Pydantic schema or FastAPI server work.

## Coding guardrails
- Keep Python version and package manager as specified by project; avoid spontaneous dependency upgrades.
- Add type hints and validated input/output schemas for public boundaries.
- Separate domain logic from endpoint concerns; use dependency injection and explicit error mapping when appropriate.
- Know the difference between async IO and CPU work. Don't block an event loop with heavy synchronous operations.
- Use DB transaction boundaries and parameterized queries; avoid committing secrets/configs.
- Any external side effect must be idempotent or explicitly guarded/reconciled.

## Test criteria
Pydantic invalid input, endpoint status/schema, permission and tenant tests, DB failure, async timeout, import/run command, backward-compatible response and logging redaction.

## Evidence
The FastAPI section below comes from E19. General Python language/runtime guidance is routed through `.ai/guides/python.md` and was rechecked against E55; framework behavior still requires the selected version's official documentation.

## FastAPI service rules (conditional; added v1.10, E19)
Applies only when FastAPI is the approved framework. It is not a recommendation to choose FastAPI over Django, Flask or a JVM stack. Labels: [S] Source-derived, [R] Engineering recommendation.

### Boundaries and models
- [S] Declare types once and let them drive validation, conversion, OpenAPI docs and editor support. Path, query, body and header inputs are inferred from the signature; a 422 with field locations is generated automatically.
- [S] Use separate input, update and output models. Return types go through `response_model` so internal fields (password hash, admin flag, internal notes) cannot leave. Do not accept privilege fields from clients; consider forbidding unknown fields on write models.
- [S] Put validation on the model (field constraints, validators) rather than scattering `if` checks in handlers, so docs and reuse stay consistent.
- [S] Never expose DB entities directly. [R] Adding a field to a stored model is a Data Exposure change under `AGENTS.md`: check response models before release.

### Dependencies, transactions, config
- [S] Share DB sessions, current user and permission checks through dependency injection; build typed aliases for reuse; tests replace them with overrides.
- [S] Code after `yield` in a dependency runs after the response is sent. Commit inside the handler (or service) before returning so a failed commit becomes an error, not a false success; keep only cleanup after `yield`.
- [S] Load settings from environment with a typed settings class, no defaults for secrets, and fail at startup when missing. Keep `.env` out of version control and commit an example file.
- [S] Use a migration tool for schema changes in non-throwaway environments; `create_all` is for practice.
- [S] Watch for N+1 queries when serializing relations; eager-load and check the emitted query count (echo logging in development).

### Async and concurrency
- [S] `def` handlers run in a thread pool; `async def` handlers run on the event loop. Blocking calls inside `async def` (sleep, sync HTTP/DB clients) stall every request. If any I/O in the handler is synchronous, use `def`, or move the blocking part to a thread/process pool (processes for CPU-bound work).
- [R] Choose `async def` only when the libraries in the path are verifiably async and a measured need exists; verify with a concurrent-request test.
- [S] Worker count depends on workload and platform; in container orchestrators scale by replicas rather than by many workers per container. Read the CPU limit from the container, not the host core count. Total DB connections = instances x pool size must stay under the DB limit, using the maximum replica count.

### Security and operations
- [S] Hash passwords with a password-specific algorithm; verify with the library, never compare hashes. Return the same error for unknown user and wrong password.
- [S] JWT payloads are signed, not encrypted; keep sensitive data out. They cannot be revoked before expiry, so use short lifetimes plus refresh or a server-side session when immediate revocation matters. Verify signature, issuer, audience and expiry; never accept unsigned tokens.
- [S] CORS: list explicit origins in production; wildcard origins and credentials do not combine.
- [S] Map unhandled errors to a generic 500 with a trace id; log details server-side. Disable interactive docs for private APIs in production.
- [S] Health: separate liveness (process only) from readiness (dependencies). A bare `ok` endpoint hides a dead database.
- [S] Request logging with a request id; propagate it in logs.

### Checks
Response lacks sensitive fields; unknown or privileged fields rejected; 401/403/404/409/422 mapped; commit failure surfaces as error; blocking call in async handler detected by concurrent test; startup fails without required settings; dependency override used in tests; query count for list endpoints; transaction rollback isolation between tests.
