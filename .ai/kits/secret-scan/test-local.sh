#!/usr/bin/env bash
# Local-only smoke test in an isolated temporary Git repository.
set -euo pipefail
here=$(cd -- "$(dirname -- "$0")" && pwd)
command -v gitleaks >/dev/null || { echo 'Install Gitleaks first.' >&2; exit 1; }
command -v python3 >/dev/null || { echo 'Install Python 3 first.' >&2; exit 1; }
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
cd "$work"
git init -q
git -c user.name=LocalTest -c user.email=local@example.invalid commit --allow-empty -qm 'Initial clean commit'
mkdir -p .githooks
cp "$here/pre-push.sh" .githooks/pre-push
chmod +x .githooks/pre-push
scan() {
  gitleaks "$@" --redact=100 --no-color --exit-code=10
}
expect() {
  local expected=$1; shift
  local actual=0
  "$@" || actual=$?
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: expected exit=$expected; actual=$actual" >&2
    exit 1
  fi
  echo "PASS: expected exit=$expected"
}
hook() {
  printf 'refs/heads/test %s refs/heads/test %040d\n' "$(git rev-parse HEAD)" 0 | .githooks/pre-push
}
echo '1. Clean directory and history'
expect 0 scan dir .
expect 0 scan git . --log-opts='--all HEAD -m'
expect 0 hook
# Random synthetic token-shaped value; never issued by GitHub.
python3 - <<'PY' > sample.py
import secrets, string
alphabet = string.ascii_letters + string.digits
print('TOKEN = "' + 'gh' + 'p_' + ''.join(secrets.choice(alphabet) for _ in range(36)) + '"')
PY
echo '2. Synthetic credential in working tree'
expect 10 scan dir .
git add sample.py
git -c user.name=LocalTest -c user.email=local@example.invalid commit -qm 'Add synthetic fixture'
echo '3. Committed credential and hook rejection'
expect 10 scan git . --log-opts='--all HEAD -m'
expect 1 hook
git rm -q sample.py
git -c user.name=LocalTest -c user.email=local@example.invalid commit -qm 'Remove synthetic fixture'
echo '4. Deleted file still present in history'
expect 0 scan dir .
expect 10 scan git . --log-opts='--all HEAD -m'
expect 1 hook
echo 'ALL LOCAL TESTS PASSED (temporary repo removed on exit).'
