#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_URL:?RUNNER_URL is required}"
: "${RUNNER_TOKEN:?RUNNER_TOKEN is required}"

RUNNER_NAME="${RUNNER_NAME:-docker-$(hostname)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,linux}"
RUNNER_WORK="${RUNNER_WORK:-_work}"
EPHEMERAL="${EPHEMERAL:-false}"

cd "${HOME}/actions-runner"

cleanup() {
  ./config.sh remove --unattended --token "${RUNNER_TOKEN}" 2>/dev/null || true
}
trap cleanup EXIT

echo "Runner configuration:"
echo "  URL: ${RUNNER_URL}"
echo "  Name: ${RUNNER_NAME}"
echo "  Labels: ${RUNNER_LABELS}"
echo "  Work dir: ${RUNNER_WORK}"
echo "  Ephemeral: ${EPHEMERAL}"

./config.sh \
  --unattended \
  --url "${RUNNER_URL}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "${RUNNER_LABELS}" \
  --work "${RUNNER_WORK}" \
  --replace \
  ${EPHEMERAL:+--ephemeral}

echo "healthy" >/tmp/runner_health
exec ./run.sh
