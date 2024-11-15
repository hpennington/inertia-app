#!/bin/bash

PROJECT="VibeDemo"

xcodebuild clean archive \
    -allowProvisioningUpdates \
    -scheme "$PROJECT" \
    -configuration release \
    -archivePath "$PWD/build/$PROJECT.xcarchive" \
    -destination "generic/platform=iOS" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_ALLOWED="NO"

xcodebuild -exportArchive \
    -archivePath "$PWD/build/$PROJECT.xcarchive" \
    -exportPath "$PWD/build/ipa" \
    -exportOptionsPlist ExportOptions.plist


cp build/ipa/"$PROJECT.ipa" ~/Library/Containers/com.vectorstudio.Inertia-Pro/Data/Inertia/
