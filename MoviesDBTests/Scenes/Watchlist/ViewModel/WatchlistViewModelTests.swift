import Foundation
import MovieDBUI
import Testing
@testable import MovieDBData
@testable import MoviesDB

@MainActor
struct WatchlistViewModelTests {
    @Test
    func test_startObserveWatchlist_mapsItemsToViewModels() async {
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        let sut = makeSUT(watchlistStore: watchlistStore, posterPrefetchController: prefetchController)

        sut.startObserveWatchlist()
        let movie = makeMovie(id: 42)
        await watchlistStore.add(movie: movie)

        let didUpdate = await waitUntil {
            await MainActor.run { sut.items.count == 1 && sut.itemViewModels.count == 1 }
        }
        #expect(didUpdate)
        #expect(sut.itemViewModels.first?.title == "Movie 42")
        #expect(sut.itemViewModels.first?.isInWatchlist == true)
    }

    @Test
    func test_toggle_updatesWatchlistStore() async {
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        let sut = makeSUT(watchlistStore: watchlistStore, posterPrefetchController: prefetchController)
        let movie = makeMovie(id: 8)

        sut.toggle(movie: movie)

        let didToggle = await waitUntil { await watchlistStore.isInWatchlist(id: 8) }
        #expect(didToggle)
    }

    @Test
    func test_itemVisibilityChanged_forwardsToPrefetchController() {
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        let sut = makeSUT(watchlistStore: watchlistStore, posterPrefetchController: prefetchController)

        sut.itemVisibilityChanged(index: 3, isVisible: true, columns: 2)

        #expect(prefetchController.visibilityCalls.count == 1)
        #expect(prefetchController.visibilityCalls[0].index == 3)
        #expect(prefetchController.visibilityCalls[0].isVisible == true)
        #expect(prefetchController.visibilityCalls[0].columns == 2)
    }

    @Test
    func test_stopObserveWatchlist_stopsPrefetchController() {
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        let sut = makeSUT(watchlistStore: watchlistStore, posterPrefetchController: prefetchController)

        sut.stopObserveWatchlist()

        #expect(prefetchController.stopCallsCount == 1)
    }

    private func makeSUT(
        watchlistStore: WatchlistStoreProtocol,
        posterPrefetchController: any PosterPrefetchControlling
    ) -> WatchlistViewModel {
        WatchlistViewModel(
            watchlistStore: watchlistStore,
            uiAssets: MovieDBUIAssets.system,
            posterPrefetchController: posterPrefetchController
        )
    }

    private func makeMovie(id: Int) -> Movie {
        Movie(
            adult: false,
            backdropPath: "/backdrop\(id).jpg",
            genreIDS: [1],
            id: id,
            originalLanguage: "en",
            originalTitle: "Original \(id)",
            overview: "Overview \(id)",
            popularity: 1,
            posterPath: "/poster\(id).jpg",
            releaseDate: "2026-01-\(String(format: "%02d", id))",
            title: "Movie \(id)",
            video: false,
            voteAverage: 7.1,
            voteCount: 10
        )
    }
}
