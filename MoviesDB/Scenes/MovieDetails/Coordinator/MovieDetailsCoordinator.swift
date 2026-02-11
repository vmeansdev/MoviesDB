import MovieDBData
import MovieDBUI
import UIKit

final class MovieDetailsCoordinator: Coordinator {
    private let rootViewController: UINavigationController
    private let movie: Movie
    private let dependenciesProvider: DependenciesProviderProtocol

    init(rootViewController: UINavigationController, movie: Movie, dependenciesProvider: DependenciesProviderProtocol) {
        self.rootViewController = rootViewController
        self.movie = movie
        self.dependenciesProvider = dependenciesProvider
    }

    func start() {
        let viewModel = MovieDetailsViewModel(
            movie: movie,
            moviesService: dependenciesProvider.serviceProvider.moviesService
        )
        let view = MovieDetailsView(viewModel: viewModel)
        let viewController = MovieDetailsViewController(with: view)
        rootViewController.pushViewController(viewController, animated: true)
    }
}
