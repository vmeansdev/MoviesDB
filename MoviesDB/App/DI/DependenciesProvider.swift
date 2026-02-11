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
    lazy var coordinatorProvider: CoordinatorProviderProtocol = CoordinatorProvider(
        window: window,
        serviceProvider: serviceProvider,
        windowConfigurator: windowConfigurator,
        appearanceConfigurator: appearanceConfigurator,
        uiAssets: uiAssets,
        dependenciesProvider: self
    )
    let serviceProvider: ServiceProviderProtocol
    let uiAssets: MovieDBUIAssetsProtocol
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
        uiAssets = MovieDBUIAssets.system
        serviceProvider = ServiceProvider(apiKey: Environment.apiKey, httpClient: HttpClient(baseURL: Environment.baseURLString))
    }
}
