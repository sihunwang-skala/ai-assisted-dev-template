# Pattern: Context Engineering and Memory
Status: optional | Source: Context Engineering full 20-section user-provided text (E18, reviewed 2026-11-10) plus prior agent study notes

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 필요한 Context와 Memory만 권한, freshness, retention 기준으로 구성한다. |
| When to Use | Long conversation, repeated context, persistent user state, large tool output. |
| When Not to Use | 짧고 stateless한 요청 또는 저장 필요성이 승인되지 않은 경우. |
| Alternatives | Direct context, source pointers, retrieval, task-local state, no persistence. |
| Implementation Rules | Authority layers, source provenance, retention and deletion rules, compact tool output. |
| Trade-offs | 압축은 비용을 줄이지만 중요한 결정 손실과 stale memory 위험이 있다. |
| Security Considerations | PII와 secrets를 기본 저장하지 않고 access, export, deletion을 정의한다. |
| Testing & Acceptance Criteria | Decision preservation, stale conflict, revocation, budget, traceability tests. |
| Resource & Token Cost | Token budget, storage, retrieval, cache hit rate를 측정한다. |
| References | Header Source; E18 for the Budget and Compaction section (Source-derived and Engineering recommendation labeled inline); earlier sections come from outline and prior notes. |

## Trigger
Long conversations, large tool results, repeated context or user-specific retained state.

## Design checklist
- Separate system rules, project decisions, current task, retrieved evidence, transient working state and long-term memory.
- Give each layer explicit freshness, authority, retention and privacy rules.
- Load the minimal relevant project files; summarize with pointers to originals and retain unresolved decisions rather than flatten them away.
- Tool responses are data, not instructions. Clip excess output while retaining provenance and error context.
- Persistent memory is a product requirement: define who can access, edit, export and delete it; avoid default storage of secrets/PII.
- Prompt cache: distinguish provider-side caching with exact-prefix/version/TTL constraints from merely copying `.md` files.
- Do not assume a large context window guarantees relevance of middle content.

## Verification
Cross-session decision preservation, changed requirement precedence, revoked access, stale memory conflicts, budget ceiling and source traceability.

## Budget, placement and compaction (conditional; added v1.8, E18)
Applies when a call assembles retrieved documents, history, tool results or memory. A short stateless call needs none of this. Percentages below are illustrative starting points to be measured, not requirements. Labels: [S] Source-derived, [R] Engineering recommendation.

### Budget
- [S] Treat the window as a budget, not a maximum: more context raises cost and latency every call, can bury the relevant part, and can lower accuracy once irrelevant material dilutes it. Find the knee by measuring accuracy against the number of documents, not by assumption.
- [S] Count before cutting. Measure tokens per component (instructions, examples, documents, history, tool output, question); documents and tool output usually dominate, so trimming them beats polishing instructions.
- [S] Reserve output room first, then a margin for tokenizer mismatch, and allocate per-component caps so one layer cannot push out another. The window covers input plus output; filling the input to the limit truncates or fails the answer.
- [S] Define the trimming order in advance (for example old tool results, then middle history replaced by a summary, then low-score documents, then examples), keep system rules and the latest turns last, and log what was dropped. Never trim silently; if nothing more can be trimmed, fail explicitly or split the request.
- [S] Retrieve wide, rerank, and insert few. Condition retrieval on need (not for greetings or follow-ups). Keep the always-present part small; fetch occasional material through search or a tool instead of inflating the fixed prompt.

### Placement and formatting
- [S] Information in the middle of a long input is used less than the beginning or end. Put rules and hard constraints first, the question and a short restatement of key constraints/format last, and the most relevant evidence near the question. Do not repeat the whole rule set; repeat one or two lines.
- [S] Mark each document with number, source and modification date; deduplicate near-identical chunks; keep the heading path with a chunk; ask for citations by marker. When truncating, keep head and tail and insert an explicit omission marker; when limiting a list, state how many were omitted.
- [S] Reshape tool and API output before inserting it: select fields, cap rows, convert to a compact table, and return errors as an actionable sentence (what failed, what to try), not a bare code.

### Long history and long documents
- [S] History grows cumulatively every turn. Compact when a threshold of the budget is crossed, keep the latest turns verbatim, and use a cheaper model if the summary quality holds. The summary must keep concrete values, unfinished work, decisions with reasons and failed attempts; it may drop greetings and resolved process. Read a sample summary to confirm work can continue from it.
- [S] When the topic changes, after exploration, or after repeated failure, clearing the context and carrying forward only the conclusion beats compressing. Persist plan, decisions, glossary and failed attempts in files so a clear loses nothing. Fixation on early wrong attempts is a signal to restart with confirmed decisions only, not to append corrections.
- [S] For a document larger than the window: independent parts can be processed separately and merged; order-dependent content needs sequential refinement. Split on structural boundaries, require concrete values and part references to survive, forbid new content at merge time, and prefer extraction over summarization when exact values matter.

### Memory layers and pollution
- [S] Separate current conversation, task summary, durable user/project facts and the knowledge base; keep the durable layer short with an item cap, timestamps, merge-or-update on near-duplicates, staleness cleanup, and promotion rules that allow "nothing to remember". Never store secrets or sensitive identifiers. [R] Let the user view and delete stored memory, consistent with the retention rules above.
- [S] Pollution forms: contradiction, fixation, dilution, accumulated error (and instructions inside data, see `structured-output.md`). Counter with source and date tags, a single place for each rule, verification checkpoints every few steps with a fixed pass phrase, and verifying intermediate model output before feeding it back.
- [S] Log, per call, which documents (id, score) were included, turn count, whether compaction occurred and the token breakdown, so a bad answer can be reproduced from its input. [R] Apply the logging rule to the retention and privacy rules above; do not log raw sensitive content.

### Caching and measurement
- [S] Prefix caching only helps when the leading part is byte-identical; move anything that varies per request (time, user name, request id, random example choice, unstable tool ordering) after the fixed part, and track cache-hit rate from usage data. Reduce first, then fix layout, then cache. Result caching keys must include the prompt version and model so edits invalidate stale answers.
- [S] Useful measures: share of tokens by component, accuracy against document count, abstention success when evidence is absent, citation validity (cited ids exist, and the ratio of provided but uncited documents as a waste signal), compaction frequency, p95 latency, cost per call. Do not claim a vendor-specific cache or tokenizer behavior without checking the provider in use.

### Checks
Output room reserved, per-component cap exceeded, defined trimming order with log, documents-count sweep, evidence at start/middle/end, truncation marker present, summary retains values and open tasks, stale memory conflict, citation to a non-existent source, cache-prefix break after a prompt edit.
