# Architecture (프로젝트별)

## System context
- Users / roles: [ ]
- Entry points: [ ]
- Modules and responsibilities: [ ]
- External dependencies and trust boundaries: [ ]
- Client → API → Business logic → Storage/Tools data flow: [ ]

## Interfaces / data
- Endpoint / events / schema / versions: [ ]
- Authentication, Authorization and Data Access: [ ]
- Error / Retry / Timeout policies: [ ]
- Async / Queue: 필요할 때만 사용. 기본으로 추가하지 않음.

## AI (사용 시)
- Routing / Model / Tool Boundaries: [ ]
- User approval, trace and evaluation: [ ]
- Fallback & operational budgets: [ ]

## Change boundaries
- 공개 API, DB schema, 이벤트 이름, 기존 DOM 계약, 권한 모델은 승인 없이 변경하지 않는다.
- Framework, DB, 클라우드, Microservices, Multi-Agent는 문제와 비용 근거가 있을 때만 추가한다.
