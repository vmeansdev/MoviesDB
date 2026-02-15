# Data Flow

1. Root composes tabs using SwiftUI (`TabView` + `NavigationStack`).
2. View calls view model intents (`onAppear`, `loadMoreIfNeeded`, `toggleWatchlist`, navigation selection).
3. View model fetches data from service/store and maps domain models to UI models.
4. SwiftUI observes view model state and re-renders.

## Key Files
- `MoviesDB/Scenes/Root/RootView.swift`
- `MoviesDB/Scenes/MovieCatalog/View/MovieCatalogView.swift`
- `MoviesDB/Scenes/MovieCatalog/ViewModel/MovieCatalogViewModel.swift`
- `MoviesDB/Scenes/Watchlist/View/WatchlistView.swift`
- `MoviesDB/Scenes/Watchlist/ViewModel/WatchlistViewModel.swift`
