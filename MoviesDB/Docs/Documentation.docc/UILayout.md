# UI Layout

- `MovieCatalogView` (SwiftUI) is shared by Popular/Top Rated.
- Layout adapts by size:
  - Compact iPhone: single-column list.
  - iPad and iPhone Max landscape: grid (3 columns on phone, adaptive on iPad).
- Watchlist mirrors the same layout behavior.

## Key Files
- `MoviesDB/Scenes/MovieCatalog/View/MovieCatalogView.swift`
- `MoviesDB/Scenes/MovieCatalog/MovieGridLayout.swift`
- `MoviesDB/Scenes/Watchlist/View/WatchlistView.swift`
