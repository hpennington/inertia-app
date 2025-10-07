#!/bin/bash
set -euo pipefail

# --- Configuration ---
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PATH="${PROJECT_DIR}/../example/InertiaDemoCompose/DemoApp"
DEST_DIR="${HOME}/InertiaStorage"
APK_NAME="app-debug.apk"
OUTPUT_PATH="${SOURCE_PATH}/app/build/outputs/apk/debug/${APK_NAME}"

# --- Execution ---
echo "Building Android project at: ${SOURCE_PATH}"
pushd "${SOURCE_PATH}" > /dev/null

# Build the debug APK
./gradlew assembleDebug

# Copy the built APK to destination
echo "Copying ${APK_NAME} to ${DEST_DIR}..."
cp "${OUTPUT_PATH}" "${DEST_DIR}/"

popd > /dev/null
echo "✅ Build complete: ${DEST_DIR}/${APK_NAME}"

