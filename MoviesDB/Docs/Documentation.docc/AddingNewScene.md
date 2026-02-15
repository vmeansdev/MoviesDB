# Adding a New Scene

1. Create a scene folder with `View`, `ViewModel`, and mapper/helpers as needed.
2. Keep the screen in SwiftUI and use `NavigationStack`/`navigationDestination` for drill-down.
3. Inject all dependencies through `DependenciesProvider` and its providers.
4. Add unit tests in `MoviesDBTests` and snapshots in `MovieDBUI` tests for reusable components.

## Key Files
- `MoviesDB/Scenes`
- `MoviesDB/App/DI/DependenciesProvider.swift`
- `MoviesDB/App/DI/RenderProvider.swift`
- `MoviesDBTests`
