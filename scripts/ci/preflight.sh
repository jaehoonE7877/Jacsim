#!/usr/bin/env bash
set -euo pipefail

mode="${1:-ci}"

require_env() {
  local key="$1"
  if [ -z "${!key:-}" ]; then
    echo "Missing required environment variable: ${key}" >&2
    exit 1
  fi
}

case "${mode}" in
  ci)
    require_env "TUIST_FULL_HANDLE"
    ;;
  deploy)
    require_env "TUIST_FULL_HANDLE"
    require_env "APPLE_TEAM_ID"
    require_env "ASC_KEY_ID"
    require_env "ASC_ISSUER_ID"
    require_env "ASC_PRIVATE_KEY_BASE64"
    require_env "IOS_P12_BASE64"
    require_env "IOS_P12_PASSWORD"
    require_env "IOS_MOBILEPROVISION_BASE64"
    require_env "IOS_KEYCHAIN_PASSWORD"
    require_env "GOOGLE_SERVICE_INFO_PLIST_BASE64"
    ;;
  *)
    echo "Unsupported mode: ${mode}" >&2
    echo "Usage: $0 [ci|deploy]" >&2
    exit 1
    ;;
esac

echo "Preflight (${mode}) passed."
