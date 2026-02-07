#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

cd "${REPO_ROOT}"

echo "==> Xcode Cloud post-clone setup started"
echo "Repository root: ${REPO_ROOT}"

run_tuist() {
  if command -v tuist >/dev/null 2>&1; then
    tuist "$@"
  else
    mise exec -- tuist "$@"
  fi
}

if ! command -v tuist >/dev/null 2>&1; then
  echo "Installing Tuist via mise..."
  if ! command -v mise >/dev/null 2>&1; then
    curl -fsSL https://mise.jdx.dev/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
  mise install
fi

echo "Using Tuist: $(run_tuist version)"

echo "Installing dependencies..."
run_tuist install

echo "Restoring GoogleService-Info.plist..."
bash scripts/ci/prepare-google-service-info.sh

build_number="${CI_BUILD_NUMBER:-1}"
if ! [[ "${build_number}" =~ ^[0-9]+$ ]]; then
  echo "CI_BUILD_NUMBER is invalid (${CI_BUILD_NUMBER:-unset}). Falling back to 1."
  build_number="1"
fi
echo "Using build number: ${build_number}"

echo "Generating workspace..."
TUIST_APP_BUILD_NUMBER="${build_number}" run_tuist generate --no-open

echo "==> Xcode Cloud post-clone setup completed"
