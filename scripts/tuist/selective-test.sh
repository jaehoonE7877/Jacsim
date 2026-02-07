#!/usr/bin/env bash
set -euo pipefail

scheme="${1:-Jacsim}"
shift || true

tuist test "${scheme}" --selective-testing "$@"
