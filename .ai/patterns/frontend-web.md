# Pattern: Web Frontend Fundamentals, Accessibility and Design System
Status: optional | Applies to any web UI regardless of framework | Sources: HTML, CSS, JavaScript, UI/UX & Design System full recovered/user-provided texts E32-E35 (CSS deep blocks completed 2026-11-11); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 의미 있는 마크업, 예측 가능한 CSS, 안전한 JS, 접근성, 토큰 기반 디자인 일관성을 지킨다. |
| When to Use | 웹 화면 구현/수정, 폼, 반응형, 접근성, 디자인 토큰/컴포넌트, 사용성 검증. |
| When Not to Use | 네이티브 모바일 전용 UI, 서버 전용 코드. 승인된 `docs/DESIGN_SYSTEM.md`가 있으면 그것이 우선한다. |
| Alternatives | 기존 컴포넌트 라이브러리, 헤드리스 컴포넌트, 서버 렌더링. |
| Implementation Rules | 시맨틱 태그, 토큰만 사용, 모든 상태 구현, 키보드 우선, 서버 검증 병행. |
| Trade-offs | 공용 컴포넌트는 일관성을 주지만 조기 추상화는 비용이다. |
| Security Considerations | `innerHTML` 금지(텍스트는 `textContent`), `target=_blank`에 `rel`, 토큰은 JS 저장소에 두지 않기. |
| Testing & Acceptance Criteria | 키보드만으로 과업 완료, axe/Lighthouse, 320px 가로 스크롤 없음, 상태별 화면. |
| Resource & Token Cost | 번들 크기, 렌더링 비용. |
| References | E32-E35 [S]. Vue 전용은 `frontend-vue.md`. |

Labels: [S] Source-derived, [R] Engineering recommendation. Do not restyle unrelated screens; new dependencies need approval (`AGENTS.md`).

### HTML and accessibility
- [S] Choose tags by meaning (`header nav main article section footer`, `button` for actions, `a href` for navigation, one `h1`, no skipped heading levels). A `div` click handler lacks focus, keyboard and role; use the native element.
- [S] Every input has a `<label for>` (placeholder is not a label); use correct `type`, `inputmode`, `autocomplete`. Informative images need meaningful `alt`, decorative `alt=""`, icon-only buttons an accessible name. Data tables use `caption`, `th scope`. Browser validation is convenience only: the server must validate.
- [S] Never remove focus outline (use `:focus-visible`); do not convey meaning by color alone; text contrast at least 4.5:1 (3:1 large text and UI parts); touch targets about 44px; respect `prefers-reduced-motion`; page works at 200% text size; provide a skip link; set `lang`, `viewport`, `title`.
- [S] Use `defer` or `type=module` for scripts; do not block first paint with non-essential scripts.

### CSS
- [S] Set `box-sizing: border-box`; use classes not ids for styling; keep specificity low and avoid `!important` (use `@layer` or `:where` for defaults). Gap over margins for sibling spacing. Flex for one axis, Grid for two; `min-width: 0` on flex children that must shrink; `auto-fit/minmax`, `clamp()` and container queries before many media queries; mobile first; `rem` for text; `dvh` not `vh` on mobile; Korean text `word-break: keep-all`, body line-height about 1.6; animate `transform`/`opacity` only. A z-index that does not work usually means a stacking context or missing `position`.
- [S] Colors, spacing, radii and font sizes come from tokens (CSS variables) named by role (`--color-action-primary`), not value; three layers: primitive, semantic, component. Components reference semantic tokens only so themes and dark mode change tokens, not components. Provide light/dark and check contrast in both. Use a fixed spacing scale (4/8 base) and a limited type scale (6-8 steps).
- [R] Lint hard-coded colors and off-scale spacing instead of relying on review.
- [S] Diagnose layout before adding overrides: confirm the stylesheet/rule is active in computed styles, identify the exact overflowing element, inspect flex direction/min-size and box sizing, then walk ancestor stacking contexts for z-index failures. Prefer native `dialog`/popover or an established portal for overlays rather than escalating z-index values blindly.

### JavaScript
- [S] `const` by default; `===` (except deliberate `x == null`); `??` not `||` for defaults that can be 0 or empty. Form values are strings: convert explicitly. `sort` needs a comparator and mutates; copy first. Shallow copies share nested objects (`structuredClone`). Money in integer minor units, never float; large server IDs as strings.
- [S] `fetch` does not reject on 404/500: check `res.ok`. Handle loading, error, empty, data states; time out and cancel with `AbortController`; debounce search. Await independent requests with `Promise.all`. Do not read async results before awaiting. Use event delegation for lists; prefer `closest`. Keep a single render function driven by state rather than scattering DOM edits.
- [S] Remove listeners, timers and subscriptions you register (leaks); closures keep captured data alive.
- [S] Browser storage is per browser and readable by page script: no secrets or auth tokens; wrap access in try/catch.

### UX and validation
- [S] Design every data screen's states: ideal, empty, loading (skeleton), partial, error with a retry; buttons: default, hover, focus, active, disabled, loading. Prefer an always-clickable button that explains what is missing over a silently disabled one. Show errors next to the field with what is wrong and how to fix; move focus to the first error. Show system status for waits above about one second.
- [S] One primary action per screen; hierarchy by size, weight, spacing, not many colors; test it by blurring the screen. Group by proximity before adding lines. Use familiar patterns.
- [S] Validate with users: five users per round find the biggest problems; do not report small-sample percentages as precise. Tasks are scenarios without UI wording; observers record behavior not interpretation. SUS is a relative score (about 68 average), not a percentage.
- [R] A Design System starts from tokens plus the few repeated components; version it, document when not to use a component, and use headless components for complex widgets (tabs, dialogs, menus) rather than hand-built keyboard logic. Do not build a large system before repetition exists.

### Product flow, information architecture and handoff
- [S] Base personas and scenarios on interviews, support/search/analytics evidence or clearly labelled assumptions; never invent demographic detail as fact. Record the user's goal, context, pain, current workaround and supporting evidence.
- [S] Design the information architecture and user flow before polishing screens. Name navigation in the user's vocabulary and cover the happy path plus empty, error, permission, cancellation and recovery paths; a screen list alone is not a flow.
- [S] Match prototype fidelity to the uncertainty: sketches for structure, interactive prototypes for sequence/interaction, and high fidelity only when visual details need validation. Test realistic tasks without words that reveal the intended control, then record completion, time, errors, hesitation and observed behaviour.
- [S] Handoff is an executable contract: link the source of truth and specify tokens, responsive rules, component/state behaviour, accessibility, content/data constraints, loading/empty/error copy and unresolved decisions. Designer and implementer review the running result together rather than relying only on static measurements.
- [R] Give tokens/components an owner, version, deprecation window and migration note. Visual regression baselines are accepted UI decisions, not screenshots that an implementation silently rewrites.

### Checks
Evidence or assumptions for the target user are labelled; the main flow includes failure/recovery; handoff covers states and responsive/accessibility rules; a realistic usability task is observed; keyboard-only run of the main task; axe/Lighthouse clean; 320px width and 200% text; dark mode contrast; each state screenshot; no hard-coded colors; XSS input rendered as text; failed fetch shows error and retry; form server-side validation rejects bad input.
