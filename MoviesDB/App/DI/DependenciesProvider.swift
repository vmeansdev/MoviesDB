import AppHttpKit
import UIKit

@MainActor
protocol DependenciesProviderProtocol {
    var coordinatorProvider: CoordinatorProviderProtocol { get }
    var serviceProvider: ServiceProviderProtocol { get }
}

final class DependenciesProvider: DependenciesProviderProtocol {
    let coordinatorProvider: CoordinatorProviderProtocol
    let serviceProvider: ServiceProviderProtocol

    init(
        window: UIWindow?,
        rootNavigationController: UINavigationController,
        windowConfigurator: WindowConfiguratorProtocol,
        navigationControllerConfigurator: NavigationControllerConfiguratorProtocol
    ) {
        let client = HttpClient(baseURL: Environment.baseURLString)
        serviceProvider = ServiceProvider(apiKey: Environment.apiKey, httpClient: client)
        coordinatorProvider = CoordinatorProvider(rootViewController: rootNavigationController, serviceProvider: serviceProvider)
        navigationControllerConfigurator.configure(navigationController: rootNavigationController)
        windowConfigurator.configure(window: window, navigationController: rootNavigationController)
    }
}
