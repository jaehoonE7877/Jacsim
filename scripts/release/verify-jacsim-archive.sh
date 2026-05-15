#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/release/verify-jacsim-archive.sh [--allow-unsigned] [--allow-development-signing] <Jacsim.xcarchive>

Verifies the App Store submission-sensitive parts of a Jacsim archive:
- Info.plist version, camera/photos usage strings, and device rotation support
- App privacy manifest required reason and tracking flag
- Firebase diagnostic privacy manifest data types, purposes, and tracking flags
- No unexpected collected data types, purposes, linked-data flags, or tracking flags
- Stale resources and removed SDK/string signals
- Duplicated third-party resource bundles under embedded frameworks
- App Store distribution signing entitlements when the archive is signed
EOF
}

allow_unsigned="false"
allow_development_signing="false"
archive_path=""

for arg in "$@"; do
  case "${arg}" in
    --allow-unsigned)
      allow_unsigned="true"
      ;;
    --allow-development-signing)
      allow_development_signing="true"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      archive_path="${arg}"
      ;;
  esac
done

if [[ -z "${archive_path}" ]]; then
  usage >&2
  exit 2
fi

app_path="${archive_path}/Products/Applications/Jacsim.app"
info_plist="${app_path}/Info.plist"
privacy_manifest="${app_path}/PrivacyInfo.xcprivacy"
expected_version="${EXPECTED_VERSION:-2.0.0}"

failures=()
warnings=()

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

require_file() {
  local path="$1"
  local label="$2"
  if [[ -e "${path}" ]]; then
    pass "${label}"
  else
    fail "${label} missing at ${path}"
  fi
}

plist_raw() {
  local key="$1"
  local plist="$2"
  plutil -extract "${key}" raw -o - "${plist}" 2>/dev/null || true
}

is_allowed_value() {
  local candidate="$1"
  shift

  local allowed
  for allowed in "$@"; do
    if [[ "${candidate}" == "${allowed}" ]]; then
      return 0
    fi
  done

  return 1
}

join_array() {
  local joined=""
  local item

  for item in "$@"; do
    if [[ -z "${joined}" ]]; then
      joined="${item}"
    else
      joined="${joined}; ${item}"
    fi
  done

  printf '%s' "${joined}"
}

require_file "${app_path}" "Jacsim.app exists"
require_file "${info_plist}" "Info.plist exists"
require_file "${privacy_manifest}" "PrivacyInfo.xcprivacy exists"

if [[ ! -d "${app_path}" || ! -f "${info_plist}" ]]; then
  printf '\nArchive is not inspectable.\n' >&2
  exit 1
fi

actual_version="$(plist_raw CFBundleShortVersionString "${info_plist}")"
if [[ "${actual_version}" == "${expected_version}" ]]; then
  pass "CFBundleShortVersionString = ${expected_version}"
else
  fail "CFBundleShortVersionString expected ${expected_version}, got ${actual_version:-<missing>}"
fi

camera_usage="$(plist_raw NSCameraUsageDescription "${info_plist}")"
photo_usage="$(plist_raw NSPhotoLibraryUsageDescription "${info_plist}")"
[[ -n "${camera_usage}" ]] && pass "NSCameraUsageDescription exists" || fail "NSCameraUsageDescription missing"
[[ -n "${photo_usage}" ]] && pass "NSPhotoLibraryUsageDescription exists" || fail "NSPhotoLibraryUsageDescription missing"

orientation_xml="$(mktemp)"
if plutil -extract UISupportedInterfaceOrientations xml1 -o "${orientation_xml}" "${info_plist}" >/dev/null 2>&1; then
  if grep -q "UIInterfaceOrientationPortrait" "${orientation_xml}" \
    && grep -q "UIInterfaceOrientationLandscapeLeft" "${orientation_xml}" \
    && grep -q "UIInterfaceOrientationLandscapeRight" "${orientation_xml}"; then
    pass "UISupportedInterfaceOrientations supports portrait and landscape rotation"
  else
    fail "UISupportedInterfaceOrientations must include portrait, landscape left, and landscape right"
  fi
