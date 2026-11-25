#!/bin/sh
set -eu
if ! command -v gitleaks >/dev/null 2>&1; then
  echo '[SECURITY] Gitleaks is required. Push blocked.' >&2
  exit 1
fi
refs='--all'
while read -r local_ref local_sha remote_ref remote_sha; do
  case "$local_sha" in
    *[!0]*) refs="$refs $local_sha" ;;
  esac
done
if gitleaks git . --log-opts="$refs -m" --redact=100 --verbose \
    --no-color --max-archive-depth=2 --max-decode-depth=2 --exit-code=10; then
  echo '[SECURITY] PASS: no matching secrets found.'
else
  rc=$?
  if [ "$rc" -eq 10 ]; then
    echo '[SECURITY] SECRET DETECTED. Push blocked.' >&2
  else
    echo "[SECURITY] SCAN FAILED ($rc). Push blocked." >&2
  fi
  exit 1
fi
