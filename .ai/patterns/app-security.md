# Pattern: Application Security and Privacy Guardrails
Status: read on auth/data/LLM-tool changes | Sources: MSA security curriculum, Spring Boot security, Agent/RAG courses

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 애플리케이션의 인증, 권한, 데이터, 입력, 비밀정보 경계를 보호한다. |
| When to Use | Auth, tenant data, uploads, LLM tools, privacy-sensitive changes. |
| When Not to Use | 보안 영향이 전혀 없는 문서 편집이나 이미 더 엄격한 프로젝트 정책이 있는 경우. |
| Alternatives | 프로젝트별 Threat Model, framework security defaults, external security review. |
| Implementation Rules | Runtime authorization, least privilege, input validation, secret isolation, auditability. |
| Trade-offs | 추가 검증과 운영 부담이 있으나 침해와 데이터 유출 위험을 줄인다. |
| Security Considerations | 이 Pattern 자체가 Security 기준이며 프로젝트 정책과 법적 요구를 우선한다. |
| Testing & Acceptance Criteria | 권한 거부, cross-tenant, injection, secret/log leakage, revocation tests. |
| Resource & Token Cost | 검사와 logging 비용이 증가한다. 위험 기반으로 범위를 정하되 필수 검증은 생략하지 않는다. |
| References | Header Sources; engineering recommendation unless separately verified. |

## Required checks
- Authentication establishes identity; Authorization grants access to a particular resource/action. Enforce per tenant/resource, not only globally at gateway.
- Treat all user input, retrieved pages, uploads and model/tool outputs as untrusted at their respective boundaries.
- Parameterize SQL, validate paths/uploads, bound resource usage, sanitize user-facing errors and restrict logs.
- Secret values live in secret manager/environment, never source repo, prompt, tests or git history.
- Use least-privilege credentials with rotation/revocation strategy appropriate to scope.
- Prompt Injection resistance is necessary but does NOT replace runtime access checks.
- Require explicit user approval for payment, deletion, third-party writes and broad permission changes.

## Tests
Cross-tenant reads, forbidden action, user revocation, leak via logs, tampered JWT, injected tool output, credential absence and role downgrade.

## Limits
This does not certify compliance; specific legal and security standards require separate review.
