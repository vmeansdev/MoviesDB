import MovieDBData
import MovieDBUI
@testable import MoviesDB

@MainActor
final class MockRenderProvider: RenderProviderProtocol {
    let posterRenderSizeProvider: any PosterRenderSizeProviding
    let posterImagePrefetcher: any PosterImagePrefetching
    private(set) var makePosterPrefetchControllerCallsCount = 0
    private(set) var madeControllers: [MockPosterPrefetchController] = []

    init(
        posterRenderSizeProvider: any PosterRenderSizeProviding,
        posterImagePrefetcher: any PosterImagePrefetching
    ) {
        self.posterRenderSizeProvider = posterRenderSizeProvider
        self.posterImagePrefetcher = posterImagePrefetcher
    }

    func makePosterPrefetchController() -> any PosterPrefetchControlling {
        makePosterPrefetchControllerCallsCount += 1
        let controller = MockPosterPrefetchController()
        madeControllers.append(controller)
        return controller
    }

    func makePrefetchCommandGate() -> any PrefetchCommandGating {
        PrefetchCommandGate(controller: makePosterPrefetchController())
    }
}

@MainActor
final class MockStoreProvider: StoreProviderProtocol {
    let watchlistStore: WatchlistStoreProtocol

    init(watchlistStore: WatchlistStoreProtocol) {
        self.watchlistStore = watchlistStore
    }
}

@MainActor
final class MockAssetsProvider: AssetsProviderProtocol {
    let uiAssets: MovieDBUIAssetsProtocol

    init(uiAssets: MovieDBUIAssetsProtocol) {
        self.uiAssets = uiAssets
    }
}

@MainActor
final class MockDependenciesProvider: DependenciesProviderProtocol {
    let serviceProvider: ServiceProviderProtocol
    let assetsProvider: AssetsProviderProtocol
    let storeProvider: StoreProviderProtocol
    let renderProvider: RenderProviderProtocol
    let viewModelProvider: ViewModelProviderProtocol

    init(
        serviceProvider: ServiceProviderProtocol,
        assetsProvider: AssetsProviderProtocol,
        storeProvider: StoreProviderProtocol,
        renderProvider: RenderProviderProtocol,
        viewModelProvider: ViewModelProviderProtocol? = nil
    ) {
        self.serviceProvider = serviceProvider
        self.assetsProvider = assetsProvider
        self.storeProvider = storeProvider
        self.renderProvider = renderProvider
        self.viewModelProvider = viewModelProvider ?? ViewModelProvider(
            serviceProvider: serviceProvider,
            assetsProvider: assetsProvider,
            storeProvider: storeProvider,
            renderProvider: renderProvider
        )
    }
}
