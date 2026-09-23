#!/usr/bin/env bash
set -euo pipefail

UPSTREAM="cleanstart/openldap"
TARGET="ghcr.io/dstockton/openldap"
MAJOR="2"

echo "==> Fetching upstream tags for ${UPSTREAM}..."
ALL_TAGS=$(crane ls "$UPSTREAM")

# Bare X.Y.Z only: skips -dev, per-arch, and sha256-*.sig/.att tags.
LATEST=$(grep -E "^${MAJOR}\.[0-9]+\.[0-9]+$" <<<"$ALL_TAGS" | sort -V | tail -1 || true)

if [[ -z "$LATEST" ]]; then
  echo "ERROR: no ${MAJOR}.x.y tag found upstream. Version tags seen:" >&2
  grep -E '^[0-9]+\.[0-9]+' <<<"$ALL_TAGS" | sort -V | sed 's/^/  /' >&2
  exit 1
fi

SERIES="${LATEST%.*}"
echo "==> Latest upstream tag: ${LATEST} (series ${SERIES})"

UPSTREAM_DIGEST=$(crane digest "${UPSTREAM}:${LATEST}")
echo "==> Upstream digest: ${UPSTREAM_DIGEST}"

# Compare against the rolling major tag: it is written last, so a run that
# died part way through leaves it stale and gets retried rather than skipped.
GHCR_DIGEST=$(crane digest "${TARGET}:${MAJOR}" 2>/dev/null || true)
echo "==> GHCR ${MAJOR} digest: ${GHCR_DIGEST:-not found}"

if [[ "$UPSTREAM_DIGEST" == "$GHCR_DIGEST" ]]; then
  echo "==> Already up to date. Nothing to do."
  exit 0
fi

echo "==> Copying ${UPSTREAM}:${LATEST} -> ${TARGET}:${LATEST}..."
crane copy "${UPSTREAM}:${LATEST}" "${TARGET}:${LATEST}"

echo "==> Tagging ${LATEST} as ${SERIES} and ${MAJOR}..."
crane tag "${TARGET}:${LATEST}" "${SERIES}"
crane tag "${TARGET}:${LATEST}" "${MAJOR}"

echo "==> Done. Published ${TARGET}:{${LATEST},${SERIES},${MAJOR}}"
