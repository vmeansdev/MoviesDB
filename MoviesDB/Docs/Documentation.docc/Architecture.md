# Architecture

Each tab scene follows a Coordinator → Interactor → Presenter → View pattern.

- Interactors are actors.
- Presenters are `@MainActor`.
- View controllers are UIKit and conform to `MovieListPresentable`.

Scene folders:
- `MoviesDB/Scenes/Popular/...`
- `MoviesDB/Scenes/TopRated/...`
- `MoviesDB/Scenes/MovieDetails/...`
- `MoviesDB/Scenes/Watchlist/...`

## Key Files
- `MoviesDB/App/Architecture/Coordinator.swift`
- `MoviesDB/App/Architecture/RootCoordinator.swift`
- `MoviesDB/Scenes/Popular`
- `MoviesDB/Scenes/TopRated`
- `MoviesDB/Scenes/MovieDetails`
- `MoviesDB/Scenes/Watchlist`
