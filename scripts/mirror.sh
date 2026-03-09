#!/usr/bin/env bash
set -euo pipefail

UPSTREAM="cleanstart/openldap"
TARGET="ghcr.io/dstockton/openldap"
SERIES="2.6"

echo "==> Fetching upstream tags for ${UPSTREAM}..."
LATEST=$(crane ls "$UPSTREAM" \
  | grep -E "^${SERIES}\.[0-9]+$" \
  | sort -t. -k1,1n -k2,2n -k3,3n \
  | tail -1)

if [[ -z "$LATEST" ]]; then
  echo "ERROR: no ${SERIES}.x tag found upstream"
  exit 1
fi
echo "==> Latest upstream tag: ${LATEST}"

UPSTREAM_DIGEST=$(crane digest "${UPSTREAM}:${LATEST}")
echo "==> Upstream digest: ${UPSTREAM_DIGEST}"

GHCR_DIGEST=$(crane digest "${TARGET}:${SERIES}" 2>/dev/null || true)
echo "==> GHCR ${SERIES} digest: ${GHCR_DIGEST:-not found}"

if [[ "$UPSTREAM_DIGEST" == "$GHCR_DIGEST" ]]; then
  echo "==> Already up to date. Nothing to do."
  exit 0
fi

echo "==> Copying ${UPSTREAM}:${LATEST} → ${TARGET}:${LATEST}..."
crane copy "${UPSTREAM}:${LATEST}" "${TARGET}:${LATEST}"

MAJOR="${LATEST%%.*}"
echo "==> Tagging ${LATEST} as ${SERIES} and ${MAJOR}..."
crane tag "${TARGET}:${LATEST}" "${SERIES}"
crane tag "${TARGET}:${LATEST}" "${MAJOR}"

echo "==> Done. Published ${TARGET}:{${LATEST},${SERIES},${MAJOR}}"
