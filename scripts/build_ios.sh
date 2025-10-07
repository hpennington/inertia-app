#!/bin/bash
set -euo pipefail

# --- Configuration ---
PROJECT="DemoApp"
SCHEME="DemoAppInertiaEditor"

# Expand ~ to full path
SOURCE_PATH="${HOME}/Developer/inertia-app/example/InertiaDemo"
OUTPUT_DIR="${SOURCE_PATH}/build"
EXPORT_PLIST="${HOME}/Developer/inertia-app/scripts/ExportOptions.plist"
DEST_DIR="${HOME}/InertiaStorage"

# --- Execution ---
echo "Building project at: ${SOURCE_PATH}"
cd "${SOURCE_PATH}"

# Clean and archive
xcodebuild clean archive \
  -project "${PROJECT}.xcodeproj" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -archivePath "${OUTPUT_DIR}/${PROJECT}.xcarchive" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_ALLOWED="NO"

# Export IPA
xcodebuild -exportArchive \
  -archivePath "${OUTPUT_DIR}/${PROJECT}.xcarchive" \
  -exportPath "${OUTPUT_DIR}/ipa" \
  -exportOptionsPlist "${EXPORT_PLIST}"

# Copy final IPA to destination folder
IPA_PATH="${OUTPUT_DIR}/ipa/${SCHEME}.ipa"
echo "Copying IPA to ${DEST_DIR}..."
cp "${IPA_PATH}" "${DEST_DIR}/"

echo "✅ Build and export complete: ${DEST_DIR}/${SCHEME}.ipa"

