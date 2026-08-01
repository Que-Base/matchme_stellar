#!/usr/bin/env bash
# Build MatchMe Xcode iOS app scheme
set -e

echo "🔨 Building MatchMe iOS Project..."
xcodebuild \
  -project matchme.mobile_swift.xcodeproj \
  -scheme matchme.mobile_swift \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
echo "✅ Build succeeded."
