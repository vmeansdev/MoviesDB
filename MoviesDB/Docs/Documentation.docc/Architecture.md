# Architecture

Each tab scene follows a SwiftUI `View + ViewModel` pattern.

- View models are `@MainActor` and own async loading/state updates.
- Navigation is handled with `NavigationStack`/`navigationDestination`.
- Root composition is a SwiftUI `TabView`.

Scene folders:
- `MoviesDB/Scenes/MovieCatalog/...`
- `MoviesDB/Scenes/MovieDetails/...`
- `MoviesDB/Scenes/Watchlist/...`
- `MoviesDB/Scenes/Root/...`

## Key Files
- `MoviesDB/App/MoviesDBApp.swift`
- `MoviesDB/Scenes/Root/RootView.swift`
- `MoviesDB/Scenes/Root/RootViewModel.swift`
- `MoviesDB/Scenes/MovieCatalog`
- `MoviesDB/Scenes/MovieDetails`
- `MoviesDB/Scenes/Watchlist`
