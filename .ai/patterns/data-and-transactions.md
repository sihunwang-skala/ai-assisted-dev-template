# Pattern: Data Modeling and Consistency
Status: optional | Sources: Data Modeling full recovered course (E39, reviewed 2026-11-11); SQL, MSA PART 4, Project Methodology curriculum; MSA full user-provided text (E21, reviewed 2026-11-10)

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Data model, migration, consistency, rollback 계약을 안전하게 설계한다. |
| When to Use | Schema, entity, distributed write, bulk ETL, data lifecycle 변경. |
| When Not to Use | Schema 영향이 없는 계산 또는 기존 read-only query만 수정할 때. |
| Alternatives | Local relational transaction, idempotent workflow, Outbox, Saga, CQRS. |
| Implementation Rules | Ownership, constraints, compatibility, backfill, backup, rollback을 먼저 정의한다. |
| Trade-offs | 강한 consistency와 복잡한 distributed patterns는 latency와 운영 부담을 높인다. |
| Security Considerations | Row and tenant authorization, retention, PII handling, safe test data를 적용한다. |
| Testing & Acceptance Criteria | Concurrency, rollback, migration failure, idempotency, unauthorized row tests. |
| Resource & Token Cost | Migration, storage, backfill and operational cost를 사전 추정한다. |
| References | E39 and Header Sources; source-derived [S] plus engineering recommendations [R]. |

## Trigger
New schema, entity changes, integration, distributed write or bulk ETL.

## Design
- Identify entities, relationships, ownership, uniqueness, nullability, lifecycle, history and data-retention rules first.
- Migration is a product contract; require review of backfill, compatibility, backup, rollback and data-loss risk.
- Prefer relational transaction for local consistency; use Outbox/Saga/CQRS only when distributed requirements actually exist.
- Map real vs synthetic data; never add genuine user/customer data to template or tests.
- For ML/recommendation document feature freshness, leakage prevention, train/serve consistency and feedback loops.

## Test
Duplicate keys, concurrent update, failed migration, rollback, idempotent writes, incomplete backfill and unauthorized row access.

## Relational model before implementation (E39)
Labels: [S] Source-derived, [R] Engineering recommendation. Product-specific SQL belongs in `sql-postgresql.md`; this section defines the model and invariants first.
- [S] Work in order: conceptual model (business entities/events and relationships), logical model (attributes, identifiers, normalization), then physical model (types, indexes, partitioning). Do not choose storage optimizations before agreeing what the facts mean.
- [S] Extract both nouns and verbs from requirements. Independent things, repeated events and relationships carrying their own attributes become entity tables; repeating values become rows, not `phone1/phone2` columns or delimiter-packed strings.
- [S] For every relationship record cardinality and optionality in both directions. Put the foreign key on the many side; resolve many-to-many with an associative entity and preserve its own facts. Translate mandatory ownership to `NOT NULL`/FK where possible, and name invariants the database cannot enforce by itself.
- [S] Classify each rule as database-enforced, transaction-enforced or asynchronously reconciled. Use `PRIMARY KEY`, `UNIQUE`, `NOT NULL`, `CHECK` and FK for facts they can express; do not rely on one application path when other writers can bypass it.

### Keys, normalization and deliberate duplication
- [S] Prefer a stable surrogate primary key when a business identifier can change, be reused, expose sensitive data or cross system boundaries; retain the business/natural key as a `UNIQUE` constraint when uniqueness is real. Record whether sequential or globally generated IDs expose scale/order and measure index effects at expected volume.
- [S] Normalize so one fact has one authoritative location and verify that update, insert and delete anomalies disappear. Snapshot a different time-bound fact—such as unit price at purchase—rather than re-reading today's value; that is not accidental duplication.
- [S] Denormalize only after a measured read path remains inadequate after query/index options. Name the writer, atomic update path, allowed staleness and reconciliation query/alert; without all four, the duplicated value is an unowned consistency defect.
- [S] Avoid polymorphic `target_type + target_id` when fixed target-specific FKs or a common parent preserve integrity. If it is necessary, document deletion responsibility and run an orphan reconciliation because the database cannot enforce the reference.

