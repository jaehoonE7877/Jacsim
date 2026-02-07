#!/usr/bin/env bash
set -euo pipefail

target_path="Projects/Jacsim/Resources/GoogleService-Info.plist"

decode_base64() {
  if base64 --help 2>/dev/null | grep -q -- "--decode"; then
    base64 --decode
  else
    base64 -D
  fi
}

if [ -n "${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]; then
  mkdir -p "$(dirname "${target_path}")"
  echo "${GOOGLE_SERVICE_INFO_PLIST_BASE64}" | decode_base64 > "${target_path}"
  echo "Restored GoogleService-Info.plist from secret."
  exit 0
fi

if [ -f "${target_path}" ]; then
  echo "GoogleService-Info.plist already exists in workspace."
  exit 0
fi

echo "Missing GoogleService-Info.plist." >&2
echo "Set GOOGLE_SERVICE_INFO_PLIST_BASE64 or provide ${target_path}." >&2
exit 1
