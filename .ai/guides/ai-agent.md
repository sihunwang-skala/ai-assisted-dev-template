# AI / LLM / Agent Guide (On demand)

## Choose the simplest effective architecture
- Problem + Baseline + User Value + failure cost + data permission + eval criteria를 먼저 정의한다.
- Rules/SQL/API/Single-call이면 충분한 문제에 LLM이나 Multi-Agent를 강제로 쓰지 않는다.
- Workflow vs Agent는 동적 의사결정 필요성으로 구분. Multi-Agent는 전문화/병렬/컨텍스트 격리의 명확한 이점이 있을 때만.
- Model-Agnostic Interface를 선호하되 실제로 교체 가능성이 낮으면 과도한 Adapter 계층은 피한다.
- 모델은 크기나 홍보 지표가 아니라 동일 평가셋의 품질·언어/도메인·도구/구조화 출력 지원·지연·개인정보 경계·비용으로 고른다. 모델/토크나이저/추론 설정 변경은 Regression을 다시 실행한다.

## Tool execution
- Tool Schema(예: Pydantic/JSON Schema), 인자 검증, 권한 체크, bounded retry, timeout, rate/budget limit.
- 외부 쓰기/예약/발송/결제/삭제는 사용자의 명시적 승인(HITL) 이후 실행.
- 승인한 Action과 Tool 실행 결과를 구분해서 기록. 민감 정보는 마스킹. 가능한 경우 Action Receipt/Idempotency.
- Tool output, Web, RAG documents, user uploads는 신뢰하지 않는 데이터. Prompt Injection을 system instruction으로 실행 금지.

## RAG & personalized context
- Retrieval 전에 ACL/tenant filter. Source ID, Version, Timestamp, Chunk, 근거를 응답과 연결.
- 정보가 없으면 모른다고 표현, Citation을 만들거나 실제 검색한 척하지 않는다.
- Chunking/Hybrid Retrieval/Reranking/Graph/Routing은 평가셋에서 유의미한 개선이 있을 때 채택.
- 개인화 데이터는 목적/동의/보존 기간, 사용자별 접근 통제 확인.

## Evaluation & observability
- 최소 Golden Set과 Baseline을 먼저 만든다. 정상/실패/악의적 입력 포함.
- Retrieval: Recall@k/Candidate quality; Generation: Faithfulness/Correctness; Operations: p95 latency, cost/request, error rate.
- Model-based grading은 Human Review 샘플, 규칙 기반 체크와 함께 Calibration.
- Tracing: Request/Version/Model/Tool/Retry/Evidence/Decision 기록. Raw PII는 남기지 않는다.
- 숫자, 성능, 고객 사례는 실제 검증 근거가 있는 것만 사용한다.
