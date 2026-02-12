# Testing

- App tests live in `MoviesDBTests`.
- UI package snapshot tests live in `Dependencies/MovieDBUI/Tests/MovieDBUITests`.
- Snapshot assets for images use `MovieDBUI/Sources/Resources/pup.jpg`.

Common commands:
```bash
xcodebuild -scheme MoviesDB -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

For snapshot recording:
```bash
SNAPSHOT_TESTING_RECORD=1 xcodebuild -scheme MovieDBUI -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Key Files
- `MoviesDBTests`
- `Dependencies/MovieDBUI/Tests/MovieDBUITests`
