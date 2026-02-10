import MovieDBData
import UIKit

final class PopularCoordinator: Coordinator {
    private let rootViewController: UINavigationController
    private let serviceProvider: ServiceProviderProtocol

    init(rootViewController: UINavigationController, serviceProvider: ServiceProviderProtocol) {
        self.rootViewController = rootViewController
        self.serviceProvider = serviceProvider
    }

    func start() {
        let viewController = PopularViewController.build(moviesService: serviceProvider.moviesService, output: self)
        rootViewController.setViewControllers([viewController], animated: false)
    }
}

extension PopularCoordinator: PopularInteractorOutput {
    func didSelect(movie: Movie) {
        // TODO: push details when details scene is available
    }
}
