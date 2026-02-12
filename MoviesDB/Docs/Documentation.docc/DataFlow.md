# Data Flow

1. Coordinator builds scene (ViewController + Interactor + Presenter).
2. ViewController calls interactor (`viewDidLoad`, `loadMore`, `didSelect`).
3. Interactor fetches data and emits `State` to presenter.
4. Presenter maps domain models to view models and updates the view.

## Key Files
- `MoviesDB/Scenes/Popular/Interactor/PopularInteractor.swift`
- `MoviesDB/Scenes/Popular/Presenter/PopularPresenter.swift`
- `MoviesDB/Scenes/Popular/View/PopularViewController.swift`
- `MoviesDB/Scenes/TopRated/Interactor/TopRatedInteractor.swift`
- `MoviesDB/Scenes/TopRated/Presenter/TopRatedPresenter.swift`
- `MoviesDB/Scenes/TopRated/View/TopRatedViewController.swift`
