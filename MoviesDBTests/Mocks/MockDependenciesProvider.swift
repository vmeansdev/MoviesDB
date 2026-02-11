import MovieDBUI
@testable import MoviesDB

final class MockDependenciesProvider: DependenciesProviderProtocol {
    let coordinatorProvider: CoordinatorProviderProtocol
    let serviceProvider: ServiceProviderProtocol
    let assetsProvider: AssetsProviderProtocol
    let storeProvider: StoreProviderProtocol

    init() {
        serviceProvider = MockServiceProvider(moviesService: MockMoviesService())
        coordinatorProvider = MockCoordinatorProvider()
        assetsProvider = AssetsProvider(uiAssets: MovieDBUIAssets.system)
        storeProvider = StoreProvider(watchlistStore: MockWatchlistStore())
    }
}
