#!/usr/bin/env bash
set -euo pipefail

decode_base64() {
  if base64 --help 2>/dev/null | grep -q -- "--decode"; then
    base64 --decode
  else
    base64 -D
  fi
}

require_env() {
  local key="$1"
  if [ -z "${!key:-}" ]; then
    echo "Missing required environment variable: ${key}" >&2
    exit 1
  fi
}

require_env "ASC_KEY_ID"
require_env "ASC_PRIVATE_KEY_BASE64"

KEY_DIR="${HOME}/.appstoreconnect/private_keys"
KEY_PATH="${KEY_DIR}/AuthKey_${ASC_KEY_ID}.p8"

mkdir -p "${KEY_DIR}"
echo "${ASC_PRIVATE_KEY_BASE64}" | decode_base64 > "${KEY_PATH}"
chmod 600 "${KEY_PATH}"

echo "Prepared App Store Connect API key at ${KEY_PATH}."
