#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/release/preflight-appstore-2.0.sh --archive PATH --support-url URL [options]

Runs the Jacsim 2.0 App Store preflight checks that can be automated:
- Source-level release-sensitive checks
- Public Privacy Policy and Support URL checks
- Archive privacy, resource, Info.plist, and signing checks
- Explicit confirmation gates for manual App Store Connect and device smoke-test work

Required for a real submission preflight:
  --archive PATH
  --support-url URL
  --confirm-app-store-connect
  --confirm-device-smoke-test

Options:
  --privacy-url URL                    Defaults to https://sjh7877.tistory.com/19
  --expected-support-privacy-url URL   Defaults to the privacy URL
  --dry-run                            Allows file:// URLs and non-distribution signing checks
  --allow-unsigned                     Local dry-run only; forwards to archive verifier
  --allow-development-signing          Local dry-run only; forwards to archive verifier
  -h, --help
EOF
}

archive_path=""
privacy_url="https://sjh7877.tistory.com/19"
support_url=""
expected_support_privacy_url=""
allow_unsigned="false"
allow_development_signing="false"
confirm_app_store_connect="false"
confirm_device_smoke_test="false"
dry_run="false"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --archive)
      archive_path="${2:-}"
      shift 2
      ;;
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
    --dry-run)
      dry_run="true"
      shift
      ;;
    --allow-unsigned)
      allow_unsigned="true"
      shift
      ;;
    --allow-development-signing)
      allow_development_signing="true"
      shift
      ;;
    --confirm-app-store-connect)
      confirm_app_store_connect="true"
      shift
      ;;
    --confirm-device-smoke-test)
      confirm_device_smoke_test="true"
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

