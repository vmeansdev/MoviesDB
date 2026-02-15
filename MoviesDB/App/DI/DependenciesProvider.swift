import AppHttpKit
import MovieDBData
import MovieDBUI
import UIKit

@MainActor
protocol DependenciesProviderProtocol {
    var coordinatorProvider: CoordinatorProviderProtocol { get }
    var serviceProvider: ServiceProviderProtocol { get }
    var assetsProvider: AssetsProviderProtocol { get }
    var storeProvider: StoreProviderProtocol { get }
    var posterImagePrefetcher: any PosterImagePrefetching { get }
    var posterURLProvider: any PosterURLProviding { get }
    func makePosterPrefetchController() -> any PosterPrefetchControlling
    func makePosterRenderSizeProvider() -> any PosterRenderSizeProviding
}

final class DependenciesProvider: DependenciesProviderProtocol {
    lazy var coordinatorProvider: CoordinatorProviderProtocol = CoordinatorProvider(
        window: window,
        windowConfigurator: windowConfigurator,
        appearanceConfigurator: appearanceConfigurator,
        assetsProvider: assetsProvider,
        storeProvider: storeProvider,
        dependenciesProvider: self
    )
    let serviceProvider: ServiceProviderProtocol
    let assetsProvider: AssetsProviderProtocol
    let storeProvider: StoreProviderProtocol
    let posterImagePrefetcher: any PosterImagePrefetching
    let posterURLProvider: any PosterURLProviding
    private let window: UIWindow?
    private let windowConfigurator: WindowConfiguratorProtocol
    private let appearanceConfigurator: AppAppearanceConfiguratorProtocol

    init(
        window: UIWindow?,
        windowConfigurator: WindowConfiguratorProtocol,
        appearanceConfigurator: AppAppearanceConfiguratorProtocol
    ) {
        self.window = window
        self.windowConfigurator = windowConfigurator
        self.appearanceConfigurator = appearanceConfigurator
        let baseURL = Environment.baseURLString
        let httpClient = HttpClient(baseURL: baseURL)
        let cache = ResponseCache()
        let policy = MovieDBCachePolicy()
        let cachingClient = CachingClient(
            baseURL: baseURL,
            client: httpClient,
            cache: cache,
            policy: policy
        )
        serviceProvider = ServiceProvider(apiKey: Environment.apiKey, httpClient: cachingClient)
        assetsProvider = AssetsProvider()
        storeProvider = StoreProvider()
        posterImagePrefetcher = PosterImagePrefetcher.shared
        posterURLProvider = PosterURLProvider(imageBaseURLString: Environment.imageBaseURLString)
    }

    func makePosterPrefetchController() -> any PosterPrefetchControlling {
        PosterPrefetchController(posterImagePrefetcher: posterImagePrefetcher)
    }

    func makePosterRenderSizeProvider() -> any PosterRenderSizeProviding {
        PosterRenderSizeProvider()
    }
}
