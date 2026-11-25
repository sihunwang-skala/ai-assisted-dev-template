# Pattern: Vue UI Implementation and Design Integrity
Status: optional | Sources: Vue 29-section detailed curriculum, HTML/CSS/JS curriculum and project design requirements

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | Vue UI의 component, state, accessibility, visual baseline을 보존한다. |
| When to Use | Vue stack이 이미 승인된 UI 구현과 변경. |
| When Not to Use | 다른 framework 프로젝트 또는 UX 요구만 있고 Vue 선택이 승인되지 않은 경우. |
| Alternatives | Existing component system, framework-native state, server-rendered UI, plain web stack. |
| Implementation Rules | Explicit props and events, controlled shared state, complete UI states, baseline comparison. |
| Trade-offs | 재사용 abstraction은 일관성을 높이지만 조기 추상화는 복잡성을 늘린다. |
| Security Considerations | Client input은 신뢰하지 않으며 auth token, error, private data 노출을 제한한다. |
| Testing & Acceptance Criteria | Responsive, keyboard, focus, validation, error recovery, visual regression tests. |
| Resource & Token Cost | Bundle size, render performance, test runtime를 추적하며 LLM token 비용은 보통 없다. |
| References | Header Sources; curriculum-derived guidance and project design rules. |

## Trigger
Existing Vue app or a new UI where Vue is already approved as the stack.

## Vue-specific discipline
- Use Composition API/reactivity deliberately (`ref`, `reactive`, `computed`, `watch`). Preserve reactivity when destructuring or passing values.
- Define component props/events/model clearly; avoid untracked hidden mutable state.
- Keep shared cross-route state in an appropriate store (e.g. Pinia) only when needed.
- Keep router, API clients and components separated; handle loading/empty/error/success/unauthorized states.
- Extract a Composable only after repeated logic or justified reuse, not for every one-liner.

## Product quality
- Prefer existing Design Tokens/components. Never silently restyle unrelated screens.
- Test mobile and desktop breakpoints, keyboard navigation, visible focus, form validation and error recovery.
- Compare changed screen to baseline; record intentional UI differences and request approval before violating established visual/UX policy.

## Avoid
Treating a Vue curriculum as a complete UX Design System textbook. The UI/UX design theory still needs an explicit project-specific spec.

## Reactivity pitfalls (conditional; E36)
Labels: [S] Source-derived. Use one style per file; prefer `ref` everywhere.
- [S] Screen not updating after a value change: missing `.value` in script, destructured reactive/props/store (use `toRefs`/`storeToRefs`, or access through the object), replaced a `reactive` object, or direct DOM edits. Update data, not DOM.
- [S] `v-for` needs a stable unique `:key` (not the index); do not combine `v-if` with `v-for` on one element (filter in `computed`). Derived values are `computed` (no side effects, copy before `sort`); side effects use `watch` (debounce requests). `v-model.number` for numbers; `@submit.prevent` for forms. `:` is required to pass non-string props and attributes.
- [S] Props down, events up; never mutate props. Use `defineModel` for input components (Vue 3.4+; check the project's Vue version), `provide/inject` for subtree-wide values (not app-wide shared data), stores for state shared across routes only. Register and unregister timers/listeners in `onMounted`/`onUnmounted`; a `KeepAlive` component is not unmounted.
- [S] Use `RouterLink`, route-level lazy imports, an API client module, an SPA fallback on the server, and only `VITE_`-prefixed non-secret env vars (they ship to the browser). Measure the bundle before trimming. See `frontend-web.md` for shared rules.
