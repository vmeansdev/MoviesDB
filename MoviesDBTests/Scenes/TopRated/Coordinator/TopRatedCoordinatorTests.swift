import UIKit
import Testing
import MovieDBData
@testable import MoviesDB

struct TopRatedCoordinatorTests {
    @Test
    @MainActor
    func test_start_shouldSetTopRatedViewControllerAsRoot() async {
        let navigationController = UINavigationController()
        let serviceProvider = MockServiceProvider(moviesService: MockMoviesService())
        let coordinatorProvider = MockCoordinatorProvider()
        let sut = TopRatedCoordinator(
            rootViewController: navigationController,
            serviceProvider: serviceProvider,
            coordinatorProvider: coordinatorProvider
        )

        sut.start()

        #expect(navigationController.viewControllers.first is TopRatedViewController)
    }
}
