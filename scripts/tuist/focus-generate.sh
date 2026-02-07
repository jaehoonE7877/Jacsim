#!/usr/bin/env bash
set -euo pipefail

query="${1:-Jacsim}"
cache_profile="${TUIST_CACHE_PROFILE:-only-external}"

tuist generate "${query}" --cache-profile "${cache_profile}" --no-open