else
  fail "UISupportedInterfaceOrientations missing"
fi
rm -f "${orientation_xml}"

if [[ -f "${privacy_manifest}" ]]; then
  privacy_dump="$(plutil -p "${privacy_manifest}")"
  if grep -q "NSPrivacyAccessedAPICategoryUserDefaults" <<<"${privacy_dump}" && grep -q "CA92.1" <<<"${privacy_dump}"; then
    pass "Privacy manifest declares UserDefaults required reason CA92.1"
  else
    fail "Privacy manifest missing UserDefaults required reason CA92.1"
  fi

  if grep -q '"NSPrivacyTracking" => false' <<<"${privacy_dump}"; then
    pass "Privacy manifest declares tracking false"
  else
    fail "Privacy manifest does not declare tracking false"
  fi
fi

require_sdk_manifest() {
  local bundle_name="$1"
  local label="$2"
  local manifest
  manifest="$(find "${app_path}" -path "*${bundle_name}.bundle/PrivacyInfo.xcprivacy" -print -quit)"
  if [[ -n "${manifest}" ]]; then
    pass "${label} privacy manifest exists"
  else
    fail "${label} privacy manifest missing"
  fi
}

sdk_manifest_path() {
  local bundle_name="$1"
  find "${app_path}" -path "*${bundle_name}.bundle/PrivacyInfo.xcprivacy" -print -quit
}

require_manifest_value() {
  local manifest="$1"
  local pattern="$2"
  local label="$3"

  if [[ ! -f "${manifest}" ]]; then
    fail "${label} manifest missing"
    return
  fi

  if plutil -p "${manifest}" | grep -q "${pattern}"; then
    pass "${label}"
  else
    fail "${label}"
  fi
}

crashlytics_manifest="$(sdk_manifest_path "Firebase_FirebaseCrashlytics")"
installations_manifest="$(sdk_manifest_path "Firebase_FirebaseInstallations")"
gdt_manifest="$(sdk_manifest_path "GoogleDataTransport_GoogleDataTransport")"

require_sdk_manifest "Firebase_FirebaseCrashlytics" "Firebase Crashlytics"
require_manifest_value "${crashlytics_manifest}" "NSPrivacyCollectedDataTypeCrashData" "Firebase Crashlytics declares Crash Data"
require_manifest_value "${crashlytics_manifest}" "NSPrivacyCollectedDataTypeOtherDiagnosticData" "Firebase Crashlytics declares Other Diagnostic Data"
require_manifest_value "${crashlytics_manifest}" "NSPrivacyCollectedDataTypePurposeAppFunctionality" "Firebase Crashlytics declares App Functionality purpose"
require_manifest_value "${crashlytics_manifest}" '"NSPrivacyCollectedDataTypeLinked" => false' "Firebase Crashlytics declares data not linked"
require_manifest_value "${crashlytics_manifest}" '"NSPrivacyCollectedDataTypeTracking" => false' "Firebase Crashlytics declares collected data not used for tracking"
require_manifest_value "${crashlytics_manifest}" '"NSPrivacyTracking" => false' "Firebase Crashlytics declares tracking false"

require_sdk_manifest "Firebase_FirebaseInstallations" "Firebase Installations"
require_manifest_value "${installations_manifest}" "NSPrivacyCollectedDataTypeOtherDiagnosticData" "Firebase Installations declares Other Diagnostic Data"
require_manifest_value "${installations_manifest}" "NSPrivacyCollectedDataTypePurposeAnalytics" "Firebase Installations declares Analytics purpose"
require_manifest_value "${installations_manifest}" '"NSPrivacyCollectedDataTypeLinked" => false' "Firebase Installations declares data not linked"
require_manifest_value "${installations_manifest}" '"NSPrivacyCollectedDataTypeTracking" => false' "Firebase Installations declares collected data not used for tracking"
require_manifest_value "${installations_manifest}" '"NSPrivacyTracking" => false' "Firebase Installations declares tracking false"

