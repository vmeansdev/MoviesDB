import MovieDBData
import UIKit

final class TopRatedCoordinator: Coordinator {
    private let rootViewController: UINavigationController
    private let serviceProvider: ServiceProviderProtocol
    private let coordinatorProvider: CoordinatorProviderProtocol

    init(
        rootViewController: UINavigationController,
        serviceProvider: ServiceProviderProtocol,
        coordinatorProvider: CoordinatorProviderProtocol
    ) {
        self.rootViewController = rootViewController
        self.serviceProvider = serviceProvider
        self.coordinatorProvider = coordinatorProvider
    }

    func start() {
        let viewController = TopRatedViewController.build(moviesService: serviceProvider.moviesService, output: self)
        rootViewController.setViewControllers([viewController], animated: false)
    }
}

extension TopRatedCoordinator: TopRatedInteractorOutput {
    func didSelect(movie: Movie) {
        // TODO: push details when details scene is available
    }
}
