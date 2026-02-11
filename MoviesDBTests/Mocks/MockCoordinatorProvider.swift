import MovieDBData
import UIKit
@testable import MoviesDB

@MainActor
final class MockCoordinator: Coordinator {
    private(set) var startCallCount = 0

    func start() {
        startCallCount += 1
    }
}

@MainActor
final class MockCoordinatorProvider: CoordinatorProviderProtocol {
    let root = MockCoordinator()
    let popular = MockCoordinator()
    let topRated = MockCoordinator()
    private(set) var movieDetailsCoordinatorMovie: Movie?

    func rootCoordinator() -> Coordinator {
        root
    }

    func popularCoordinator() -> Coordinator {
        popular
    }

    func topRatedCoordinator() -> Coordinator {
        topRated
    }

    func movieDetailsCoordinator(rootViewController: UINavigationController, movie: Movie) -> Coordinator {
        movieDetailsCoordinatorMovie = movie
        return MockCoordinator()
    }

    func allCoordinators() -> [Coordinator] {
        [root, popular, topRated]
    }
}
