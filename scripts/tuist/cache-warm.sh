#!/usr/bin/env bash
set -euo pipefail

configuration="${1:-Debug}"
shift || true

if ! tuist cache --configuration "${configuration}" --external-only "$@"; then
  echo "Falling back to external-only cache warm without target filters."
  tuist cache --configuration "${configuration}" --external-only
fi
