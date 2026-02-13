import UIKit
import Testing
import MovieDBData
import MovieDBUI
@testable import MoviesDB

@MainActor
struct TopRatedCoordinatorTests {
    @Test
    func test_start_shouldSetTopRatedViewControllerAsRoot() {
        let navigationController = UINavigationController()
        let serviceProvider = MockServiceProvider(moviesService: MockMoviesService())
        let coordinatorProvider = MockCoordinatorProvider()
        let watchlistStore = MockWatchlistStore()
        let uiAssets = MovieDBUIAssets.system
        let sut = TopRatedCoordinator(
            rootViewController: navigationController,
            serviceProvider: serviceProvider,
            coordinatorProvider: coordinatorProvider,
            watchlistStore: watchlistStore,
            uiAssets: uiAssets
        )

        sut.start()

        #expect(navigationController.viewControllers.first is TopRatedViewController)
    }
}
