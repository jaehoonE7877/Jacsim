#!/usr/bin/env bash
set -euo pipefail

mode="${1:-ci}"

case "${mode}" in
  ci)
    # Intentionally minimal: support CI should run tests even when cache auth
    # values are not configured (e.g. fork PRs or local dry-runs).
    ;;
  *)
    echo "Unsupported mode: ${mode}" >&2
    echo "Usage: $0 [ci]" >&2
    exit 1
    ;;
esac

echo "Preflight (${mode}) passed."
