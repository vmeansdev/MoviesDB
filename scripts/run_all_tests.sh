#!/usr/bin/env bash
set -euo pipefail

DESTINATION="platform=iOS Simulator,OS=26.2,name=iPhone 17 Pro"
DERIVED_DATA_PATH="/tmp/DerivedData"

xcodebuild -scheme MoviesDB -destination "$DESTINATION" -derivedDataPath "$DERIVED_DATA_PATH" test

pushd Dependencies/MovieDBData >/dev/null
swift test --package-path .
popd >/dev/null

SNAPSHOT_TESTING_RECORD=0 xcodebuild \
  -workspace Dependencies/MovieDBUI/.swiftpm/xcode/package.xcworkspace \
  -scheme MovieDBUI \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH/MovieDBUI" \
  test
