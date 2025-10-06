#!/bin/bash

PROJECT="DemoApp"
SCHEME="DemoAppInertiaEditor"

xcodebuild clean archive \
    -project "$PROJECT.xcodeproj" \
    -allowProvisioningUpdates \
    -scheme "$SCHEME" \
    -configuration release \
    -archivePath "$PWD/build/$PROJECT.xcarchive" \
    -destination "generic/platform=iOS" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_ALLOWED="NO"

xcodebuild -exportArchive \
    -archivePath "$PWD/build/$PROJECT.xcarchive" \
    -exportPath "$PWD/build/ipa" \
    -exportOptionsPlist ExportOptions.plist


cp build/ipa/"DemoAppInertiaEditor.ipa" ~/InertiaStorage/
