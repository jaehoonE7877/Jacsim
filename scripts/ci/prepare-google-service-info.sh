#!/usr/bin/env bash
set -euo pipefail

target_path="Projects/Jacsim/Resources/GoogleService-Info.plist"

# Detect CI environment for better error messages
detect_ci_env() {
  if [ -n "${CI_XCODE_CLOUD:-}" ] || [ -n "${CI_BUILD_NUMBER:-}" ]; then
    echo "xcode-cloud"
  elif [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "github-actions"
  else
    echo "local"
  fi
}

decode_base64() {
  if base64 --help 2>/dev/null | grep -q -- "--decode"; then
    base64 --decode
  else
    base64 -D
  fi
}

write_raw_plist_if_present() {
  local raw_content="$1"
  if printf '%s' "${raw_content}" | grep -q "<plist"; then
    printf '%s' "${raw_content}" > "${target_path}"
    echo "Restored GoogleService-Info.plist from raw plist content."
    return 0
  fi
  return 1
}

if [ -n "${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]; then
  mkdir -p "$(dirname "${target_path}")"
  encoded="$(printf '%s' "${GOOGLE_SERVICE_INFO_PLIST_BASE64}" | tr -d '\r\n')"
  tmp_path="${target_path}.tmp"

  if printf '%s' "${encoded}" | decode_base64 > "${tmp_path}" 2>/dev/null; then
    mv "${tmp_path}" "${target_path}"
    echo "Restored GoogleService-Info.plist from base64 secret."
    exit 0
  fi

  rm -f "${tmp_path}"
  if write_raw_plist_if_present "${GOOGLE_SERVICE_INFO_PLIST_BASE64}"; then
    exit 0
  fi

  echo "Warning: GOOGLE_SERVICE_INFO_PLIST_BASE64 is not valid base64/plist. Skipping restore."
  exit 0
fi

if [ -f "${target_path}" ]; then
  echo "GoogleService-Info.plist already exists in workspace."
  exit 0
fi

echo "Missing GoogleService-Info.plist." >&2
ci_env="$(detect_ci_env)"
case "${ci_env}" in
  xcode-cloud)
    echo "For Xcode Cloud: Add GOOGLE_SERVICE_INFO_PLIST_BASE64 in App Store Connect > App > Xcode Cloud > Workflow > Environment Variables (mark as Secret)." >&2
    ;;
  github-actions)
    echo "For GitHub Actions: Add GOOGLE_SERVICE_INFO_PLIST_BASE64 in Repository Settings > Secrets and variables > Actions > Repository secrets." >&2
    ;;
  *)
    echo "Set GOOGLE_SERVICE_INFO_PLIST_BASE64 or provide ${target_path}." >&2
    ;;
esac
exit 1
