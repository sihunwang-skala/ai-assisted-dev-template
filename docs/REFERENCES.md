# Official References (verified 2026-11-08)

이 파일은 참고 자료이며, 사용자 승인 요구사항보다 우선하지 않는다.

- Anthropic, Claude Code memory/instructions: https://code.claude.com/docs/en/memory
  - `CLAUDE.md`, `AGENTS.md`, import behavior, path-scoped rules. `CLAUDE.md` -> `@AGENTS.md`를 사용하면 Claude/Codex 공통 지침 중복을 줄일 수 있다.
- Anthropic, Claude Code best practices: https://code.claude.com/docs/en/best-practices
  - Always-read 지침 최소화, 검증 명령, scoped rules/skills, hooks, context 비용 최적화.
- OpenAI, Codex iterative workflow: https://developers.openai.com/cookbook/examples/codex/iterating-development-workflows-with-codex
  - `AGENTS.md`와 build phases, 검증 기반 workflow 예시.
- OpenAI, Rethinking skills and prompts (2026-09-11): https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra
  - 과거 누적 지침이 크면 불필요한 Context 비용과 충돌을 낳을 수 있으므로 압축하고 정리.
- GitHub, Template repositories: https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository
  - 새로운 Project를 independent Git History로 복제할 수 있다.
- GitHub, Spec Kit: https://github.com/github/spec-kit
  - Specify / Plan / Tasks / Implement / Converge, 필요 시 Lean workflow.
- GitHub, CI actions: https://docs.github.com/en/actions/get-started/quickstart
  - 실제 Stack이 정해진 뒤 CI Workflow 추가.
- Anthropic, Prompt caching (API, not repository copying): https://platform.claude.com/docs/en/build-with-claude/prompt-caching
  - Prefix/TTL/model 조건에 따라 재사용, 복제된 Markdown이 곧바로 캐시로 연결되는 것은 아니다.
- Anthropic, Claude Code settings: https://code.claude.com/docs/en/settings
  - Project/user settings and permission boundaries. Hooks or permissions must be configured and tested; a Markdown rule alone is not enforcement.
- Anthropic, Claude Code hooks: https://code.claude.com/docs/en/hooks
  - Deterministic checks can run at tool lifecycle points. Apply selectively to high-impact, objectively testable rules.
- Postiz, public Claude Code instructions: https://github.com/gitroomhq/postiz-app/blob/main/CLAUDE.md
  - Production compatibility, QA and high-impact boundary cautions were reviewed as a real-world case. This template generalizes the lessons rather than copying product-specific rules.
- Postiz, instruction history: https://github.com/gitroomhq/postiz-app/commits/main/CLAUDE.md
  - Rules can evolve from incidents and review findings. The template records reusable guards only when they are verifiable and broadly applicable.
- Postiz, pull request template: https://github.com/gitroomhq/postiz-app/blob/main/.github/PULL_REQUEST_TEMPLATE.md
  - Reproducible QA steps and reviewer-independent verification informed the executable QA format.
- GitHub, standardizing pull requests: https://docs.github.com/en/pull-requests/reference/managing-and-standardizing-pull-requests
  - Pull request templates improve consistency but do not themselves execute validation.
- GitHub, ruleset rules: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets
  - Required reviews and status checks are examples of deterministic merge gates when GitHub is actually used.

## Adopted design choices
- 한 개의 짧은 공유 `AGENTS.md` + Claude `@AGENTS.md` import.
- 변경 불가능하게 고정하지 말고, 승인 이전은 변경 제안 상태로 관리.
- Domain Guide는 On demand. 모든 프로젝트에 CI/AI/RAG/DB를 강제하지 않는다.
- Hackathon은 Lean, Product는 검증 체계를 필요에 따라 확장.
- 자연어 지침과 Enforcement를 분리하고, 변경 Risk에 비례해 Review와 Evidence를 강화.
