# Testing

- App tests live in `MoviesDBTests`.
- Data package tests live in `Dependencies/MovieDBData/Tests/MovieDBDataTests`.
- UI package snapshot tests live in `Dependencies/MovieDBUI/Tests/MovieDBUITests`.
- Snapshot assets for images use `MovieDBUI/Sources/Resources/pup.jpg`.

Common commands:
```bash
xcodebuild -scheme MoviesDB -destination 'platform=iOS Simulator,OS=26.2,name=iPhone 17 Pro' test
swift test --package-path Dependencies/MovieDBData
```

For snapshot recording:
```bash
SNAPSHOT_TESTING_RECORD=1 xcodebuild -workspace Dependencies/MovieDBUI/.swiftpm/xcode/package.xcworkspace -scheme MovieDBUI -destination 'platform=iOS Simulator,OS=26.2,name=iPhone 17 Pro' test
```

## Key Files
- `MoviesDBTests`
- `Dependencies/MovieDBData/Tests/MovieDBDataTests`
- `Dependencies/MovieDBUI/Tests/MovieDBUITests`
