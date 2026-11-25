# Pattern: C/C++ Native Memory, Build and Boundary Safety
Status: optional | Applies only to C/C++ projects or native boundaries | Sources: recovered C Programming E52, C++ Programming E53

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | C 코드의 메모리 수명, 경계, 정수/문자열, 빌드 계약을 명시해 조용한 손상을 막는다. |
| When to Use | C/C++ 소스, native library/FFI, embedded/system code, compiler or sanitizer failure. |
| When Not to Use | Native code가 없는 프로젝트; 다른 언어에 C/C++ 관용구를 강제하지 않는다. |
| Alternatives | Memory-safe language/component, existing platform library, generated binding. |
| Implementation Rules | Warning-clean build, explicit ownership/length, checked arithmetic/I/O, sanitizer-backed tests. |
| Trade-offs | 경계 검사와 진단 빌드는 시간/성능 비용이 있지만 undefined behavior를 조기에 찾는다. |
| Security Considerations | Buffer bounds, use-after-free, integer overflow, format strings, untrusted file/input limits. |
| Testing & Acceptance Criteria | Warnings reviewed, sanitizer/unit/boundary/error-path tests, release-build regression. |
| Resource & Token Cost | Debug/sanitizer builds are slower and larger; keep separate measured release settings. |
| References | E52; selected compiler/platform documentation at implementation time. |

## Build and interface contract
- [S] Pin the intended C standard, compiler and build command. Enable the compiler's strong warnings in project code and review every warning; do not hide failures with broad suppressions. Keep debug symbols and Address/Undefined Behavior sanitizers in a dedicated development/test configuration, then also test the optimized release build.
- [S] Header files declare the public contract and use include guards; implementation lives in one source definition. Pass arrays/buffers with an explicit length, use `size_t` for sizes, `const` for read-only data, and document who allocates, owns, mutates and frees every pointer crossing an API boundary.

## Memory and input rules
- [S] Initialize variables and pointers; check null/error returns before use. Pair every successful allocation/acquisition with one clear cleanup path, handle partial initialization, avoid returning addresses of local storage, and never use or free memory after ownership ends.
- [S] Check bounds before indexing and reserve string terminators. Prefer length-aware input/formatting, verify conversion counts, and never let untrusted text become a format string. Treat integer narrowing, signed/unsigned mixing, size multiplication and overflow as validation boundaries before allocation or indexing.
- [S] `realloc` may fail while leaving the original allocation valid: assign through a temporary. File/network operations are partial/fallible; check open/read/write/close results and cap input size.

## Modern C++ ownership (E53; C++ only)
- [S] Prefer value types and standard containers/strings. Bind resource lifetime to an object (RAII); use `unique_ptr` for single ownership, `shared_ptr` only for proven shared lifetime, and non-owning references/pointers with an explicit lifetime contract. Avoid raw `new`/`delete`; wrap C handles in one RAII owner.
- [S] Follow the rule of zero: compose resource-managing standard types so custom destructor/copy/move code is unnecessary. After `std::move`, only destroy or assign the source unless its documented state permits more. For polymorphic bases use a virtual destructor and `override`; do not add inheritance when composition is sufficient.
- [S] Pass large read-only objects by `const&`, mutable required objects by reference, and nullable/non-owning objects by an explicitly checked pointer or optional abstraction. Remember container growth invalidates stored addresses/iterators; reserve when justified and never retain an iterator across an operation whose invalidation rules are unknown.
- [R] Pin the C++ standard and CMake/compiler settings, enable warnings plus Address/Undefined Behavior sanitizers in native tests, and include copy/move/lifetime/exception paths in regression coverage. Do not transplant C manual-allocation patterns into C++.

## Verification and diagnosis
- [S] Test empty, one-past-boundary, maximum size, invalid input, allocation/I/O failure and cleanup paths. Run sanitizers and leak checks in CI where supported; add fuzzing for parsers or externally supplied binary/text formats when risk justifies it.
- [R] Diagnose in order: reproduce with the exact build/input, read the first compiler/runtime diagnostic, reduce the case, inspect with debugger/sanitizer, fix the ownership or boundary invariant, then add the smallest regression test. Do not treat a disappearing crash under different optimization as a fix.

## Evidence labels
- `[S]` Source-derived from E52/E53. `[R]` Conservative engineering recommendation.
