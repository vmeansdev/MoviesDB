import UIKit
import Testing
import MovieDBData
import MovieDBUI
@testable import MoviesDB

struct TopRatedCoordinatorTests {
    @Test
    @MainActor
    func test_start_shouldSetTopRatedViewControllerAsRoot() async {
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
