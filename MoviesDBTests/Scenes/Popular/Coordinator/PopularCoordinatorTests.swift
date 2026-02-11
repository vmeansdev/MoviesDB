import UIKit
import Testing
import MovieDBData
import MovieDBUI
@testable import MoviesDB

struct PopularCoordinatorTests {
    @Test
    @MainActor
    func test_start_shouldSetPopularViewControllerAsRoot() async {
        let navigationController = UINavigationController()
        let serviceProvider = MockServiceProvider(moviesService: MockMoviesService())
        let coordinatorProvider = MockCoordinatorProvider()
        let watchlistStore = MockWatchlistStore()
        let uiAssets = MovieDBUIAssets.system
        let sut = PopularCoordinator(
            rootViewController: navigationController,
            serviceProvider: serviceProvider,
            coordinatorProvider: coordinatorProvider,
            watchlistStore: watchlistStore,
            uiAssets: uiAssets
        )

        sut.start()

        #expect(navigationController.viewControllers.first is PopularViewController)
    }
}
