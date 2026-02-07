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

require_env "IOS_P12_BASE64"
require_env "IOS_P12_PASSWORD"
require_env "IOS_MOBILEPROVISION_BASE64"
require_env "IOS_KEYCHAIN_PASSWORD"

TMP_DIR="$(mktemp -d)"
KEYCHAIN_PATH="${TMP_DIR}/build.keychain-db"
P12_PATH="${TMP_DIR}/signing.p12"
PROFILE_PATH="${TMP_DIR}/profile.mobileprovision"

echo "${IOS_P12_BASE64}" | decode_base64 > "${P12_PATH}"
echo "${IOS_MOBILEPROVISION_BASE64}" | decode_base64 > "${PROFILE_PATH}"

security create-keychain -p "${IOS_KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"
security set-keychain-settings -lut 21600 "${KEYCHAIN_PATH}"
security unlock-keychain -p "${IOS_KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"
security import "${P12_PATH}" \
  -P "${IOS_P12_PASSWORD}" \
  -A \
  -t cert \
  -f pkcs12 \
  -k "${KEYCHAIN_PATH}"

security set-key-partition-list \
  -S apple-tool:,apple: \
  -s \
  -k "${IOS_KEYCHAIN_PASSWORD}" \
  "${KEYCHAIN_PATH}"

security list-keychains -d user -s "${KEYCHAIN_PATH}"

mkdir -p "${HOME}/Library/MobileDevice/Provisioning Profiles"
UUID="$(
  security cms -D -i "${PROFILE_PATH}" \
    | /usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin
)"
cp "${PROFILE_PATH}" "${HOME}/Library/MobileDevice/Provisioning Profiles/${UUID}.mobileprovision"

echo "Installed signing certificate and provisioning profile (${UUID})."
