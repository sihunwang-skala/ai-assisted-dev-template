# Pattern: Java Core Contracts and Collections
Status: optional | Applies to Java projects with or without Spring | Source: recovered Java Programming E54 (54 sections, 5 collapsible blocks)

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Java의 값·불변성·컬렉션·예외·Stream 계약을 명확히 해 조용한 오류와 불필요한 복잡성을 줄인다. |
| When to Use | Java domain/model/collection/exception/Stream/date code or standalone JVM application. |
| When Not to Use | Java가 없는 프로젝트; Spring-specific API/transaction rules alone are handled by `backend-spring.md`. |
| Alternatives | Existing project conventions, simpler functions/records, standard-library types. |
| Implementation Rules | Immutable boundaries, value semantics, appropriate collection, preserved exception cause, measured Stream use. |
| Trade-offs | Abstractions and defensive copies improve safety but may add allocation and indirection. |
| Security Considerations | Validate untrusted input, bound collections, avoid sensitive exception/log data, use precise date/number types. |
| Testing & Acceptance Criteria | Equality/hash, null/empty, numeric precision, collection boundary, exception and date-zone tests. |
| Resource & Token Cost | Allocation, collection complexity, Stream boxing and parallel overhead are measured before optimization. |
| References | E54; selected JDK/build documentation and project toolchain are authoritative. |

## Value and API contracts
- [S] Java always passes values; an object reference is itself copied. Mutating the referenced object is visible, reassigning the parameter is not. Make mutation explicit and prefer immutable records/value objects for boundary data.
- [S] Use `BigDecimal` for exact decimal money and construct it from strings or exact values, with an explicit rounding rule. Use `java.time` types and state whether a value is local date/time, instant or zoned; do not silently rely on the host default zone.
- [S] If objects are values or collection keys, implement `equals` and `hashCode` consistently and test both. Keep enum/state invariants inside the type; avoid setters that permit invalid intermediate state.

## Collections, generics and streams
- [S] Choose by access pattern: list for ordered iteration, set for membership/uniqueness, map for keyed lookup. Do not assume one implementation's complexity; measure hot paths and avoid modifying a collection while iterating unless the API explicitly supports it.
- [S] Use generics instead of raw types. Apply producer/consumer variance deliberately at API boundaries; do not add wildcard complexity when a concrete type is clearer.
- [S] Streams are for readable transformations, not a mandate. Avoid hidden side effects, repeated traversal and boxing-heavy pipelines; use a loop when stateful control is clearer. Parallel streams share a common pool and add ordering/thread-safety/overhead risks—adopt only after workload-specific measurement.

## Failure and resource handling
- [S] Catch the narrow exception you can handle, preserve the cause when translating, and never swallow a failure or return a fabricated success. Use domain exceptions for caller-actionable failures; do not leak internal or sensitive detail in public messages.
- [S] Manage closeable resources with try-with-resources. Treat `Optional` as an explicit absence return where useful, not as a replacement for every field/parameter or a reason to call `get()` unchecked.

## Verification
- [R] Pin JDK/build versions, compile with the project's warning/static-analysis policy, and test public contracts: equality/hash, empty/null/invalid input, exact numeric rounding, time-zone/DST boundaries, exception cause, collection scale and stream/loop equivalence. Use `backend-spring.md` additionally for Spring boundaries.

## Evidence labels
- `[S]` Source-derived from E54. `[R]` Conservative engineering recommendation.
