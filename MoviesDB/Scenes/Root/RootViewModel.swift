import MovieDBData
import MovieDBUI
import Observation

@MainActor
@Observable
final class RootViewModel {
    let popularViewModel: MovieCatalogViewModel
    let topRatedViewModel: MovieCatalogViewModel
    let watchlistViewModel: WatchlistViewModel
    let posterRenderSizeProvider: any PosterRenderSizeProviding

    private let serviceProvider: ServiceProviderProtocol
    private let assetsProvider: AssetsProviderProtocol
    private let storeProvider: StoreProviderProtocol

    init(dependenciesProvider: DependenciesProviderProtocol) {
        self.serviceProvider = dependenciesProvider.serviceProvider
        self.assetsProvider = dependenciesProvider.assetsProvider
        self.storeProvider = dependenciesProvider.storeProvider
        self.posterRenderSizeProvider = dependenciesProvider.renderProvider.posterRenderSizeProvider
        self.popularViewModel = MovieCatalogViewModel(
            kind: .popular,
            moviesService: serviceProvider.moviesService,
            watchlistStore: storeProvider.watchlistStore,
            uiAssets: assetsProvider.uiAssets,
            posterPrefetchController: dependenciesProvider.renderProvider.makePosterPrefetchController()
        )
        self.topRatedViewModel = MovieCatalogViewModel(
            kind: .topRated,
            moviesService: serviceProvider.moviesService,
            watchlistStore: storeProvider.watchlistStore,
            uiAssets: assetsProvider.uiAssets,
            posterPrefetchController: dependenciesProvider.renderProvider.makePosterPrefetchController()
        )
        self.watchlistViewModel = WatchlistViewModel(
            watchlistStore: storeProvider.watchlistStore,
            uiAssets: assetsProvider.uiAssets,
            posterPrefetchController: dependenciesProvider.renderProvider.makePosterPrefetchController()
        )
    }

    var tabAssets: MovieDBUIAssetsProtocol { assetsProvider.uiAssets }

    func makeMovieDetailsViewModel(movie: Movie, isInWatchlist: Bool) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movie: movie,
            isInWatchlist: isInWatchlist,
            moviesService: serviceProvider.moviesService,
            watchlistStore: storeProvider.watchlistStore,
            uiAssets: assetsProvider.uiAssets
        )
    }
}
