# Dependency Injection

`DependenciesProvider` is the composition root.

Providers:
- `ServiceProvider` → `MoviesService`.
- `StoreProvider` → `WatchlistStore`.
- `AssetsProvider` → `MovieDBUIAssets`.
- `RenderProvider` → poster render sizing and shared prefetch dependencies.

## Key Files
- `MoviesDB/App/DI/DependenciesProvider.swift`
- `MoviesDB/App/DI/ServiceProvider.swift`
- `MoviesDB/App/DI/StoreProvider.swift`
- `MoviesDB/App/DI/AssetsProvider.swift`
- `MoviesDB/App/DI/RenderProvider.swift`
