# Concurrency

- Swift 6 mode is enabled.
- Interactors are actors and own async flows.
- Presenters are `@MainActor`.
- UI updates happen on the main actor only.

## Key Files
- `MoviesDB/Scenes/Popular/Interactor/PopularInteractor.swift`
- `MoviesDB/Scenes/TopRated/Interactor/TopRatedInteractor.swift`
- `MoviesDB/Scenes/Popular/Presenter/PopularPresenter.swift`
- `MoviesDB/Scenes/TopRated/Presenter/TopRatedPresenter.swift`
