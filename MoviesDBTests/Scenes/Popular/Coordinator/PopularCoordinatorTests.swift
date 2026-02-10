import UIKit
import Testing
import MovieDBData
@testable import MoviesDB

struct PopularCoordinatorTests {
    @Test
    @MainActor
    func test_start_shouldSetPopularViewControllerAsRoot() async {
        let navigationController = UINavigationController()
        let serviceProvider = MockServiceProvider(moviesService: MockMoviesService())
        let sut = PopularCoordinator(rootViewController: navigationController, serviceProvider: serviceProvider)

        sut.start()

        #expect(navigationController.viewControllers.first is PopularViewController)
    }
}
