# Adding a New Scene

1. Create a new scene folder with Coordinator, Interactor, Presenter, ViewController.
2. Add a new `State` type and presenter mapping to view models.
3. Wire it in `CoordinatorProvider` and `RootCoordinator`.
4. Add tests in `MoviesDBTests`.

## Key Files
- `MoviesDB/Scenes`
- `MoviesDB/App/DI/CoordinatorProvider.swift`
- `MoviesDB/App/Architecture/RootCoordinator.swift`
- `MoviesDBTests`
