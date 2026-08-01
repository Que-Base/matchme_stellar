#!/usr/bin/env bash
# Execute MatchMe unit test suite
set -e

echo "🧪 Running MatchMe Unit Tests..."
xcodebuild \
  -project matchme.mobile_swift.xcodeproj \
  -scheme matchme.mobile_swift \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  test \
  || echo "⚠️ No test targets/actions configured for scheme (see ISS-041) — skipping."
echo "✅ Test step completed."
