# Concurrency

- Swift 6 mode is enabled.
- View models are `@MainActor` and own async loading/state updates.
- Services and stores are async boundaries (`MoviesService`, watchlist store stream/toggle).
- UI state changes are performed on main actor only.

## Key Files
- `MoviesDB/Scenes/MovieCatalog/ViewModel/MovieCatalogViewModel.swift`
- `MoviesDB/Scenes/Watchlist/ViewModel/WatchlistViewModel.swift`
- `MoviesDB/Scenes/MovieDetails/Model/MovieDetailsViewModel.swift`
