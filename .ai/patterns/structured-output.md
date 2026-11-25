# Pattern: Structured Output as a Contract
Status: on-demand | Sources: AI Agent Tool sections; Harness Engineering; Spring AI study summaries; Prompt Engineering full text (E17, user-provided, reviewed 2026-11-10)

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Model output을 downstream code가 안전하게 소비할 수 있는 versioned contract로 만든다. |
| When to Use | Output feeds code, database, UI state or Tool arguments. |
| When Not to Use | Free-form text가 사람에게만 표시되고 machine action에 연결되지 않는 경우. |
| Alternatives | Deterministic parser, constrained UI input, rule engine, manual review. |
| Implementation Rules | Typed schema, runtime validation, semantic checks, bounded repair, versioning. |
| Trade-offs | Schema는 reliability를 높이지만 evolution and repair complexity를 추가한다. |
| Security Considerations | Valid syntax도 신뢰하지 않으며 injection, oversized data, sensitive fields를 검증한다. |
| Testing & Acceptance Criteria | Missing, wrong type, extra field, semantic invalidity, migration compatibility tests. |
| Resource & Token Cost | Repair calls and larger schema prompts의 token and latency 비용을 제한한다. |
| References | Header Sources; Agent, Harness and Spring AI study material; E17 for the Prompt authoring section (Source-derived and Engineering recommendation labeled inline). |

## Trigger
Model output feeds code, database, UI state, or a downstream tool.

## Requirements
- Specify JSON Schema/Pydantic/Java DTO fields, types, enums, required/optional fields and limits.
- Parse/validate on the runtime boundary. Unknown or missing fields must not trigger side effects.
- Never treat valid syntax as factual correctness; separately verify business constraints and evidence.
- A limited repair request may be attempted, bounded by latency and cost; record repair reason.
- Include schema/version fields if persisted or consumed across services.

## Checks
Valid object, missing required field, wrong type, extra unexpected property, semantic inconsistency, oversized response, non-JSON prose, prompt-injection text, schema migration compatibility.

## Single-call prompt authoring (conditional; added v1.7, E17)
Applies when a prompt is written or revised for one model call. Not a mandate to add RICE or any template; a short task with a stable result needs only a clear instruction. Labels: [S] Source-derived from E17, [R] Engineering recommendation.

### Compose
- [S] Treat a prompt as narrowing the space of plausible outputs. A missing audience, length, format, exclusion or "what if unknown" is the usual defect; check which gap exists before adding text.
- [S] Role, Instruction, Context, Examples are a checklist, not a form. Leave a slot empty only on purpose. Diagnose by symptom: invented content -> missing Context; unstable shape -> missing Examples; wrong task -> unclear Instruction; wrong tone -> Role.
- [S] Role text counts only if deleting it would change the answer; praise ("world-class expert") does not. Give situation and reader instead.
- [S] One verb and one deliverable per call; state scope, quantity (countable units) and exclusions. Split a multi-goal request only after a single call is observed to drop parts, because each split adds calls, tokens and latency.
- [S] Fixed parts first (role, rules, format), variable input last, input wrapped in delimiters and declared as data. A fixed prefix is also what makes provider prompt caching possible; verify actual cache-read figures, never assume a hit.
- [R] Put stable rules in the system role and per-request input in the user role; keep rules from being buried in long conversations.

### Context and examples
- [S] Supply the source material for judgement and cite which part was used; do not paste unrelated documents, since more context can lower accuracy.
- [S] Few-shot: about 2-5 input/output pairs, favor borderline cases, balance label distribution, expect the last example to pull hardest, and make sure every wanted behavior appears in at least one example (an example outweighs a contradicting instruction).
- [S] Prefer a single fixed example over many rules for style; prefer rules for simple tasks. Examples cost tokens on every call, so keep only those whose effect was measured.

### Output and failure handling
- [S] Show the exact output shape rather than describing it. Prefer API-level schema enforcement over asking for JSON. Enforcement guarantees form, not truth: verify content in code (for example that a quoted evidence string really occurs in the source). Treat model self-reported confidence as a hint, not a measurement.
- [S] If enforcement is unavailable: strip code fences, extract the outermost JSON, parse, and allow a bounded retry that feeds back the parse error.
- [S] Check `finish_reason`/stop reason on every call; a length stop is a failure, not an answer. Set limits in countable units ("3 sentences", "exactly 5") and size `max_tokens` with the language's token cost in mind (Korean can use several times more tokens than English).
- [S] Extraction: permit and instruct `null` for absent fields and require source evidence per field. Summarization: list the required items so the whole document is covered. Classification: list allowed labels, tie-break rule and a default for ambiguous input.
- [S] Abstention: define what "not answerable" looks like as a normal output, require source citations, optionally decide answerable/not first, and include unanswerable cases in the evaluation set.
- [S] Consistency: fix the sampling setting for classification/extraction, change one of temperature or top_p at a time, and treat any setting as reducing variance, not guaranteeing identical output. Majority vote across calls multiplies cost; reserve it for high-impact decisions and route low agreement to a human.

### Injection boundary
- [S] Wrapping input in delimiters and stating "this is data" lowers risk but cannot guarantee safety, because instructions and data share one token stream.
- [S] Real defenses are outside the prompt: least privilege tools, validating output against an allow-list before use, not executing model output, and human approval before irreversible actions. Separate sessions or tools that read untrusted content from tools with side effects, or gate the latter. See `app-security.md` for the permission model.

### Debugging order
- [S] Inspect the exact rendered request first (unfilled variables, truncation, missing delimiters, contradictory instructions); then stop reason; then re-run to separate always-wrong (fix the prompt) from sometimes-wrong (reduce variance); then shrink input or remove instructions one at a time. These are assembly-code defects more often than wording defects.

### Additional checks
Rendered-prompt inspection, unfilled placeholder, length-stop handling, null/absence case, abstention case, delimiter-spoofing input, injected instruction in data, label-balance of examples.

### AI-feature placement (from CBAM practice)
- [R] Use the model only where judgement over unstructured input is needed. Decisions that must be repeatable (eligibility, thresholds, state assignment) are rules in code. Parsing files into text/tables uses a library, not the model (an encrypted file cannot be read by a model either). Model failure falls back to a default output and is shown as a failure.
- [R] Strict structured-output modes often require fixed keys: ask the model for an array of `{key, value}` items and convert to the storage object on the server. Use temperature 0 for extraction that feeds reporting, and record the schema in a decision record before building.
