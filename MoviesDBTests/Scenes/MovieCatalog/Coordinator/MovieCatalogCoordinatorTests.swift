import UIKit
import Testing
@testable import MoviesDB

@MainActor
struct MovieCatalogCoordinatorTests {
    @Test
    func test_start_popular_shouldSetMovieCatalogViewControllerAsRoot() {
        let navigationController = UINavigationController()
        let coordinatorProvider = MockCoordinatorProvider()
        let dependenciesProvider = MockDependenciesProvider()
        let sut = MovieCatalogCoordinator(
            kind: .popular,
            rootViewController: navigationController,
            coordinatorProvider: coordinatorProvider,
            dependenciesProvider: dependenciesProvider
        )

        sut.start()

        #expect(navigationController.viewControllers.first is MovieCatalogViewController)
    }

    @Test
    func test_start_topRated_shouldSetMovieCatalogViewControllerAsRoot() {
        let navigationController = UINavigationController()
        let coordinatorProvider = MockCoordinatorProvider()
        let dependenciesProvider = MockDependenciesProvider()
        let sut = MovieCatalogCoordinator(
            kind: .topRated,
            rootViewController: navigationController,
            coordinatorProvider: coordinatorProvider,
            dependenciesProvider: dependenciesProvider
        )

        sut.start()

        #expect(navigationController.viewControllers.first is MovieCatalogViewController)
    }
}
