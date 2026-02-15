# Concurrency

- Swift 6 mode is enabled.
- Interactors are actors and own async flows.
- Presenters are `@MainActor`.
- UI updates happen on the main actor only.

## Key Files
- `MoviesDB/Scenes/MovieCatalog/Interactor/MovieCatalogInteractor.swift`
- `MoviesDB/Scenes/MovieCatalog/Presenter/MovieCatalogPresenter.swift`
