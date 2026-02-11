import MovieDBData
import MovieDBUI
import UIKit

final class PopularCoordinator: Coordinator {
    private let rootViewController: UINavigationController
    private let serviceProvider: ServiceProviderProtocol
    private let coordinatorProvider: CoordinatorProviderProtocol
    private let watchlistStore: WatchlistStoreProtocol
    private let uiAssets: MovieDBUIAssetsProtocol

    init(
        rootViewController: UINavigationController,
        serviceProvider: ServiceProviderProtocol,
        coordinatorProvider: CoordinatorProviderProtocol,
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol
    ) {
        self.rootViewController = rootViewController
        self.serviceProvider = serviceProvider
        self.coordinatorProvider = coordinatorProvider
        self.watchlistStore = watchlistStore
        self.uiAssets = uiAssets
    }

    func start() {
        let viewController = PopularViewController.build(
            moviesService: serviceProvider.moviesService,
            watchlistStore: watchlistStore,
            uiAssets: uiAssets,
            output: self
        )
        rootViewController.setViewControllers([viewController], animated: false)
    }
}

extension PopularCoordinator: PopularInteractorOutput {
    func didSelect(movie: Movie) {
        let coordinator = coordinatorProvider.movieDetailsCoordinator(
            rootViewController: rootViewController,
            movie: movie
        )
        coordinator.start()
    }
}
