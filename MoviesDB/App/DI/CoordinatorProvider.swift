import UIKit

@MainActor
protocol CoordinatorProviderProtocol {
    func popularCoordinator() -> Coordinator
}

final class CoordinatorProvider: CoordinatorProviderProtocol {
    private let rootViewController: UINavigationController
    private let serviceProvider: ServiceProviderProtocol

    init(rootViewController: UINavigationController, serviceProvider: ServiceProviderProtocol) {
        self.rootViewController = rootViewController
        self.serviceProvider = serviceProvider
    }

    func popularCoordinator() -> Coordinator {
        PopularCoordinator(rootViewController: rootViewController, serviceProvider: serviceProvider)
    }
}
