# Pattern: Small-Model Selection and Fine-tuning
Status: optional | Approval: model/provider/data/cost changes may require approval | Source: recovered sLLM/Fine-tuning E47 (24 sections)

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Prompt/RAG로 해결되지 않는 반복적 형식·스타일·도메인 동작을 측정 가능한 데이터로 조정한다. |
| When to Use | Stable task, licensed high-quality examples and a baseline gap justify tuning or a smaller model. |
| When Not to Use | Fresh facts, missing retrieval, unclear task, tiny/noisy data, or no evaluation set. |
| Alternatives | Rules, prompt/examples, RAG, tool use, larger/smaller hosted model. |
| Implementation Rules | Baseline first, license/data gate, versioned training contract, held-out evaluation, reversible serving. |
| Trade-offs | Training adds data, GPU, serving, regression and lifecycle cost; quantization may reduce quality. |
| Security Considerations | Remove unauthorized personal/secrets data; preserve refusals and tenant isolation. |
| Testing & Acceptance Criteria | Compare baseline/candidate on task, general ability, safety, latency, memory and cost. |
| Resource & Token Cost | Dataset creation, GPU time, artifact storage and steady-state serving cost are budgeted. |
| References | E47; selected model license/card and framework docs must be verified at implementation time. |

## Decision gate
- [S] First separate the problem: changing facts usually need RAG/data updates; external actions need tools; unstable instructions need prompt/workflow repair. Fine-tune only when a stable behavior gap remains.
- [S] Compare base/instruction and hosted/self-hosted candidates on actual hardware and task data. Check license, context length, language/domain fit, quantization support and total operating cost before choosing.
- [R] Treat LoRA/QLoRA/full tuning and quantization as experiments, not defaults. Choose the least expensive method that meets the stated acceptance threshold.

## Data and training contract
- [S] Record dataset source, consent/license, deduplication, filtering, schema/chat template, tokenizer, split method and immutable version. Keep validation/test examples and repeated entities out of training.
- [S] Monitor training/validation loss and task metrics; stop and investigate divergence or overfit. Never select a checkpoint using the final test set.
- [S] Include safety/refusal and general-capability regression cases. A task metric gain is insufficient if it leaks memorized data or breaks expected refusals.

## Release and operations
- [S] Package model/base revision, adapter, tokenizer/template, quantization, code and evaluation manifest together. Do not silently combine incompatible artifacts.
- [R] Canary against the existing baseline with rollback, latency/memory/cost limits and drift/quality monitoring. Self-hosting must include capacity, availability, patching and on-call cost—not GPU price alone.

## Evidence labels
- `[S]` Source-derived from E47. `[R]` Conservative engineering recommendation.
