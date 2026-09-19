#!/usr/bin/env bash
set -euo pipefail
smoke_temp="$(mktemp -d)"
export RUNNER_TEMP="$smoke_temp"

server=''
trap 'if [[ -n "$server" ]]; then kill "$server" 2>/dev/null || true; fi; rm -rf "$smoke_temp"' EXIT

# CI delegates lifecycle and deadlines to the shared smoke action. Keep this
# standalone mode for the documented local command.
if [[ "${1:-}" != '--assert-only' ]]; then
  PORT=4321 bun run scripts/serve-dist.ts &
  server=$!
  timeout 90 bash -c 'until curl --noproxy "*" -fsS -o /dev/null http://127.0.0.1:4321/; do sleep 1; done'
fi

# Assert on CONTENT, not just status — a 200 error page would sail
# through a status-only check.
#
# The body goes to a file rather than into `curl ... | grep -q`:
# grep -q exits at the first match, curl then dies of SIGPIPE with
# exit 23, and `pipefail` turns that into a failure. Whether it trips
# depends on response size and timing, so the piped form is
# intermittently red rather than reliably broken.
#
# /grade/3 and /fag/matematik are content-collection-driven dynamic
# routes; both are present in dist/ and verified to render.
for path in / /other /grade/3 /fag/matematik; do
  echo "==> ${path}"
  curl --noproxy "*" -fsS -m 10 -o "${RUNNER_TEMP}/page.html" "http://127.0.0.1:4321${path}"
  grep -q '<title>' "${RUNNER_TEMP}/page.html" \
    || { echo "SMOKE FAILED: ${path} served no <title>"; exit 1; }
done
