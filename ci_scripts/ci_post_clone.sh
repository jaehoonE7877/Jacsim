#!/usr/bin/env bash
set -euo pipefail

echo "==> Xcode Cloud post-clone setup started"

if ! command -v tuist >/dev/null 2>&1; then
  echo "Installing Tuist..."
  curl -Ls https://install.tuist.io | bash
  export PATH="$HOME/.tuist/bin:$PATH"
fi

echo "Using Tuist: $(tuist version)"

echo "Installing dependencies..."
tuist install

echo "Restoring GoogleService-Info.plist..."
bash scripts/ci/prepare-google-service-info.sh

echo "Generating workspace..."
tuist generate --no-open

echo "==> Xcode Cloud post-clone setup completed"
