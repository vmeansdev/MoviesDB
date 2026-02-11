import AppHttpKit
import MovieDBUI
import UIKit

@MainActor
protocol DependenciesProviderProtocol {
    var coordinatorProvider: CoordinatorProviderProtocol { get }
    var serviceProvider: ServiceProviderProtocol { get }
    var uiAssets: MovieDBUIAssetsProtocol { get }
}

final class DependenciesProvider: DependenciesProviderProtocol {
    let coordinatorProvider: CoordinatorProviderProtocol
    let serviceProvider: ServiceProviderProtocol
    let uiAssets: MovieDBUIAssetsProtocol

    init(
        window: UIWindow?,
        windowConfigurator: WindowConfiguratorProtocol,
        appearanceConfigurator: AppAppearanceConfiguratorProtocol
    ) {
        uiAssets = MovieDBUIAssets.system
        serviceProvider = ServiceProvider(apiKey: Environment.apiKey, httpClient: HttpClient(baseURL: Environment.baseURLString))
        coordinatorProvider = CoordinatorProvider(
            window: window,
            serviceProvider: serviceProvider,
            windowConfigurator: windowConfigurator,
            appearanceConfigurator: appearanceConfigurator,
            uiAssets: uiAssets
        )
    }
}