### Time, lifecycle and code values
- [S] Decide at design time which values need only current state, transition timestamps or a complete history. Money, permission, contract and dispute-relevant changes usually need actor, reason and effective time; missing history cannot be reconstructed later. Use half-open validity intervals and prevent overlaps when point-in-time answers matter.
- [S] Treat deletion as a business lifecycle decision. Soft delete affects every query, uniqueness, foreign keys, aggregates, retention and privacy; prefer an explicit domain state when the record is actually closed/cancelled, and test restore/purge separately.
- [S] Use a `CHECK` for a small stable set and a type-specific reference table when labels/order/attributes change. A universal common-code table often weakens FK/type safety; use it only with an explicit integrity mechanism.
- [S] Choose exact money units, time-zone-aware instants, calendar dates and identifier widths consistently across all referencing tables. Do not use floating point for money or strings for dates merely for convenience.

### Operational and analytical models
- [S] Evolve large schemas compatibly: add nullable/new shape, deploy dual write or translation, backfill in bounded batches, verify completeness/equality, switch reads, observe, then remove the old shape after the rollback window. Identify every consumer before renaming or removing a field.
- [S] Separate OLTP and analytical models when workload and ownership justify it. Define a fact table's grain before measures, distinguish additive/non-additive measures, and use dimensions for slicing. For changing dimensions, decide whether reports use current attributes or attributes valid at event time before choosing SCD behavior.
- [R] Keep the source-to-warehouse mapping, late-arriving data policy, replay/rebuild procedure and reconciliation totals with the model; a star schema is derived data, not a replacement for the operational source of truth.

### Model acceptance checks
Requirements map to entities/relationships; both-side cardinality and optionality are recorded; natural keys have deliberate uniqueness; duplicate and orphan writes fail or are detected; update/insert/delete anomalies are exercised; historical point-in-time query works; soft-delete uniqueness and aggregates are correct; denormalized values reconcile; migration dual-write/backfill/cutover/rollback are tested; fact grain and dimension history answer the declared analytical questions.

## Distributed data and messaging (conditional; added v1.10, E21)
Applies only when data is genuinely owned by more than one deployable service or when events cross a service boundary. A single database and local transaction remain the default. Not a mandate for Kafka, any broker, Saga, CQRS or Event Sourcing. Labels: [S] Source-derived, [R] Engineering recommendation.
- [S] Each service accesses only its own data store; enforce with separate schemas and credentials rather than convention. Reference other services' entities by id only; keep a read-only copy of needed fields, with a named source of truth and updates driven by that owner's events.
- [S] Two-phase commit is usually unsuitable across services (blocking, availability, unsupported stores). Use local transactions plus compensation when atomicity across services is required.
- [S] Choreography (event reactions) suits few steps; orchestration (a stored state machine) suits many steps, branching or timeouts. Compensation is a new forward action, must be idempotent, and may itself fail; put irreversible steps last, retain failure to a human-visible queue, and detect sagas stuck in a middle state.
- [S] Do not write the database and publish to a broker as two independent steps. Persist the event in the same local transaction (outbox) and relay it; relays are at-least-once, so consumers must tolerate duplicates. Multiple relay workers need row-level locking (skip locked) and published rows need cleanup; alert on backlog age.
- [S] Delivery is normally at-least-once and order holds only within a partition/key. Give events a unique id, type, version, timestamp and trace id; put an ordering key on the entity id; consumers record processed event ids in the same transaction as their effect, and ignore events older than the stored version.
- [S] Idempotency keys for non-idempotent commands: claim the key first (unique constraint) so concurrent duplicates fail, store a request hash, treat in-progress as a distinct state, expire records after the maximum client retry window. Prefer naturally idempotent designs (state checks, ledger entries) when possible.
- [S] Use dead-letter handling with an alert and a documented replay procedure; never leave it unmonitored.
- [S] Cross-service reads: API composition (parallel calls, tolerate partial failure) for simple screens; replicated fields for lists; a dedicated read model (CQRS) only when sorting, filtering or paging across services is a measured need. Any read model needs a full rebuild path and a reconciliation job against the source.
- [S] Eventual consistency is a product behavior: show intermediate states honestly, support read-your-writes where needed, and define what the user sees when a step fails.
- [S] Event sourcing is warranted when history itself is the core value (audit, ledger); otherwise state storage plus a change-history table is simpler. It requires snapshots, event versioning and a plan for erasure requests.
- [S] Roll schema changes in compatible steps (add, backfill, dual use, then remove after all instances upgrade) because old and new versions run together during rollout.
- [R] Add periodic consistency checks for the invariants that matter (for example paid but not confirmed) and report mismatches.

### Additional checks
Duplicate delivery of the same event; out-of-order versions; relay crash after send before mark; concurrent duplicate requests with one key; compensation run twice; stuck saga detection; broker unavailable while writes continue; rebuild of read model equals source.
