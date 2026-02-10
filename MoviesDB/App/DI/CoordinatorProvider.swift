import UIKit

@MainActor
protocol CoordinatorProviderProtocol {
    func rootCoordinator() -> Coordinator
}

final class CoordinatorProvider: CoordinatorProviderProtocol {
    private let rootViewController: UINavigationController
    private let serviceProvider: ServiceProviderProtocol

    init(rootViewController: UINavigationController, serviceProvider: ServiceProviderProtocol) {
        self.rootViewController = rootViewController
        self.serviceProvider = serviceProvider
    }

    func rootCoordinator() -> Coordinator {
        RootCoordinator(rootViewController: rootViewController)
    }
}
