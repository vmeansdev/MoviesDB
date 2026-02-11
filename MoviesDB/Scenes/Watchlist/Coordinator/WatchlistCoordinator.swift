import MovieDBData
import MovieDBUI
import UIKit

final class WatchlistCoordinator: Coordinator {
    private let rootViewController: UINavigationController
    private let dependenciesProvider: DependenciesProviderProtocol
    private let coordinatorProvider: CoordinatorProviderProtocol

    init(
        rootViewController: UINavigationController,
        dependenciesProvider: DependenciesProviderProtocol,
        coordinatorProvider: CoordinatorProviderProtocol
    ) {
        self.rootViewController = rootViewController
        self.dependenciesProvider = dependenciesProvider
        self.coordinatorProvider = coordinatorProvider
    }

    func start() {
        let viewModel = WatchlistViewModel(
            watchlistStore: dependenciesProvider.storeProvider.watchlistStore,
            uiAssets: dependenciesProvider.assetsProvider.uiAssets,
            onSelect: { [weak self] movie in
                self?.showDetails(movie: movie)
            }
        )
        let view = WatchlistView(viewModel: viewModel)
        let viewController = WatchlistViewController(with: view)
        viewController.title = String.localizable.tabWatchlistTitle
        rootViewController.setViewControllers([viewController], animated: false)
    }

    private func showDetails(movie: Movie) {
        let coordinator = coordinatorProvider.movieDetailsCoordinator(
            rootViewController: rootViewController,
            movie: movie
        )
        coordinator.start()
    }
}
