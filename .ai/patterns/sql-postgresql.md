# Pattern: SQL and PostgreSQL Practice
Status: optional | Applies when a relational database is used; product-specific parts apply only if PostgreSQL is approved | Sources: PostgreSQL & SQL full user-provided text (E28, reviewed 2026-11-10); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 정확하고 성능이 예측되며 동시성에 안전한 SQL, 스키마, 인덱스, 마이그레이션을 작성한다. |
| When to Use | SQL/쿼리/인덱스/트랜잭션/마이그레이션 작성·검토, 느린 쿼리, 동시 수정 문제. |
| When Not to Use | 관계형 DB를 쓰지 않는 경우. PostgreSQL 전용 항목은 다른 DB에 그대로 적용하지 않는다. |
| Alternatives | ORM 기본 기능, 다른 RDBMS, 캐시, 검색 엔진, 문서/그래프 저장소. |
| Implementation Rules | 제약은 DB에, 원자적 UPDATE 우선, 인덱스는 측정 후, 마이그레이션은 파일로. |
| Trade-offs | 인덱스는 읽기를 빠르게 하고 쓰기와 저장 공간 비용을 만든다. 격리 수준을 올리면 재시도가 필요하다. |
| Security Considerations | 파라미터 바인딩, 최소 권한 계정, 민감 컬럼 노출 점검, 파괴적 SQL 승인. |
| Testing & Acceptance Criteria | 실행계획, 동시 요청 테스트, 제약 위반, 마이그레이션 적용/롤백, 쿼리 수 확인. |
| Resource & Token Cost | 인덱스 크기, 쓰기 증폭, VACUUM/저장 공간, 연결 수. |
| References | E28 (source-derived [S]). 확장 이름, 버전 기능, 설정 기본값은 사용 중인 버전의 공식 문서로 재확인. |

## Guardrails
Running DDL/DML or migrations against a real database, `DELETE`/`UPDATE` without a verified `WHERE`, dropping indexes/tables, and changing isolation or pool settings in shared environments need approval (`AGENTS.md`). Preview targets with a `SELECT`, use a transaction, and use `RETURNING` to confirm. Labels: [S] Source-derived, [R] Engineering recommendation.

### Correctness
- [S] NULL means unknown: use `IS NULL`, not `=`; arithmetic with NULL is NULL; aggregates skip NULLs; `NOT IN` against a set containing NULL returns nothing, so prefer `NOT EXISTS`. Default new columns to `NOT NULL` unless absence has meaning; use `COALESCE`/`NULLIF` deliberately (for example divide-by-zero).
- [S] `LEFT JOIN` followed by a `WHERE` on the right table silently becomes an inner join; put the right-table condition in `ON`. Anti-join via `NOT EXISTS` or `LEFT JOIN ... IS NULL`. A missing join condition yields a cross product.
- [S] Joining a one-to-many relation multiplies rows and inflates sums; aggregate in a subquery or CTE first and check the row count after the join. Every non-aggregated selected column must be grouped.
- [S] Without `ORDER BY` row order is undefined; paging needs a unique tiebreaker. Large `OFFSET` reads and discards rows; use keyset paging for deep pages.
- [S] Name columns in `INSERT`; avoid `SELECT *` in application code. Use `RETURNING` and an `ON CONFLICT` upsert instead of read-then-write. The conflict target needs a unique constraint.
- [S] Money in exact numeric (or integer minor units), never floating point; timestamps with time zone; text without arbitrary length caps unless required.
- [S] Put rules in the database as well as the application: primary/foreign keys, `NOT NULL`, `UNIQUE`, `CHECK`. Default foreign keys to restrict deletion; cascade only where the child has no meaning without the parent. Index foreign-key columns (not created automatically). Snapshot values that must not change later (unit price at order time) instead of re-reading the current price.
- [S] Normalize to keep one fact in one place; denormalize deliberately for measured read paths. Soft deletes keep history but complicate uniqueness and queries.

### Concurrency
- [S] Read-modify-write loses updates. Order of preference: single atomic statement (`SET stock = stock - 1 WHERE stock > 0`, check affected rows); optimistic version column; row lock (`FOR UPDATE`, with `NOWAIT`/`SKIP LOCKED` for queues). Lock rows in a consistent order; set a lock timeout; inspect waiters in the activity view.
- [S] Default isolation is read committed. Repeatable read and serializable can fail with a serialization error that the application must retry. Raise isolation only with retry logic.
- [S] Updates create new row versions; dead rows need vacuum. Long-open transactions block cleanup, causing bloat; tune autovacuum on hot tables; check dead-tuple ratio and oldest transaction age.

