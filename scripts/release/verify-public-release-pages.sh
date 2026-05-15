#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/release/verify-public-release-pages.sh [--privacy-url URL] [--support-url URL] [--expected-support-privacy-url URL] [--skip-support]

Verifies public App Store submission pages after publishing:
- Privacy policy URL contains the Jacsim 2.0 policy content
- Support URL contains the public support email and privacy policy URL

The privacy URL defaults to https://sjh7877.tistory.com/19.
The expected support-page privacy link defaults to the privacy URL.
EOF
}

privacy_url="https://sjh7877.tistory.com/19"
expected_support_privacy_url=""
support_url=""
skip_support="false"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --privacy-url)
      privacy_url="${2:-}"
      shift 2
      ;;
    --support-url)
      support_url="${2:-}"
      shift 2
      ;;
    --expected-support-privacy-url)
      expected_support_privacy_url="${2:-}"
      shift 2
      ;;
    --skip-support)
      skip_support="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${expected_support_privacy_url}" ]]; then
  expected_support_privacy_url="${privacy_url}"
fi

failures=()
warnings=()
tmp_files=()

cleanup() {
  if [[ "${#tmp_files[@]}" -gt 0 ]]; then
    rm -f "${tmp_files[@]}"
  fi
}
trap cleanup EXIT

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  failures+=("$1")
  printf 'FAIL: %s\n' "$1" >&2
}

warn() {
  warnings+=("$1")
  printf 'WARN: %s\n' "$1" >&2
}

fetch_page() {
  local url="$1"
  local label="$2"
  local output
  output="$(mktemp)"
  tmp_files+=("${output}")

  if curl -fsSL --retry 2 --max-time 20 --user-agent "JacsimReleaseVerifier/2.0" "${url}" -o "${output}"; then
    pass "${label} is reachable" >&2
  else
    fail "${label} is not reachable: ${url}"
  fi

  printf '%s' "${output}"
}

require_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"

  if grep -Fq "${pattern}" "${file}"; then
    pass "${label}"
  else
    fail "${label} missing (${pattern})"
  fi
}

require_not_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"

  if grep -Fq "${pattern}" "${file}"; then
    fail "${label} still present (${pattern})"
  else
    pass "${label}"
  fi
}

if [[ -z "${privacy_url}" ]]; then
  fail "Privacy policy URL is empty"
else
  privacy_page="$(fetch_page "${privacy_url}" "Privacy policy URL")"
  require_contains "${privacy_page}" "2026년 5월 2" "Privacy policy effective date is current"
  require_contains "${privacy_page}" "sjh7877@naver.com" "Privacy policy includes support email"
  require_contains "${privacy_page}" "JPEG" "Privacy policy explains JPEG image compression"
  require_contains "${privacy_page}" "원본" "Privacy policy explains original image is not stored"
  require_contains "${privacy_page}" "Firebase Crashlytics" "Privacy policy explains Firebase Crashlytics"
  require_contains "${privacy_page}" "FirebaseInstallations" "Privacy policy explains FirebaseInstallations"
  require_contains "${privacy_page}" "GoogleDataTransport" "Privacy policy explains GoogleDataTransport"
  require_not_contains "${privacy_page}" "2022년 9월 28" "Old 2022 privacy policy effective date"
  require_not_contains "${privacy_page}" "계좌정보, 거래날짜" "Old template financial-data placeholder"
fi

if [[ "${skip_support}" == "true" ]]; then
  warn "Support URL check skipped by --skip-support"
elif [[ -z "${support_url}" ]]; then
  fail "Support URL is required unless --skip-support is passed"
else
  support_page="$(fetch_page "${support_url}" "Support URL")"
  require_contains "${support_page}" "sjh7877@naver.com" "Support page includes support email"
  require_contains "${support_page}" "${expected_support_privacy_url}" "Support page links to privacy policy"
  require_contains "${support_page}" "계정 생성" "Support page explains no account creation"
  require_contains "${support_page}" "로컬 알림" "Support page explains local notifications"
  require_contains "${support_page}" "앱 내부 이미지" "Support page explains local image cleanup"
fi

printf '\nPublic page verification summary: %s failure(s), %s warning(s)\n' "${#failures[@]}" "${#warnings[@]}"

if [[ "${#failures[@]}" -gt 0 ]]; then
  exit 1
fi
