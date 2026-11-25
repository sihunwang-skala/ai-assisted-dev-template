# Prompt: Fix Regression / Bug

Bug: [Actual vs Expected]
First observed: [ ]
Previously working version (if known): [ ]
Reproduction: [ ]

`AGENTS.md`를 준수하라.
1. 기존 요구사항과 Baseline을 확인하고 최소 재현을 만든다. 코드를 읽기 전에 실제 입력, 실제 출력, 로그, 모델 호출이면 실제로 보낸 요청 전문을 먼저 확인한다.
1-1. 재현을 여러 번 실행해 항상 실패하는지 가끔 실패하는지 구분한다. 가끔이면 타이밍, 동시성, 비결정성부터 의심한다.
2. 원인과 영향 범위를 추론/관찰로 구분해 제시한다.
3. 재발 방지 테스트를 작성해 수정 전에 실패하는 출력을 남기고, 한 번에 하나의 가설만 좁게 수정한다. 같은 방향이 두 번 실패하면 가설을 버리고 입력부터 다시 확인한다.
4. 기존 기능/데이터 계약 변경은 사용자 승인 전 금지.
5. Targeted Regression, 필요한 Full Suite, Diff를 확인하고 증거와 실패 내역을 보고한다.
6. 관련 없는 리팩터링/스타일 변경은 하지 않는다.
