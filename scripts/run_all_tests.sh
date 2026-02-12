#!/usr/bin/env bash
set -euo pipefail

DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro"
DERIVED_DATA_PATH="/tmp/DerivedData"

xcodebuild -scheme MoviesDB -destination "$DESTINATION" -derivedDataPath "$DERIVED_DATA_PATH" test
xcodebuild -scheme MovieDBUI -destination "$DESTINATION" -derivedDataPath "$DERIVED_DATA_PATH" test
xcodebuild -scheme MovieDBData -destination "$DESTINATION" -derivedDataPath "$DERIVED_DATA_PATH" test
