# Pattern: Measured Rust Hotspot Offload (Python/Node -> Rust)
Status: optional | Applies only after a measured performance problem | Sources: PyO3 official guide (performance, parallelism; read 2026-11-25), secondary blog/conference write-ups (anecdotal), user-supplied social-media summary (claim, not evidence), Engineering recommendation

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 측정으로 확인된 병목 구간만 Rust로 옮겨 속도/메모리를 개선하고, 나머지 코드는 그대로 둔다. |
| When to Use | 대표 작업을 프로파일링했더니 소수 함수가 대부분의 시간을 차지하고, CPU-bound이며, 입출력이 작은 순수 계산(문자열 비교, 파싱, 해시, 수치 루프 등)인 경우. 목표 수치(예: p95 latency)가 있고 현재 미달일 때. |
| When Not to Use | 병목이 I/O 대기, DB, 네트워크, LLM 호출인 경우. 프로파일 없이 "Rust가 빠르다"는 이유만 있는 경우. 시간이 여러 함수에 고르게 퍼진 경우. 팀에 Rust 유지보수 인력/빌드 환경이 없는 경우. 앱 전체 재작성. |
| Alternatives | 알고리즘/자료구조 개선, 캐시, 배치, 쿼리/인덱스 개선, 이미 native인 라이브러리(numpy, polars, rapidfuzz 등) 사용, 병렬화(process), 하드웨어 증설. 보통 이쪽이 먼저다. |
| Implementation Rules | 아래 Working loop. 한 번에 한 함수/모듈, 기존 Python 함수 signature와 동작을 유지하는 얇은 바인딩, 원본 구현은 비교 기준으로 남긴다. |
| Trade-offs | 빌드 체인(Rust toolchain, 바인딩, wheel 배포), 언어 경계 데이터 변환 비용, 디버깅/온보딩 복잡도가 늘어난다. 호출이 잦고 데이터가 작으면 변환 비용이 이득을 상쇄해 오히려 느려질 수 있다. |
| Security Considerations | 새 의존성(crate) 공급망, `unsafe` 사용 최소화와 사유 기록, 외부 입력 길이/깊이 제한, panic이 호출 프로세스를 죽이지 않도록 경계에서 오류 변환, lockfile 고정. |
| Testing & Acceptance Criteria | 기존 구현과 같은 입력 -> 같은 출력(속성/경계/오류 케이스 포함), 대표 작업 end-to-end 시간이 목표를 충족, 변환 비용 포함 전후 비교 기록, 실패 시 Python 구현으로 되돌릴 수 있음. |
| Resource & Token Cost | 개발 시간과 CI 빌드 시간(플랫폼별 wheel), 바이너리 크기가 증가한다. 측정 비용은 작다. 이득이 목표 미만이면 되돌리는 것이 정답이다. |
| References | Header Sources; 이미지의 "Python 4.91s -> 42ms, 116x"는 한 도구 소개 게시물의 **특정 사례 주장**이며 `Unverified proposal`이다. 우리 앱의 기대 효과로 인용하지 않는다. |

## Trigger
"느리다", "Rust로 바꾸자", 성능 목표 미달, CPU 사용률 포화. 이 pattern을 연다고 Rust 도입이 승인된 것은 아니다(`docs/APPROVAL_POLICY.md`: 새 런타임/빌드 의존성, 아키텍처 변경은 승인 필요).

## Working loop
1. **목표 고정**: 대표 작업 1~3개와 합격 기준(예: 20s -> 5s, p95)을 `docs/BASELINE.md`에 적는다. 기준 없는 최적화는 시작하지 않는다.
2. **측정**: 같은 입력/환경에서 전체 시간과 함수별 시간을 프로파일한다(Python: `cProfile`/`py-spy`, 호출 횟수 포함). 결과를 병목 표로 남긴다: 함수, 시간 비중, 호출 수, 입출력 크기, 순수 계산 여부.
3. **먼저 비-Rust 대안**: 알고리즘, 캐시, 배치, 기존 native 라이브러리, vectorization으로 목표를 달성하면 여기서 끝낸다.
4. **후보 선별**: 시간 비중이 크고(예: 상위 1~3개 함수가 대부분), CPU-bound이며, 입출력이 단순 타입이고, 외부 I/O/상태/프레임워크 객체에 의존하지 않는 함수만 후보. 진입 스크립트, 프레임워크 글루, I/O 코드는 후보에서 제외한다.
5. **경계 설계**: 호출 한 번에 큰 배치를 넘기고 결과도 한 번에 받는다(함수 호출을 잘게 쪼개 경계를 자주 넘지 않는다). 직렬화/복사 비용을 계획에 포함한다.
6. **제안(승인 전 구현 금지)**: 후보 함수, 예상 이득(측정 근거), 빌드/배포 변경, 롤백 방법, 리스크를 `Proposal template`로 제출한다.
7. **구현**: 승인 후 후보 한 개만. 기존 테스트 + 동등성 테스트(Python 구현과 출력 비교) 추가. Python fallback을 유지하거나 feature flag로 전환한다.
8. **재측정**: 변환 비용을 포함한 **전체 실행 시간**을 baseline과 비교해 기록한다. 함수 단독 벤치마크만으로 성공을 주장하지 않는다.
9. **판정**: 목표 달성이면 유지하고 `docs/DECISIONS.md`에 근거와 수치를 기록한다. 미달이거나 이득이 미미하면 되돌린다. 다음 병목은 1번부터 다시 반복한다.

