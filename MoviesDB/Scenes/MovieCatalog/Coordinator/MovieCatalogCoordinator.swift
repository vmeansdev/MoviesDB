import MovieDBData
import MovieDBUI
import UIKit

@MainActor
final class MovieCatalogCoordinator: Coordinator, @unchecked Sendable {
    private let kind: MovieCatalogKind
    private let rootViewController: UINavigationController
    private let coordinatorProvider: CoordinatorProviderProtocol
    private let dependenciesProvider: DependenciesProviderProtocol

    init(
        kind: MovieCatalogKind,
        rootViewController: UINavigationController,
        coordinatorProvider: CoordinatorProviderProtocol,
        dependenciesProvider: DependenciesProviderProtocol
    ) {
        self.kind = kind
        self.rootViewController = rootViewController
        self.coordinatorProvider = coordinatorProvider
        self.dependenciesProvider = dependenciesProvider
    }

    func start() {
        let viewController = MovieCatalogViewController.build(
            kind: kind,
            moviesService: dependenciesProvider.serviceProvider.moviesService,
            watchlistStore: dependenciesProvider.storeProvider.watchlistStore,
            uiAssets: dependenciesProvider.assetsProvider.uiAssets,
            output: self,
            posterPrefetchController: dependenciesProvider.makePosterPrefetchController(),
            posterRenderSizeProvider: dependenciesProvider.makePosterRenderSizeProvider(),
            posterURLProvider: dependenciesProvider.posterURLProvider
        )
        rootViewController.setViewControllers([viewController], animated: false)
    }
}

extension MovieCatalogCoordinator: MovieCatalogInteractorOutput {
    func didSelect(movie: Movie) {
        let coordinator = coordinatorProvider.movieDetailsCoordinator(
            rootViewController: rootViewController,
            movie: movie
        )
        coordinator.start()
    }
}
