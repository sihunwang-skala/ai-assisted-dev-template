# AI-Assisted Software Development Template

**English** | [한국어](README.ko.md)

**Purpose:** a reusable, service-agnostic repository template that helps Claude Code, Codex and other AI coding agents build **web/mobile backends, frontends, Python/data tools and optionally LLM/Agent services** safely. This does **not** mean that every resulting application must use AI.

**State:** v1.11, docs and engineering instructions only. No application code, environment provisioned, mandatory orchestration, or active CI pipelines (the optional `.ai/kits/secret-scan/` files are copy sources and are not installed).

## Quick start for a fresh project
1. Keep this directory as the master template and copy it **once per new project** to a new local project directory, **excluding `_master/`** (template-maintenance files only). Do not copy it again for each task and do not develop an application directly inside the master.
2. Fill `docs/PROJECT.md` with a real product goal, time/cost budget, and chosen stack. Unknowns remain explicitly unapproved.
3. Fill `docs/REQUIREMENTS.md` with current approved features and acceptance criteria, `docs/BASELINE.md` with observable baseline, and `docs/DECISIONS.md` with architectural decisions.
4. Give Claude Code or Codex `.ai/prompts/START.md`, ask for the smallest usable Vertical Slice, then implement only with consent.
5. Iterate: scoped change -> tests -> diff review -> decision record -> approved merge.

## When adopting in an EXISTING project
Use `.ai/prompts/ADOPT_EXISTING.md`. **Do not overwrite existing AGENTS/CLAUDE, requirements, tested code or configuration.** Produce a comparison/merge plan first.

## Comparing this template with an existing workflow
Use the same starting commit in two isolated workspaces: A keeps the existing agent rules; B adopts this template through `ADOPT_EXISTING.md` without overwriting accepted project decisions. Give both the same task packet, model/agent, clean context, tool access, time/token budget and test environment. Prefer several representative backlog tasks over rebuilding two vaguely similar services.

Score each task on acceptance-test pass rate, regressions, unauthorized scope changes, security/contract findings, diff size, human review corrections, elapsed time, model/tool calls and cost. Keep commits, prompts, test output and review notes as evidence. Compare task-by-task and include failures; one polished demo or subjective code-style preference is not enough to claim improvement.

## Where to look
| Path | Responsibility | Normal load |
|---|---|---|
| `AGENTS.md` | Short universal agent rules, approval boundary, diff/test discipline | always |
| `CLAUDE.md` | Imports shared instructions for Claude | always in Claude context |
| `docs/PROJECT.md`, `REQUIREMENTS.md`, `BASELINE.md`, `DECISIONS.md` | Project-specific source of truth | task-dependent |
| `.ai/ROUTER.md` | Route to a small relevant guide/pattern | only when needed |
| `.ai/guides/` | Engineering guides by layer | only matching layer |
| `.ai/PATTERN_CATALOG.md` / `.ai/patterns/` | **37 optional source-informed implementation patterns** | only chosen patterns |
| `.ai/kits/secret-scan/` | Optional, dormant Gitleaks kit (Actions workflow, pre-push Hook, local test, install/incident guide); copy only after approval | secret leak prevention work |
| `_master/` | **Master-only**, not copied into projects: e-book tracker and provenance (`knowledge/`), Pattern authoring standard, e-book ingest prompt, template changelog, manifest | only when maintaining the template |
| `.ai/prompts/` | Startup, feature, bug, review, handoff, adopt existing, propose pattern | when the workflow applies |
| `docs/APPROVAL_POLICY.md` | What needs explicit approval | when proposing changes |
| `docs/ENFORCEMENT_MATRIX.md` | Map high-impact rules to checks, evidence and failure behavior | when selecting gates or reviewing risk |

## Optional pattern example: Multi-Agent
Ask for a feature -> evaluate a single-call/fixed-workflow/one-Agent baseline -> if specialized agents might genuinely help, open `.ai/patterns/multi-agent.md` and **propose** an option with estimated calls, latency, cost, risks and tests -> **wait for user approval** before changing architecture. Nothing is auto-enabled by the presence of an `.md` file.

## E-book integration: what is and isn't included
- E-book knowledge is applied as concise, original Engineering Guidance inside the relevant guides, patterns and task prompts. Full textbook text is deliberately **not** embedded.
- Per-course coverage, provenance and the intake queue live in `_master/knowledge/` (master-only). Not every course in the 44-course catalog is fully ingested; source integration and operational validation are tracked separately.
- Only user-supplied material is used as source; no course site is scraped or accessed.

## Keep changes safe and affordable
- Mandatory Selective Context Loading. Start from the request and related code/test/diff; do not read every `.md` in each AI request.
- Protect accepted requirements and baseline; approval before behavior/architecture/API/DB/security/UX/budget changes.
- Prefer deterministic implementation over unnecessary LLM/agents; use measurable proof before adopting advanced patterns.
- Never claim unexecuted tests passed. Preserve old fixes through regression tests and avoid irrelevant refactors.
- Project `docs/DECISIONS.md` tracks actual project-specific decisions.

## Rules are not enforcement
Agent instructions guide behavior but do not prove compliance. Use Risk-based Review and reproducible QA by default, then add deterministic Tests, CI checks or Hooks only after the project Stack and critical paths are known. High/Critical changes require stronger evidence; simple changes should not automatically create extra Agent calls.

## Maintaining this template
Copy the template for each new project; never develop an application inside the template itself. Never overwrite an existing project's rules with a newer template: compare the two, assess behavior and contract impact, and apply only approved changes.

## License
MIT. See [LICENSE](LICENSE).

## Security note
Do not commit live credentials, customer data, copied proprietary textbooks, or private chat logs. Shared notes are generic actionable engineering rules, not a substitute for testing and code review.