## Rules
- 전체 재작성 금지. 병목이 아닌 코드를 옮기면 Amdahl 법칙상 전체 이득이 거의 없고 유지보수 비용만 는다. 이득의 상한은 그 구간이 전체에서 차지하는 비중으로 정해진다.
- 속도 수치는 "측정한 환경/입력/횟수/기준 구현"과 함께 기록한다. 외부 사례의 배수는 근거로 쓰지 않는다.
- 같은 입력에서 결과가 같다는 증거 없이 교체하지 않는다(부동소수점, 정렬 안정성, 유니코드/인코딩, 오류 처리 차이 주의).
- 팀이 Rust를 유지보수할 수 없다면 이득이 커도 제안 단계에서 리스크로 명시한다.
- 실행하지 않은 측정은 `Not run`으로 보고한다.

## Where Rust pays off (and where it does not) - researched 2026-11-25
Evidence labels: `[V]` Verified best practice (PyO3 official docs), `[S]` secondary blog/talk reports (anecdotal, single-machine, not reproduced), `[R]` Engineering recommendation.

Good candidates `[R]` consistent with `[S]`:
- CPU-bound pure computation with a small, simple input/output: string/fuzzy matching, parsing/tokenizing, validation, hashing/compression, numeric/simulation loops, graph/tree algorithms.
- Work a single call does in at least milliseconds (so call overhead is negligible), or a whole loop that can live on the Rust side.
- Work that benefits from real multi-core: Rust `rayon` + releasing the GIL.
- Memory-heavy or latency-sensitive hot paths (GC pauses, large object graphs).

Poor candidates:
- I/O, DB, network, LLM/API waits; orchestration/glue; framework code; entry scripts; code whose time is spread across many functions.
- Tiny functions called very often from a Python/JS loop: boundary cost can make it slower (one Node/napi-rs write-up `[S]` reports ~6x faster for heavy work but ~19x slower for tiny calls; treat the numbers as indicative, not a threshold).
- Code that is slow because of the algorithm; a port of an O(n^2) algorithm is still O(n^2) `[S]`.
- Data that must be converted object-by-object across the boundary (large Python dict/list-of-objects). Prefer bytes/typed arrays/NumPy/Arrow buffers or one coarse batch call `[R]`; zero-copy NumPy/Arrow exchange is commonly recommended but verify layout/dtype/ownership against the NumPy, PyO3 and Arrow docs before relying on it.

Existing production examples (existence `[S]`; multipliers vary widely by source and workload, so do **not** reuse them as expected gains): Pydantic v2 validation core, Polars, Ruff, uv. They are libraries/tools whose core is CPU-bound and which were designed around Rust, not Python apps that were rewritten wholesale. Prefer adopting such an existing Rust-backed library over writing your own extension when it covers the need `[R]`. A survey summary `[S]` reports Rust use for Python extensions rising (27% -> 33% year over year in JetBrains' 2025 survey); adoption is not evidence that it fits your project.

## PyO3 implementation notes `[V]` (official guide, version-dependent; re-read for the pinned version)
- Release the interpreter for long Rust-only work: `Python::detach` (older versions: `allow_threads`). Attach/detach costs under a millisecond, so work of several milliseconds or more can benefit; it matters most on the GIL-enabled build and is still good practice on free-threaded builds (Python 3.14+).
- Use `rayon` for in-Rust parallelism; detach before spawning workers that attach to the interpreter, to avoid deadlock. Holding the GIL for the whole run gives no speedup on GIL builds.
- Avoid expensive conversions: use `cast` instead of `extract` when the error is ignored; use `intern!` for repeated string keys; pass Rust tuples as call arguments to get vectorcall; reuse `Bound::py()` instead of re-attaching.
- The official parallelism page's own benchmark (2020 machine) shows Rust-sequential ~4x over pure Python and Rust-parallel ~16x on that task. This is illustrative of one task, not a promise.
- Tooling: PyO3 + maturin is the standard build/packaging pair; plan per-platform wheels in CI. For Node, napi-rs plays the same role; pass buffers/typed arrays, not large JS object arrays `[S]`.

## Decision checklist (answer before proposing)
1. Is there a stated, measured target the current code misses? 2. Does a profile show one to three functions dominate? 3. Are they CPU-bound, with simple inputs/outputs and meaningful work per call? 4. Were algorithm/cache/batch/native-library alternatives tried or ruled out with numbers? 5. Can the team build, test, ship and maintain Rust (toolchain, wheels, `unsafe` review)? 6. Is a fallback/rollback in place? Any "no" means do not port yet.

## Report
병목 표, 목표 대비 전후 전체 시간, 선택한 대안과 이유, 변경 파일, 실제 실행한 테스트/벤치 명령과 결과, 롤백 방법, 남은 리스크.
