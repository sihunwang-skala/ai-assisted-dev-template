# Deployment / Operations Guide (On demand)

- 환경별 (Local/Preview/Production) 구성과 Secret의 범위를 분리한다.
- Deployment는 별도 승인 작업이다. Automatic deploy나 External Writes를 기본 켜지 않는다.
- Startup/Health Checks, structured logging, actionable error and trace IDs를 필요 수준에서 구현한다.
- 비용/성능 위험이 있을 때 rate caps, timeout, retries, fallback, circuit breaker의 최소 구성을 선택한다.
- Database Migration/Backfill/rollback, version compatibility, backups는 데이터에 영향이 있을 때 우선 검토한다.
- 개인정보, 민감 로그, 원문 프롬프트의 저장기간 및 삭제 정책은 사용자/서비스 요구에 맞춘다.
- 해커톤 데모는 합성 데이터, 재현 가능한 실행 절차, 실패 시 수동 fallback을 우선.
