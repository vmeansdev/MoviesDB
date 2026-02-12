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
}

final class DependenciesProvider: DependenciesProviderProtocol {
    lazy var coordinatorProvider: CoordinatorProviderProtocol = CoordinatorProvider(
        window: window,
        serviceProvider: serviceProvider,
        windowConfigurator: windowConfigurator,
        appearanceConfigurator: appearanceConfigurator,
        assetsProvider: assetsProvider,
        storeProvider: storeProvider,
        dependenciesProvider: self
    )
    let serviceProvider: ServiceProviderProtocol
    let assetsProvider: AssetsProviderProtocol
    let storeProvider: StoreProviderProtocol
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
    }
}