### Performance
- [S] Diagnose with `EXPLAIN (ANALYZE, BUFFERS)` before indexing; read nodes inside-out; large gaps between estimated and actual rows mean stale statistics (run analyze). Small tables and queries returning a large share of rows correctly use sequential scans.
- [S] An index is not used when the column is wrapped in a function (use a range condition or an expression index), types differ, a leading wildcard is used (trigram index), or selectivity is low (partial index). Multicolumn index order follows the leftmost-prefix rule. Each index slows writes and consumes space; drop unused ones (check usage stats). Choose the index type by access pattern (b-tree default; GIN for arrays/JSON/text; BRIN for append-ordered huge tables).
- [S] Find offenders with the statement-statistics extension; a cheap query called very often is usually a repeated-call (N+1) problem. Log ORM SQL in development and count queries per request.
- [S] Pool size is bounded by database connections divided by instance count at maximum scale; disable open-session-in-view for web apps so connections are not held during rendering; batch inserts.
- [S] JSONB suits variable secondary attributes, not core columns (no constraints, weaker typing). Large documents move to out-of-line storage; frequently filtered fields deserve ordinary columns or expression indexes; choose GIN operator class by the operators needed.
- [S] Vector search extension: dimension, distance operator and index operator class must match the embedding model and query; changing the model needs re-embedding; approximate indexes trade recall for speed and should be built after bulk load (see `spring-ai.md`, `rag-pipeline.md`).

### Schema changes
- [S] Manage schema through ordered migration files; never edit an applied migration (checksums); add a new one. Run application schema validation, not auto-DDL, outside throwaway environments. Compatible, staged changes (see `data-and-transactions.md`).

### Checks
Row counts before and after joins; NULL cases; anti-join correctness; deep-page query; concurrent decrement test; serialization-failure retry; plan shows expected index; dead-tuple ratio; foreign-key index present; migration applies on an empty database and on a copy of production-like data.

## Oracle and other-RDBMS differences (conditional; E29)
Applies only when Oracle (or a migration to/from it) is in scope; do not apply to PostgreSQL. Labels: [S] Source-derived, [R] Engineering recommendation. Confirm each item against the vendor documentation for the version in use.
- [S] Oracle treats an empty string as NULL; other databases keep them distinct. Migrations must re-verify every `IS NULL`/empty-string condition and Java `""` round trips. `SELECT` needs `FROM DUAL`; `VARCHAR2(n)` counts bytes unless `n CHAR` is stated (multibyte text overflows), `NUMBER` for money, `DATE` carries time of day, so compare with a half-open range (`>= d AND < d+1`) and never wrap the column in a function.
- [S] Oracle does not auto-commit; DDL and DCL commit implicitly and cannot be rolled back, so never run DDL inside a transaction you expect to undo. Commit per business unit, not per row and not once for a million rows (undo exhaustion, `snapshot too old`). Readers do not block writers (undo-based read consistency); only writer-writer conflicts wait.
- [S] `ROWNUM` is assigned before `ORDER BY`: sort in an inner query then limit, or use `FETCH FIRST n ROWS ONLY`. `MERGE` source must be unique per target key (else ORA-30926). Analytic functions cannot be used in `WHERE`; wrap in a subquery. A default window frame with `ORDER BY` is `RANGE`; use `ROWS` and a tiebreaker for deterministic running totals and `ROW_NUMBER`.
- [S] A function-wrapped or implicitly converted column disables the index (`varchar_col = 100`); bind variables avoid hard parsing and SQL injection together. Binds can cause plan reuse that is wrong for skewed data; verify with the actual plan (`DBMS_XPLAN.DISPLAY_CURSOR`, estimated vs actual rows) and refresh statistics before reaching for hints. Hints freeze today's data distribution; use last.
- [S] Foreign keys without an index cause broad child-table locks and deadlocks; find and index them. B-tree indexes omit all-NULL keys, so `IS NULL` needs another design. Application accounts get least privilege, not `DBA`; never the schema owner; avoid password-expiry surprises for service accounts.
- [S] Diagnose performance from a reproducible SQL identifier and stable measurement: inspect current/actual execution statistics with `DBMS_XPLAN.DISPLAY_CURSOR`, compare estimated and actual rows, then classify statistics, access path, join order, skew/bind sensitivity, waits and repeated calls. Refresh justified statistics before changing indexes; hints are a measured last resort, not a first fix.
- [S] Prefer set-based SQL. When PL/SQL must process many rows, use bounded `BULK COLLECT` and `FORALL` batches with an explicit partial-error policy; avoid row-by-row SQL and per-row commits. Measure undo/redo, locks, elapsed time and failed-row handling on production-like volume.
- [S] Keep Oracle schema changes in reviewed migration files and use application schema validation rather than automatic production DDL. For Java mappings, preserve nullable numeric values with wrapper types, money with `BigDecimal`, and sequence allocation/fetch/batch sizes deliberately; count queries to catch N+1 and cap pools against the database connection limit at maximum replica count.
- [S] Logical schema transfer/export (Data Pump) and physical database recovery (RMAN) solve different problems. Define who owns each, retention and encryption, and never call a backup successful until a restore/recovery drill has produced verified data. Schema migration also needs a rehearsal and a rollback or forward-fix plan.
- [R] Preserve the ORA code, line, SQL identifier, transaction context and redacted bind shape when reporting an error; classify constraint/authentication/lock/storage/connectivity before changing settings. Never log credentials or sensitive bind values.
- [R] Never put sample credentials or the schema-owner login in application config; run Oracle DDL/DML and `ALTER SYSTEM` only after approval.