require_sdk_manifest "GoogleDataTransport_GoogleDataTransport" "GoogleDataTransport"
require_manifest_value "${gdt_manifest}" "NSPrivacyCollectedDataTypeOtherDiagnosticData" "GoogleDataTransport declares Other Diagnostic Data"
require_manifest_value "${gdt_manifest}" "NSPrivacyCollectedDataTypePurposeAnalytics" "GoogleDataTransport declares Analytics purpose"
require_manifest_value "${gdt_manifest}" '"NSPrivacyCollectedDataTypeLinked" => false' "GoogleDataTransport declares data not linked"
require_manifest_value "${gdt_manifest}" '"NSPrivacyCollectedDataTypeTracking" => false' "GoogleDataTransport declares collected data not used for tracking"
require_manifest_value "${gdt_manifest}" '"NSPrivacyTracking" => false' "GoogleDataTransport declares tracking false"

validate_collected_data_scope() {
  local allowed_data_types=(
    "NSPrivacyCollectedDataTypeCrashData"
    "NSPrivacyCollectedDataTypeOtherDiagnosticData"
  )
  local allowed_purposes=(
    "NSPrivacyCollectedDataTypePurposeAnalytics"
    "NSPrivacyCollectedDataTypePurposeAppFunctionality"
  )

  local manifests=()
  while IFS= read -r manifest; do
    manifests+=("${manifest}")
  done < <(find "${app_path}" -name "PrivacyInfo.xcprivacy" -print | sort)

  if [[ "${#manifests[@]}" -eq 0 ]]; then
    fail "No bundled privacy manifests found"
    return
  fi

  local unexpected_data_types=()
  local unexpected_purposes=()
  local linked_data_flags=()
  local tracking_flags=()

  local manifest
  for manifest in "${manifests[@]}"; do
    local collected_json
    collected_json="$(plutil -extract NSPrivacyCollectedDataTypes json -o - "${manifest}" 2>/dev/null || true)"

    if [[ -n "${collected_json}" ]]; then
      local collected_type
      while IFS= read -r collected_type; do
        [[ -z "${collected_type}" ]] && continue
        if ! is_allowed_value "${collected_type}" "${allowed_data_types[@]}"; then
          unexpected_data_types+=("${manifest}: ${collected_type}")
        fi
      done < <(
        printf '%s\n' "${collected_json}" \
          | grep -Eo '"NSPrivacyCollectedDataType"[[:space:]]*:[[:space:]]*"NSPrivacyCollectedDataType[A-Za-z]+"' \
          | sed -E 's/^.*:[[:space:]]*"([^"]+)".*$/\1/' \
          | sort -u || true
      )

      local collected_purpose
      while IFS= read -r collected_purpose; do
        [[ -z "${collected_purpose}" ]] && continue
        if ! is_allowed_value "${collected_purpose}" "${allowed_purposes[@]}"; then
          unexpected_purposes+=("${manifest}: ${collected_purpose}")
        fi
      done < <(
        printf '%s\n' "${collected_json}" \
          | grep -Eo '"NSPrivacyCollectedDataTypePurpose[A-Z][A-Za-z]+"' \
          | tr -d '"' \
          | sort -u || true
      )

      if grep -Eq '"NSPrivacyCollectedDataTypeLinked"[[:space:]]*:[[:space:]]*true' <<<"${collected_json}"; then
        linked_data_flags+=("${manifest}")
      fi

      if grep -Eq '"NSPrivacyCollectedDataTypeTracking"[[:space:]]*:[[:space:]]*true' <<<"${collected_json}"; then
        tracking_flags+=("${manifest}: collected data tracking=true")
      fi
    fi

    if plutil -p "${manifest}" | grep -q '"NSPrivacyTracking" => true'; then
      tracking_flags+=("${manifest}: NSPrivacyTracking=true")
    fi
  done

  if [[ "${#unexpected_data_types[@]}" -eq 0 ]]; then
    pass "No unexpected collected data types in bundled privacy manifests"
  else
    fail "Unexpected collected data types found: $(join_array "${unexpected_data_types[@]}")"
  fi

  if [[ "${#unexpected_purposes[@]}" -eq 0 ]]; then
    pass "No unexpected collected data purposes in bundled privacy manifests"
  else
    fail "Unexpected collected data purposes found: $(join_array "${unexpected_purposes[@]}")"
  fi

  if [[ "${#linked_data_flags[@]}" -eq 0 ]]; then
    pass "Bundled privacy manifests do not link collected data to the user"
  else
    fail "Linked collected data flags found: $(join_array "${linked_data_flags[@]}")"
  fi

  if [[ "${#tracking_flags[@]}" -eq 0 ]]; then
    pass "Bundled privacy manifests do not use tracking"
  else
    fail "Tracking flags found in bundled privacy manifests: $(join_array "${tracking_flags[@]}")"
  fi
}

