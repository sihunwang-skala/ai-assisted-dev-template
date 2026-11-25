# Pattern: High-Volume Data Pipeline and Messaging
Status: optional | Applies when volume, burst rate or latency needs exceed a single database plus batch script | Sources: Large-scale Data Processing full user-provided text (E30, reviewed 2026-11-11); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 수집, 버퍼, 처리, 저장, 조회 다섯 칸으로 대량/고속 데이터를 잃지 않고 다시 처리할 수 있게 설계한다. |
| When to Use | 최대 유입이 DB 쓰기를 넘거나, 소비자가 여러 개이거나, 재처리/지연 요구가 있는 데이터 흐름. |
| When Not to Use | 하루 수 GB 이하이고 야간 배치로 충분한 경우. 먼저 DB 튜닝, 인덱스, 파티션 테이블을 쓴다. |
| Alternatives | DB + batch, queue service, managed streaming, "append raw then SQL" 적재. |
| Implementation Rules | 최대치로 측정, 원본 보존, at-least-once + 멱등 저장, 이벤트 시간, 커밋은 처리 후. |
| Trade-offs | 버퍼와 스트리밍은 장애 흡수와 재처리를 주지만 운영, 상태, 지표 부담을 만든다. |
| Security Considerations | 원본 층의 개인정보 보관·마스킹·접근 통제, 토픽 ACL, 스키마 레지스트리 권한. |
| Testing & Acceptance Criteria | 소비자 중단 후 복구, 중복 전달, 늦은 데이터, 스키마 변경, 백필 대조 테스트. |
| Resource & Token Cost | 브로커 디스크·보관 기간, 파티션 수, 상태 크기, 작은 파일 수. |
| References | E30 [S]; 제품별 설정은 사용 버전의 공식 문서로 재확인. 특정 제품을 기본으로 강제하지 않는다. |

## Guardrails
Creating brokers/topics, changing partition counts or retention, resetting consumer offsets on a live group, and large backfills touch shared infrastructure and need approval. Backfill with a new consumer group or job, a rate limit, output to a temporary table, compare, then swap by partition; copy the old result first. Labels: [S] Source-derived, [R] Engineering recommendation.

### Decide first
- [S] Write down volume per day, peak (not average) events per second, latency requirement, accuracy requirement and retention before choosing tools. One machine and simple batch is the right answer for many cases; scaling out adds failure points.
- [S] Batch first. Many "real time" needs are met by a frequent batch. Use streaming only when seconds matter; first prove the logic as batch and keep it as the correctness reference.
- [S] "Can the source be re-read?" decides the design. A non-replayable source needs a buffer or producer-side durability.
- [S] Locate a slowdown by stage (ingest, buffer, process, store, query) and by metric before changing anything.

### Buffer and messaging
- [S] A durable log buffer decouples producer and consumer speed, survives consumer downtime and allows re-reading within retention; reading does not delete. Set retention to the time it takes to notice a defect, not to disk convenience.
- [S] Order is guaranteed only within a partition. Choose a key that spreads load but groups what must be ordered; a skewed key leaves one partition hot. Increasing partitions changes key placement; decreasing is not supported. Consumers in a group cannot usefully exceed partitions.
- [S] Producers: confirm the send result and flush on shutdown (silent loss is usually unchecked sends). Use acknowledgement from all in-sync replicas and idempotent producing for data that must not be lost; relax only for disposable metrics.
- [S] Consumers: disable auto-commit for important data; process, then commit. Commit-before-process loses data; process-before-commit duplicates. Standard answer: at-least-once plus idempotent write (event id and upsert / conflict-ignore; reject stale updates by event time). Transactions give exactly-once only inside the messaging system, not across an external database or API.
- [S] Rebalances: keep per-poll work within the poll interval (reduce records per poll, move heavy work out), prefer cooperative assignment and static membership for frequent deployments. Changing a consumer group name restarts from the reset policy.
- [S] Alert on consumer lag expressed as time (lag / throughput), on partition skew, and on input volume falling below a floor (a silent source stops everything quietly). Before adding consumers, check what each message does (per-message database calls); batching often beats scaling.
- [S] CDC from the transaction log avoids loading the operational database; it captures only changes after start, so snapshot first and overlap then dedupe. Order by log position, not wall-clock time. Schema changes: add optional fields only, keep a deprecation window, avoid rename and type change; a schema registry with a compatibility rule rejects breaking changes before deploy. Keep unknown fields in the raw layer.

### Time and state
- [S] Stamp every event with event time in UTC at creation. Aggregate by event time, never processing time, so reruns reproduce results. Decide explicitly what to do with data later than the watermark (drop, side output, correct later) and count it. Idle partitions can stall watermarks; configure idleness handling.
- [S] Stateful operations (aggregation, joins, dedupe) need bounded state: a join time bound, key expiry. Watch state size; steady growth means something is never evicted. Checkpoint state together with read position.
- [R] Prefer "append raw, then SQL" when minutes of latency are acceptable; the loader stays stateless and logic stays re-runnable.

### Storage and query
- [S] Keep an immutable raw layer, a cleaned layer and a serving layer so logic bugs can be rebuilt. Use columnar compressed files, partition by the usual date filter (daily, not by high-cardinality keys), and compact small files (aim for hundreds of MB) because streaming writes create thousands; plan compaction up front. Partition keys must appear in query predicates to prune.

### Checks
Producer send failure surfaced; consumer killed mid-batch then restarted (no loss, duplicates absorbed); duplicate event id; late event; schema field added; lag-in-time alert fires; input floor alert fires; backfill result equals original on overlapping range; file count and size per partition.
