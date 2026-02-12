# UI Layout

- `MovieListViewController` (UIKit) is shared by Popular/TopRated.
- Layout adapts by size:
  - Compact iPhone: single-column list.
  - iPad and iPhone Max landscape: grid (3 columns on phone, adaptive on iPad).
- Watchlist (SwiftUI) mirrors the same layout behavior.

## Key Files
- `Dependencies/MovieDBUI/Sources/MovieDBUI/ViewControllers/MovieList/MovieListViewController.swift`
- `MoviesDB/Scenes/Watchlist/View/WatchlistView.swift`
