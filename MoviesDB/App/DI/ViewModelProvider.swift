import MovieDBData
import MovieDBUI

@MainActor
protocol ViewModelProviderProtocol {
    func makeMovieCatalogViewModel(kind: MovieCatalogViewModel.Kind) -> MovieCatalogViewModel
    func makeWatchlistViewModel() -> WatchlistViewModel
    func makeMovieDetailsViewModel(movie: Movie) -> MovieDetailsViewModel
}

@MainActor
final class ViewModelProvider: ViewModelProviderProtocol {
    private let serviceProvider: ServiceProviderProtocol
    private let assetsProvider: AssetsProviderProtocol
    private let storeProvider: StoreProviderProtocol
    private let renderProvider: RenderProviderProtocol

    init(
        serviceProvider: ServiceProviderProtocol,
        assetsProvider: AssetsProviderProtocol,
        storeProvider: StoreProviderProtocol,
        renderProvider: RenderProviderProtocol
    ) {
        self.serviceProvider = serviceProvider
        self.assetsProvider = assetsProvider
        self.storeProvider = storeProvider
        self.renderProvider = renderProvider
    }

    func makeMovieCatalogViewModel(kind: MovieCatalogViewModel.Kind) -> MovieCatalogViewModel {
        MovieCatalogViewModel(
            kind: kind,
            moviesService: serviceProvider.moviesService,
            watchlistStore: storeProvider.watchlistStore,
            uiAssets: assetsProvider.uiAssets,
            posterPrefetchController: renderProvider.makePosterPrefetchController()
        )
    }

    func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(
            watchlistStore: storeProvider.watchlistStore,
            uiAssets: assetsProvider.uiAssets,
            posterPrefetchController: renderProvider.makePosterPrefetchController()
        )
    }

    func makeMovieDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movie: movie,
            moviesService: serviceProvider.moviesService,
            watchlistStore: storeProvider.watchlistStore,
            uiAssets: assetsProvider.uiAssets
        )
    }
}
