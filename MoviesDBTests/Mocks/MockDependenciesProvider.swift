import MovieDBUI
@testable import MoviesDB

@MainActor
final class MockDependenciesProvider: DependenciesProviderProtocol {
    let coordinatorProvider: CoordinatorProviderProtocol
    let serviceProvider: ServiceProviderProtocol
    let assetsProvider: AssetsProviderProtocol
    let storeProvider: StoreProviderProtocol
    let posterImagePrefetcher: any PosterImagePrefetching
    let posterURLProvider: any PosterURLProviding

    init() {
        serviceProvider = MockServiceProvider(moviesService: MockMoviesService())
        coordinatorProvider = MockCoordinatorProvider()
        assetsProvider = AssetsProvider(uiAssets: MovieDBUIAssets.system)
        storeProvider = StoreProvider(watchlistStore: MockWatchlistStore())
        posterImagePrefetcher = PosterImagePrefetcher.shared
        posterURLProvider = PosterURLProvider(imageBaseURLString: "https://image.tmdb.org")
    }

    func makePosterPrefetchController() -> any PosterPrefetchControlling {
        PosterPrefetchController(posterImagePrefetcher: posterImagePrefetcher)
    }

    func makePosterRenderSizeProvider() -> any PosterRenderSizeProviding {
        PosterRenderSizeProvider()
    }
}
