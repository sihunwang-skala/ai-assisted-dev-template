# Token / Context / Resource Budget Guide (On demand)

## Coding agent cost
- Default: `AGENTS.md`와 이번 작업 관련 PROJECT/REQ/BASE의 해당 섹션 + 관련 소스/테스트만.
- 필요한 경우에만 `.ai/guides/`를 열고, 대화 전체/대용량 파일/중복 문서/무관한 테스트 로그를 읽지 않는다.
- Read/search 먼저, 작은 Diff, Targeted Test 먼저. 광범위한 리팩터링이나 풀스캔은 근거가 있을 때.
- 쉬운 작업에 Deep Research, 여러 Subagent, 무제한 재시도, 반복 전체 재생성을 사용하지 않는다.
- Handoff는 `docs/CURRENT_STATE.md` 1페이지에 현재 상태/진행/테스트/다음 한 가지를 요약.

## Product runtime cost
- Model call 전에 deterministic rule/cache/database로 답할 수 있는지 확인.
- 작은 모델/정적 Workflow와 고성능 모델을 요청 난이도/실패 비용에 맞게 라우팅 (측정 후).
- Model/Tool 호출 상한, 출력 Token 상한, Timeout, retry cap, 캐시 정책을 예산에 맞춰 결정.
- Token/request, cost/request, p50/p95 latency, cache hit rate, error rate로 측정.
- Provider/API의 Prompt Caching은 실제 동일한 안정 Prefix와 TTL/최소 길이 조건에서만 작동한다. Markdown 파일 복제 자체가 캐시 적중을 보장하지 않는다.
- UI/컴퓨트/서버리스/외부 데이터 API도 요금제와 Free Tier 한도 확인. 과도한 다중 무료 API 분산은 개인정보 경계와 안정성 문제를 만든다.

## Performance bottleneck rule (measure before rewriting)
- 속도 문제는 목표 수치와 대표 작업을 먼저 정하고, 프로파일로 병목 함수/호출 수/I-O 비중을 확인한 뒤에만 고친다. 추측으로 최적화하거나 전체를 다른 언어로 재작성하지 않는다.
- 순서: 알고리즘/자료구조 -> 캐시/배치/쿼리 -> 기존 native 라이브러리 -> 병렬화 -> (CPU-bound 순수 계산 소수 구간만) Rust 등 native 이전(`.ai/patterns/rust-hotspot.md`). I/O, DB, 네트워크, LLM 호출이 병목이면 언어 교체는 해법이 아니다.
- 구간을 옮겼다면 언어 경계 변환 비용을 포함한 전체 실행 시간을 전후 비교한다. 외부 사례의 배수(예: "116배")는 그 사례의 주장일 뿐 우리 앱의 기대치가 아니다.
