# Secret Scan Kit (optional, dormant)

Gitleaks v8.30.1 기반. 이 폴더는 **복사 원본**이며 템플릿 자체에서는 아무것도 활성화되지 않는다(`.github/`, `.githooks/` 없음). 설치는 `docs/APPROVAL_POLICY.md`에 따라 사용자 승인 후 진행한다. 전체 폴더를 프로젝트에 복사하지 말고 아래 표의 파일만 복사한다.

| 파일 | 복사 위치 | 비고 |
|---|---|---|
| `secret-scan.yml` | `.github/workflows/secret-scan.yml` | push/PR/수동/merge_group에서 현재 파일 + 전체 Git 이력 검사 |
| `pre-push.sh` | `.githooks/pre-push` | 확장자 제거, `chmod +x`, `git config core.hooksPath .githooks` |
| `test-local.sh` | 복사 안 함 | 임시 Git 저장소에서 가짜 토큰으로 탐지/차단 검증 (`bash .ai/kits/secret-scan/test-local.sh`). `pre-push.sh`와 같은 폴더에 있어야 한다 |
| (`.gitignore`) | 이미 템플릿 `.gitignore`에 병합됨 | 기존 프로젝트는 덮어쓰지 말고 빠진 항목만 추가 |

## 사전 조건
`git`, `python3`, `gitleaks`(Mac: `brew install gitleaks`), GitHub Actions 사용 권한. Actions는 GitHub Ubuntu Runner의 Docker로 Gitleaks 이미지를 받는다.

## 설치 순서 (새 프로젝트)
1. `git rev-parse --show-toplevel`로 프로젝트 최상위인지, `git config --get core.hooksPath`와 기존 pre-push가 있는지 확인한다. 있으면 덮어쓰지 말고 통합한다.
2. `mkdir -p .github/workflows .githooks` 후 위 표대로 `cp -i`, `chmod +x .githooks/pre-push`, `git config core.hooksPath .githooks`.
3. 커밋 전 직접 검사: `gitleaks dir . --redact=100 --verbose` (첫 커밋 이후 `gitleaks git . --log-opts="--all HEAD -m" --redact=100`).
4. `bash .ai/kits/secret-scan/test-local.sh`가 `ALL LOCAL TESTS PASSED`로 끝나는지 확인한다. 실제 키로 테스트하지 않는다.
5. 보호 브랜치면 새 브랜치 + PR로 워크플로를 올리고, Actions에서 `Secret Scan` Job이 초록인지 확인한다.
6. (관리자) Settings → Rules → Rulesets에서 `Secret Scan`을 필수 status check로 지정하고 Bypass를 최소화한다. 목록에 안 보이면 Actions를 한 번 먼저 실행한다. 추가로 GitHub Secret scanning / Push protection을 켠다(요금제별 상이).
7. 배포 Job은 같은 워크플로에서 `needs: secret-scan`으로 연결한다. 별도 배포 워크플로는 검사 성공을 명시적으로 요구하도록 수정해야 하며, Job 실패만으로 외부 배포가 자동 중단되지는 않는다.

## 한계 (과장 금지)
- 패턴 기반 검사이므로 100% 탐지를 보장하지 않는다. 압축/인코딩 깊이 2단계, 일부 바이너리/LFS/submodule/서버 보관 이력은 범위 밖이다.
- 로컬 Hook은 우회 가능하고 PR 작성자가 워크플로/예외 설정을 바꿀 수 있다. 강제하려면 Ruleset + 관리자 검토(워크플로, `.gitleaks.toml`, `.gitleaksignore` 변경)가 필요하다.
- Actions만으로는 최초 Push를 막지 못한다. 이미 커밋된 비밀은 `.gitignore`나 파일 삭제로 사라지지 않는다.
- 이 kit의 YAML/셸 문법은 검사되었으나 실제 Runner 실행은 미검증이다. 최초 도입 시 `test-local.sh`와 첫 Actions 실행으로 확인하고 `actions/checkout`, Gitleaks 이미지 버전/digest를 그 시점에 재검증한다.

## 오탐 / 사고 대응
- 검출 원문을 메신저·이슈에 붙여 넣지 않는다. 예외는 책임자 승인 + 근거 기록 + 좁은 규칙만. 전체 검사 비활성화 금지.
- 노출 시 순서: (1) 발급처에서 Key 즉시 폐기·재발급 → (2) 사용 로그/비용/권한 오남용 확인 → (3) 값 제거 후 환경변수/Secret 저장소로 이동 → (4) 이력에 남았으면 관리자와 정리 범위(브랜치·태그·PR·포크) 검토, 필요 시 `git-filter-repo` 후 재클론·재검사. 승인 없이 강제 Push 금지.
- 이미 추적 중인 `.env`: `git rm --cached .env` 후 커밋(과거 이력에는 남음).

## 증상별 확인
| 증상 | 확인 |
|---|---|
| Gitleaks not found | `gitleaks version`, PATH |
| Hook 미실행 | `core.hooksPath`, 파일명(확장자 없음), 실행 권한 |
| Actions 안 보임 | `.github/workflows` 경로, YAML 커밋, Actions 허용 |
| Docker pull 오류 | Runner 네트워크, GHCR 접근, 이미지 정책 |
| 삭제 후에도 검출 | Git 이력/다른 ref에 남은 커밋 |
| Secret Scan 선택 불가 | Job 선행 실행, 요금제, 관리자 권한 |