is_file_url() {
  [[ "$1" == file://* ]]
}

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

check_release_artifacts_are_tracked() {
  local required_paths=(
    "AppStore/privacy-policy-2.0-publish.md"
    "AppStore/support-page-publish.md"
    "AppStore/public/privacy-policy.html"
    "AppStore/public/support.html"
    "AppStore/app-store-connect-privacy-label.md"
    "AppStore/app-review-notes-submit.md"
    "AppStore/device-smoke-test-checklist.md"
    "AppStore/submission-runbook.md"
    "AppStore/completion-audit.md"
    "AppStore/release-readiness-audit.md"
    "scripts/release/verify-public-release-pages.sh"
    "scripts/release/verify-jacsim-archive.sh"
    "scripts/release/preflight-appstore-2.0.sh"
  )

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    warn "Git worktree not detected; release artifact tracking check skipped"
    return
  fi

  local untracked=()
  local path
  for path in "${required_paths[@]}"; do
    if ! git ls-files --error-unmatch "${path}" >/dev/null 2>&1; then
      untracked+=("${path}")
    fi
  done

  if [[ "${#untracked[@]}" -eq 0 ]]; then
    pass "Release submission artifacts are tracked by git"
  elif [[ "${dry_run}" == "true" ]]; then
    warn "Release submission artifacts are not tracked yet: ${untracked[*]}"
  else
    fail "Release submission artifacts are not tracked by git: ${untracked[*]}"
  fi
}

require_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"

  if [[ ! -f "${file}" ]]; then
    fail "${label}: file missing at ${file}"
    return
  fi

  if grep -Fq "${pattern}" "${file}"; then
    pass "${label}"
  else
    fail "${label} missing (${pattern})"
  fi
}

require_no_matches() {
  local pattern="$1"
  local label="$2"
  shift 2

  if ! command -v rg >/dev/null 2>&1; then
    warn "ripgrep not found; ${label} skipped"
    return
  fi

  if rg -q "${pattern}" "$@"; then
    fail "${label}"
  else
    pass "${label}"
  fi
}

run_step() {
  local label="$1"
  shift

  printf '\n== %s ==\n' "${label}"
  if "$@"; then
    pass "${label}"
  else
    fail "${label}"
  fi
}

printf 'Jacsim 2.0 App Store preflight\n'

if [[ "${dry_run}" == "true" ]]; then
  warn "Dry-run mode enabled; local URLs and non-distribution signing are allowed for validation only"
else
  if is_file_url "${privacy_url}" || is_file_url "${support_url}" || is_file_url "${expected_support_privacy_url}"; then
    fail "Real App Store preflight cannot use file:// URLs; publish public pages first or pass --dry-run"
  fi

  if [[ "${allow_unsigned}" == "true" || "${allow_development_signing}" == "true" ]]; then
    fail "Real App Store preflight cannot allow unsigned or development-signed archives; pass --dry-run for local validation only"
  fi
fi

require_file "AppStore/privacy-policy-2.0-publish.md" "Privacy policy markdown publish draft"
require_file "AppStore/support-page-publish.md" "Support page markdown publish draft"
require_file "AppStore/public/privacy-policy.html" "Privacy policy HTML publish draft"
require_file "AppStore/public/support.html" "Support page HTML publish draft"
require_file "AppStore/app-store-connect-privacy-label.md" "App Store privacy label memo"
require_file "AppStore/app-review-notes-submit.md" "App Review notes draft"
require_file "AppStore/device-smoke-test-checklist.md" "Physical device smoke-test checklist"
require_file "AppStore/submission-runbook.md" "Submission runbook"
require_file "scripts/release/verify-public-release-pages.sh" "Public pages verifier"
require_file "scripts/release/verify-jacsim-archive.sh" "Archive verifier"

check_release_artifacts_are_tracked

require_contains \
  "Projects/Jacsim/Sources/Presentation/Setting/SettingView.swift" \
  "sjh7877@naver.com" \
  "Settings support email matches public support email"

require_contains \
  "Projects/Jacsim/Sources/Presentation/Setting/SettingView.swift" \
  "https://sjh7877.tistory.com/19" \
  "Settings privacy URL matches App Store privacy URL"

require_contains \
  "AppStore/device-smoke-test-checklist.md" \
  "디바이스 회전 smoke check" \
  "Physical device smoke-test checklist includes rotation check"

require_contains \
  "AppStore/device-smoke-test-checklist.md" \
  "portrait와 landscape left/right" \
  "Physical device smoke-test checklist covers supported orientations"

require_contains \
  "AppStore/device-smoke-test-checklist.md" \
  "SwiftData migration crash" \
  "Physical device smoke-test checklist covers SwiftData migration"

require_contains \
  "Projects/Jacsim/Sources/Presentation/Common/ImageAttachmentPicker.swift" \
  "사진 찍기" \
  "Common image attachment picker includes camera action"

require_contains \
  "Projects/Jacsim/Sources/Presentation/Common/ImageAttachmentPicker.swift" \
  "앨범에서 선택" \
  "Common image attachment picker includes album action"

require_contains \
  "Projects/Modules/DSKit/Sources/SwiftUI/Components/JSPhotoPicker.swift" \
  "사진 찍기" \
  "DSKit photo picker includes camera action"

require_contains \
  "Projects/Modules/DSKit/Sources/SwiftUI/Components/JSPhotoPicker.swift" \
  "앨범에서 선택" \
  "DSKit photo picker includes album action"

require_contains \
  "Projects/Jacsim/Sources/Presentation/NewTask/NewTaskView.swift" \
  "ImageAttachmentPicker(" \
  "New task image attachment uses common camera-and-album picker"

require_contains \
  "Projects/Jacsim/Sources/Presentation/TaskDetail/TaskEditView.swift" \
  "ImageAttachmentPicker(" \
  "Task edit image attachment uses common camera-and-album picker"

require_contains \
  "Projects/Jacsim/Sources/Presentation/TaskUpdate/TaskUpdateView.swift" \
  "ImageAttachmentPicker(" \
  "Daily update image attachment uses common camera-and-album picker"

require_no_matches \
  "PhotosPicker|PhotosPickerItem|\\.photosPicker|UIImagePickerController|JSPhotoPicker" \
  "Presentation image attachment callsites do not bypass ImageAttachmentPicker" \
  "Projects/Jacsim/Sources/Presentation" \
  --glob '!**/Common/ImageAttachmentPicker.swift'

require_contains \
  "Projects/Data/Sources/Adapters/DocumentImageStoreAdapter.swift" \
  "jpegData(compressionQuality:" \
  "Image store recompresses images before storage"

require_contains \
  "Projects/Data/Sources/Adapters/DocumentImageStoreAdapter.swift" \
  "resizedForStorage" \
  "Image store resizes images before storage"

require_contains \
  "Projects/Data/Sources/Adapters/DocumentImageStoreAdapter.swift" \
  "UIImage(data: data)" \
  "Image store rejects non-image data"

require_contains \
  "Projects/Data/Sources/Adapters/DocumentImageStoreAdapter.swift" \
  "lastPathComponent" \
  "Image store rejects path-traversal keys"

require_contains \
  "Projects/Data/Sources/Adapters/DocumentImageStoreAdapter.swift" \
  "FileProtectionType.completeUntilFirstUserAuthentication" \
  "Image store applies file protection"

require_contains \
  "Projects/Jacsim/Sources/Presentation/NewTask/NewTaskFeature.swift" \
  "makeImageStoreInputData(from: image)" \
  "New task image save encodes image input before storage"

require_contains \
  "Projects/Jacsim/Sources/Presentation/TaskDetail/TaskDetailFeature.swift" \
  "makeImageStoreInputData(from: image)" \
  "Task edit image save encodes image input before storage"

require_contains \
  "Projects/Jacsim/Sources/Presentation/TaskUpdate/TaskUpdateFeature.swift" \
  "makeImageStoreInputData(from: image)" \
  "Daily update image save encodes image input before storage"

require_contains \
  "Projects/Modules/DSKit/Sources/SwiftUI/Components/JSBottomSheet.swift" \
  "allowsInteractiveDismiss: Bool = false" \
  "Bottom sheet background/drag dismissal defaults off"

require_contains \
  "Projects/Modules/DSKit/Sources/SwiftUI/Components/JSModal.swift" \
  "allowsBackdropDismiss: Bool = false" \
  "Modal backdrop dismissal defaults off"

require_contains \
  "Projects/Jacsim/Sources/Presentation/ChallengeCreate/ChallengeCreateView.swift" \
  ".interactiveDismissDisabled(true)" \
  "Challenge creation sheet disables swipe/background dismissal"

require_contains \
  "Projects/Jacsim/Sources/Presentation/Home/HomeView.swift" \
  ".interactiveDismissDisabled(true)" \
  "Home challenge creation sheet disables interactive dismissal"

require_contains \
  "Projects/Jacsim/Sources/Presentation/TaskDetail/TaskDetailView.swift" \
  ".interactiveDismissDisabled(true)" \
  "Task edit sheet disables interactive dismissal"

require_contains \
  "Projects/Jacsim/Sources/Presentation/NewTask/NewTaskFeature.swift" \
  "hasDraftContent" \
  "New task reducer detects draft content before cancel"

require_contains \
  "Projects/Jacsim/Sources/Presentation/NewTask/NewTaskFeature.swift" \
  "confirmDiscard" \
  "New task reducer requires discard confirmation"

require_contains \
  "Projects/Jacsim/Sources/Presentation/NewTask/NewTaskView.swift" \
  '.alert($store.scope(state: \.alert, action: \.alert))' \
  "New task view presents discard confirmation alert"

require_no_matches \
  "allowsInteractiveDismiss:[[:space:]]*true|allowsBackdropDismiss:[[:space:]]*true" \
  "Presentation code does not opt into background/drag modal dismissal" \
  "Projects/Jacsim/Sources/Presentation"

run_step \
  "Release plists lint" \
  plutil -lint \
    "Projects/Jacsim/Resources/PrivacyInfo.xcprivacy" \
    "Projects/Jacsim/Info.plist" \
    "Projects/Jacsim/Jacsim.entitlements"

printf '\n== Forbidden source signals ==\n'
if command -v rg >/dev/null 2>&1; then
  if rg -q "FirebaseAnalytics|FirebaseMessaging|GoogleAppMeasurement|remote-notification|NSAllowsArbitraryLoads|aps-environment" \
    Projects Plugins Tuist \
    --glob '!**/Derived/**'; then
    fail "Forbidden release-sensitive source signal found"
  else
    pass "Forbidden release-sensitive source signals absent"
  fi
else
  warn "ripgrep not found; source forbidden-signal scan skipped"
fi

public_args=(
  --privacy-url "${privacy_url}"
  --support-url "${support_url}"
  --expected-support-privacy-url "${expected_support_privacy_url}"
)

if [[ -z "${support_url}" ]]; then
  fail "Support URL is required for App Store preflight"
else
  run_step "Public Privacy Policy and Support URL verification" \
    scripts/release/verify-public-release-pages.sh "${public_args[@]}"
fi

archive_args=()
if [[ "${allow_unsigned}" == "true" ]]; then
  archive_args+=(--allow-unsigned)
  warn "--allow-unsigned is enabled; this is not an App Store submission pass"
fi

if [[ "${allow_development_signing}" == "true" ]]; then
  archive_args+=(--allow-development-signing)
  warn "--allow-development-signing is enabled; this is not an App Store submission pass"
fi

if [[ -z "${archive_path}" ]]; then
  fail "Archive path is required for App Store preflight"
elif [[ "${#archive_args[@]}" -eq 0 ]]; then
  run_step "Archive verification" \
    scripts/release/verify-jacsim-archive.sh "${archive_path}"
else
  run_step "Archive verification" \
    scripts/release/verify-jacsim-archive.sh "${archive_args[@]}" "${archive_path}"
fi

if [[ "${confirm_app_store_connect}" == "true" ]]; then
  pass "App Store Connect privacy label, URLs, and review notes manually confirmed"
else
  fail "App Store Connect privacy label, URLs, and review notes are not confirmed"
fi

if [[ "${confirm_device_smoke_test}" == "true" ]]; then
  pass "Physical device camera/photo smoke test manually confirmed"
else
  fail "Physical device camera/photo smoke test is not confirmed"
fi

printf '\nPreflight summary: %s failure(s), %s warning(s)\n' "${#failures[@]}" "${#warnings[@]}"

if [[ "${#failures[@]}" -gt 0 ]]; then
  exit 1
fi
