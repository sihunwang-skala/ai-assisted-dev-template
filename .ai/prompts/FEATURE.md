# Prompt: Implement One Feature

필수 (간단한 요청은 이 3칸이면 충분하다):
Task: [ ]
Acceptance Criteria: [ ]
Out of scope: [ ]

해당될 때만 채운다 (비워 두면 에이전트가 코드/문서에서 확인하고, 확인 못 하면 `확인 불가`로 보고):
Related REQ/BASE IDs: [ ]
Explicitly allowed changes: [ ]
Risk: [Low / Medium / High / Critical] - [reason]
Read first (파일 3~5개 이내, 읽지 않을 것은 제외): [ ]
Critical boundaries touched: [payment / webhook / auth / credentials / migration / public API / external write / none]

`AGENTS.md`를 준수하라.
0. 범위가 불명확한 큰 요청은 가장 작은 Vertical Slice 하나로 좁혀 제안하고 그것만 진행한다. 반대로 사용자가 여러 단계를 **명시적으로** 요청했다면(예: 필드 추가 + API 수정 + 테스트) 멈추지 말고 순서대로 처리하되, 단계마다 테스트로 검증하고 보고한다. 중간에 승인이 필요한 계약 변경이 새로 드러난 단계에서만 멈춘다.
1. 관련 기능/파일/테스트를 식별하고 Diff 범위를 제시하라. 확인한 사실은 `파일:줄` 또는 명령 출력으로 인용하고, 확인하지 못한 것은 추측으로 구현하지 말고 `확인 불가`로 보고하라.
2. 승인된 요구사항 또는 기존 동작과 충돌한다면 **수정하지 말고** Before/After, 영향, 대안, 승인 요청을 보고하라.
3. 충돌이 없다면 가장 작은 변경으로 구현하고 Regression Test를 실행하라.
4. API/DB/권한/UI/비용/실제 외부 행동의 계약은 명시적 승인 없이 변경하지 마라.
5. `docs/TEST_PLAN.md` 형식으로 제3자가 재현 가능한 번호형 QA 절차, Expected Result, Actual Result, Evidence를 기록하라.
6. High/Critical 변경은 독립 Review를 요청하고, Critical 변경은 승인과 가능한 Staging/Preview, Rollback 또는 Reconciliation 증거를 확보하라.
7. 구현 후 변경 파일, 실행한 테스트, 실패/미실행, 남은 위험, Diff Stat을 보고하라.
8. 별도 승인이 없다면 main Merge/Push, 외부 Deploy 금지.

9. 문서에 답이 있으면 그대로 따르고, 어느 문서에도 없는 것만 질문한다. 위험이 낮은 엣지 케이스는 상식적으로 정하되 코드 주석과 보고의 `가정`에 "임의로 정함"으로 남긴다. 미결정 항목을 그럴듯하게 채워 넣지 않는다.

보고 형식(고정): 변경 요약 | 변경 파일 | 실행한 테스트(결과) / 미실행 | 가정 | 남은 위험 | 승인 필요 항목.
