# Protected Baseline

기존에 정상 작동하던 것을 AI가 다음 작업에서 망가뜨리지 않도록 **실제 검증된 동작**을 추적한다.
추측/미테스트 내용을 '검증됨'으로 등록하지 않는다. Baseline도 사용자 승인 없이 자동으로 바꾸지 않는다.

| ID | Protected behavior / contract | Evidence (test/demo) | Status | Last verified |
|---|---|---|---|---|
| BASE-001 | [아직 작성 전] | [unverified] | Draft | - |

## Known-good version
- Branch/commit/tag: [없음]
- Test commands actually run: [없음]
- Known limitations: [ ]

## Regression trigger
- BASE 항목에 영향을 미치는 수정이면 해당 테스트와 연결된 REQ를 검토한다.
- Baseline 자체가 틀렸다면 사용자에게 '기존 결정을 수정할 이유'를 설명하고 승인 후 갱신한다.
- 테스트가 없으면 최소 재현 단계 또는 Characterization Test를 먼저 작성한다.
