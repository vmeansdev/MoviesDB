# MoviesDB

<p align="center">
  <img src="MoviesDB/Resources/Assets.xcassets/AppIcon.appiconset/dark_icon.png" width="180" alt="MoviesDB App Icon" />
</p>

<p align="center">
  <img src="https://github.com/vmeansdev/MoviesDB/actions/workflows/ci.yml/badge.svg" alt="CI Status" />
</p>

MoviesDB is a Swift 6 iOS application that delivers a fast, elegant movie browsing experience with a clean, testable architecture and a UI that scales from iPhone to iPad. The project is built to be production-ready: strict concurrency checks, modular packages, structured documentation, and a fully automated test pipeline.

**Highlights**
- Swift 6 codebase with strict concurrency checks enabled.
- Clean module split: `MoviesDB` (app), `MovieDBUI` (UI kit), `MovieDBData` (data layer).
- VIP-style scene flow with coordinators, presenters, and interactors.
- Grid layouts that adapt to iPad and iPhone Max landscape.
- Snapshot tests for UI components and full unit test coverage for core flows.
- DocC documentation under `MoviesDB/Docs/Documentation.docc`.

**Architecture At A Glance**
- **UI layer**: `MovieDBUI` contains reusable view controllers, views, and UI assets.
- **App layer**: `MoviesDB` composes scenes, handles routing, and wires dependencies.
- **Data layer**: `MovieDBData` owns models, caching, networking, and domain logic.
- **DI**: Providers and builders assemble scenes with explicit dependencies.

**Requirements**
- Xcode 16+ (Swift 6)
- iOS 18 deployment target

**Quick Start**
1. Open `MoviesDB.xcodeproj`.
2. Select the `MoviesDB` scheme.
3. Run on any iOS 18+ simulator or device.

**Running Tests**
- Run everything:
  ```bash
  ./scripts/run_all_tests.sh
  ```
- App tests:
  ```bash
  xcodebuild -scheme MoviesDB -destination 'platform=iOS Simulator,OS=18.5,name=iPhone 16 Pro' test
  ```
- UI package tests:
  ```bash
  SNAPSHOT_TESTING_RECORD=0 xcodebuild -workspace Dependencies/MovieDBUI/.swiftpm/xcode/package.xcworkspace -scheme MovieDBUI -destination 'platform=iOS Simulator,OS=18.5,name=iPhone 16 Pro' test
  ```
- Data package tests:
  ```bash
  swift test --package-path Dependencies/MovieDBData
  ```

**Documentation**
Open the DocC catalog at `MoviesDB/Docs/Documentation.docc` to explore:
- Architecture and data flow
- Networking stack
- Dependency injection
- UI layout strategy
- Concurrency model
- Testing and snapshot strategy

**CI**
A GitHub Actions workflow runs tests for `MoviesDB`, `MovieDBUI`, and `MovieDBData` on every branch push and PR, and also supports manual runs (`workflow_dispatch`).

**Project Structure**
- `MoviesDB/` — App target
- `Dependencies/MovieDBUI/` — Reusable UI components and assets
- `Dependencies/MovieDBData/` — Data and networking layer
- `MoviesDBTests/` — App tests
- `MoviesDB/Docs/` — DocC documentation
