# Data Flow

1. Coordinator builds scene (ViewController + Interactor + Presenter).
2. ViewController calls interactor (`viewDidLoad`, `loadMore`, `didSelect`).
3. Interactor fetches data and emits `State` to presenter.
4. Presenter maps domain models to view models and updates the view.

## Key Files
- `MoviesDB/Scenes/MovieCatalog/Interactor/MovieCatalogInteractor.swift`
- `MoviesDB/Scenes/MovieCatalog/Presenter/MovieCatalogPresenter.swift`
- `MoviesDB/Scenes/MovieCatalog/View/MovieCatalogViewController.swift`