validate_collected_data_scope

stale_resources="$(find "${app_path}" -maxdepth 2 \( -name "Package.resolved" -o -name "Jacsim-PrivacyReport 2024-03-30 17-45-58.pdf" \) -print)"
if [[ -z "${stale_resources}" ]]; then
  pass "No stale Package.resolved or 2024 privacy report resources"
else
  fail "Stale resources found: ${stale_resources}"
fi

nested_resource_bundles="$(find "${app_path}/Frameworks" -path "*.framework/*.bundle" -print 2>/dev/null | sort || true)"
if [[ -z "${nested_resource_bundles}" ]]; then
  pass "No resource bundles nested inside embedded frameworks"
else
  fail "Resource bundles found inside embedded frameworks: ${nested_resource_bundles}"
fi

forbidden_pattern="GoogleAppMeasurement|Package\\.resolved|PrivacyReport 2024|NSAllowsArbitraryLoads|remote-notification|aps-environment"
if command -v rg >/dev/null 2>&1; then
  if rg -a -q "${forbidden_pattern}" "${app_path}" --glob "!embedded.mobileprovision"; then
    fail "Forbidden archive string found"
  else
    pass "Forbidden archive strings absent outside embedded provisioning profile"
  fi
else
  warn "ripgrep not found; skipping forbidden string scan"
fi

entitlements_file="$(mktemp)"
if codesign -d --entitlements :- "${app_path}" >"${entitlements_file}" 2>/tmp/jacsim-codesign-error.log; then
  if grep -q "aps-environment" "${entitlements_file}"; then
    fail "Signed entitlements include aps-environment"
  else
    pass "Signed entitlements do not include aps-environment"
  fi

  get_task_allow="$(plutil -extract get-task-allow raw -o - "${entitlements_file}" 2>/dev/null || true)"
  if [[ "${get_task_allow}" == "true" ]]; then
    if [[ "${allow_development_signing}" == "true" ]]; then
      warn "Signed entitlements include get-task-allow=true; development signing allowed by option"
    else
      fail "Signed entitlements include get-task-allow=true; use an App Store distribution archive"
    fi
  else
    pass "Signed entitlements are not development-debuggable"
  fi
else
  if [[ "${allow_unsigned}" == "true" ]]; then
    warn "Archive app is unsigned; entitlement check skipped because --allow-unsigned was passed"
  else
    fail "Archive app is unsigned or codesign entitlement extraction failed"
  fi
fi
rm -f "${entitlements_file}" /tmp/jacsim-codesign-error.log

printf '\nVerification summary: %s failure(s), %s warning(s)\n' "${#failures[@]}" "${#warnings[@]}"

if [[ "${#failures[@]}" -gt 0 ]]; then
  exit 1
fi
