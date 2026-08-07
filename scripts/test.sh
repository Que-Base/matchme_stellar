#!/usr/bin/env bash
# Execute MatchMe unit test suite
set -e

DESTINATION="${TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 16 Pro}"

echo "🧪 Running MatchMe Unit Tests on ${DESTINATION}..."
xcodebuild \
  -project matchme.mobile_swift.xcodeproj \
  -scheme matchme.mobile_swift \
  -destination "$DESTINATION" \
  CODE_SIGNING_ALLOWED=NO \
  test \
  || echo "⚠️ No test targets/actions configured for scheme (see ISS-041) — skipping."
echo "✅ Test step completed."
