#!/bin/bash
set -euo pipefail

# --- Configuration ---
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_PATH="${PROJECT_DIR}/../runtime-web"
PACKAGES=("inertia-base" "inertia-react")

# --- Execution ---
echo "🔧 Starting web package builds..."
echo "Base path: ${BASE_PATH}"
echo

for PKG in "${PACKAGES[@]}"; do
  PACKAGE_PATH="${BASE_PATH}/${PKG}"
  
  echo "📦 Building ${PKG}..."
  if [[ ! -d "${PACKAGE_PATH}" ]]; then
    echo "❌ Directory not found: ${PACKAGE_PATH}"
    exit 1
  fi

  pushd "${PACKAGE_PATH}" > /dev/null

  # Ensure dependencies are installed cleanly
  echo "→ Installing dependencies..."
  npm ci
  rm -rf node_modules/react
  rm -rf node_modules/react-dom

  # Run the build
  echo "→ Running build..."
  npm run build

  popd > /dev/null
  echo "✅ Finished building ${PKG}"
  echo
done

echo "🎉 All web packages built successfully!"

