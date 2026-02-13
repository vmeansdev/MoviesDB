# Getting Started

This project depends on API keys and base URLs set in `Info.plist`.

## Required `Info.plist` Keys
- `API_BASE_URL`
- `API_VERSION`
- `API_KEY`
- `API_IMAGES_BASE_URL`

## Key Files
- `MoviesDB/Info.plist`
- `MoviesDB/App/Configuration/Environment.swift`

## Build and Test
```bash
xcodebuild -scheme MoviesDB -destination 'platform=iOS Simulator,OS=26.2,name=iPhone 17 Pro' test
```

Snapshot recording (MovieDBUI):
```bash
SNAPSHOT_TESTING_RECORD=1 xcodebuild -workspace Dependencies/MovieDBUI/.swiftpm/xcode/package.xcworkspace -scheme MovieDBUI -destination 'platform=iOS Simulator,OS=26.2,name=iPhone 17 Pro' test
```
