# Python Engineering Guide (On demand)

1. 기존 Python Version/Dependencies/Packaging/Style을 존중한다. 새 프로젝트는 `pyproject.toml` 등 단일 Source of Truth를 선택.
2. 타입 힌트, 명확한 함수 계약, 작은 책임 단위, Context Manager, 예외의 명시적 처리를 권장.
3. I/O, parsing, transformation, business logic을 분리하되 과도한 Class/Interface 추상화를 피한다.
4. `.venv`, Downloaded Model, Cache, 실데이터는 Git에서 제외. 외부 데이터/모델은 출처, License, Version을 기록.
5. 테스트는 `pytest` 등을 현재 프로젝트에 적합하게 적용하고, `ruff`/typecheck는 필요 수준으로 운영.
6. 네트워크와 파일 I/O에 Timeout과 경로/입력 검증 적용. 반복 로그는 개인정보를 포함하지 않는다.
7. pandas/numpy/ML 라이브러리는 용도 있을 때만 의존성 추가; 대용량 데이터는 Chunk/Streaming을 고려.
8. 하위호환이 필요한 함수 signature, public imports, serialized format은 승인 없이 변경하지 않는다.

## Language traps and operational checks (E55)
- `==`는 값 비교, `is`는 `None` 같은 객체 정체성 비교에만 쓴다. 가변 기본 인자는 `None`에서 새로 만들고, 대입·얕은 복사·깊은 복사의 차이를 테스트한다. 정렬/반복 중 원본 변경처럼 오류 없이 결과가 달라지는 연산을 확인한다.
- 함수 경계에는 타입 힌트를 쓰되 런타임 검증으로 오해하지 않는다. 외부 입력은 별도로 검증하고, 좁은 예외만 처리하며 변환할 때 `raise ... from ...`으로 원인을 보존한다. 빈 `except`나 성공값으로 실패를 숨기지 않는다.
- 파일·락·연결은 `with`로 수명을 묶고 경로는 `pathlib`로 다룬다. 텍스트 encoding, CSV newline/BOM, JSON 직렬화 계약을 명시하며 `w` 모드의 덮어쓰기는 대상 확인과 테스트가 필요하다.
- 큰 입력은 전체 리스트보다 iterator/generator/줄 단위 처리를 우선하되, generator는 한 번 소비된다는 계약을 문서화한다. `zip`의 짧은 입력 종료, 반복 중 컬렉션 변경, hash/`__eq__` 불일치를 경계 사례로 테스트한다.
- I/O 대기는 async/thread가 도움이 될 수 있지만 CPU-bound Python 코드는 현재 runtime과 라이브러리의 GIL 해제 여부를 확인해 process/vectorized/native 경로를 비교한다. 동시성 모델을 관습으로 고르지 말고 같은 workload로 측정한다.
- CPU 병목이 프로파일로 확인되면 알고리즘/기존 native 라이브러리를 먼저 쓰고, 그래도 부족할 때만 `.ai/patterns/rust-hotspot.md`로 한 구간을 제안한다(승인 필요).
- 가상환경은 저장소 밖에 두고 Python/dependency/lock source를 하나로 고정한다. import 시 실행되는 부수효과를 피하고 CLI 진입점과 library code를 분리한다.
