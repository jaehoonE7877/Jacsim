#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

workspace_plist="${repo_root}/Projects/Jacsim/Resources/GoogleService-Info.plist"
default_local_plist="${HOME}/Downloads/GoogleService-Info.plist"
source_plist="${JACSIM_GOOGLE_SERVICE_INFO_PLIST:-}"

if [ -n "${source_plist}" ]; then
  if [ ! -f "${source_plist}" ]; then
    echo "error: JACSIM_GOOGLE_SERVICE_INFO_PLIST points to a missing file: ${source_plist}" >&2
    exit 1
  fi
elif [ -f "${workspace_plist}" ]; then
  source_plist="${workspace_plist}"
elif [ -f "${default_local_plist}" ]; then
  source_plist="${default_local_plist}"
else
  echo "error: Missing GoogleService-Info.plist." >&2
  echo "Expected one of:" >&2
  echo "  - ${workspace_plist}" >&2
  echo "  - ${default_local_plist}" >&2
  echo "Or set JACSIM_GOOGLE_SERVICE_INFO_PLIST to a local plist path." >&2
  exit 1
fi

if ! /usr/bin/plutil -lint "${source_plist}" >/dev/null; then
  echo "error: Invalid GoogleService-Info.plist: ${source_plist}" >&2
  exit 1
fi

mkdir -p "$(dirname "${workspace_plist}")"
if [ "${source_plist}" != "${workspace_plist}" ]; then
  /bin/cp "${source_plist}" "${workspace_plist}"
fi

bundle_plist=""
if [ -n "${SCRIPT_OUTPUT_FILE_0:-}" ]; then
  bundle_plist="${SCRIPT_OUTPUT_FILE_0}"
elif [ -n "${TARGET_BUILD_DIR:-}" ] && [ -n "${UNLOCALIZED_RESOURCES_FOLDER_PATH:-}" ]; then
  bundle_plist="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"
fi

if [ -n "${bundle_plist}" ]; then
  mkdir -p "$(dirname "${bundle_plist}")"
  /bin/cp "${workspace_plist}" "${bundle_plist}"
fi

echo "Prepared GoogleService-Info.plist for local build."
