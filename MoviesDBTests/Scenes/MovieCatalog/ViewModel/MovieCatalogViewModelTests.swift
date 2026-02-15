import Foundation
import MovieDBUI
import Testing
@testable import MovieDBData
@testable import MoviesDB

@MainActor
struct MovieCatalogViewModelTests {
    @Test
    func test_onAppear_loadsInitialPagesAndUpdatesTitle() async {
        let service = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        service.fetchPopularHandler = { options in
            switch options.page {
            case 1:
                return MovieList(page: 1, results: [makeMovie(id: 1)], totalPages: 3, totalResults: 3)
            case 2:
                return MovieList(page: 2, results: [makeMovie(id: 2)], totalPages: 3, totalResults: 3)
            default:
                return MovieList(page: options.page, results: [], totalPages: 3, totalResults: 3)
            }
        }
        let sut = makeSUT(
            moviesService: service,
            watchlistStore: watchlistStore,
            posterPrefetchController: prefetchController
        )

        sut.onAppear()

        let didLoad = await waitUntil { await MainActor.run { sut.items.count == 2 } }
        #expect(didLoad)
        #expect(service.fetchPopularCalls.map(\.page) == [1, 2])
        #expect(sut.title == String(format: String.localizable.popularCountTitle, 2))
    }

    @Test
    func test_toggleWatchlist_updatesItemState() async {
        let service = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        let movie = makeMovie(id: 7)
        service.fetchPopularResult = .success(MovieList(page: 1, results: [movie], totalPages: 1, totalResults: 1))
        let sut = makeSUT(
            moviesService: service,
            watchlistStore: watchlistStore,
            posterPrefetchController: prefetchController
        )

        sut.onAppear()

        let didLoad = await waitUntil { await MainActor.run { sut.items.count == 1 } }
        #expect(didLoad)
        #expect(sut.items.first?.isInWatchlist == false)

        sut.toggleWatchlist(at: 0)

        let didUpdate = await waitUntil { await MainActor.run { sut.items.first?.isInWatchlist == true } }
        #expect(didUpdate)
        #expect(await watchlistStore.isInWatchlist(id: movie.id))
    }

    @Test
    func test_errorState_canBeDismissed() async {
        enum TestError: Error { case failure }

        let service = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        service.fetchPopularResult = .failure(TestError.failure)
        let sut = makeSUT(
            moviesService: service,
            watchlistStore: watchlistStore,
            posterPrefetchController: prefetchController
        )

        sut.onAppear()

        let didFail = await waitUntil { await MainActor.run { sut.error != nil } }
        #expect(didFail)
        #expect(sut.error?.retry != nil)

        sut.dismissError()
        #expect(sut.error == nil)
    }

    @Test
    func test_onDisappear_stopsPrefetchController() {
        let service = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let prefetchController = MockPosterPrefetchController()
        let sut = makeSUT(
            moviesService: service,
            watchlistStore: watchlistStore,
            posterPrefetchController: prefetchController
        )

        sut.onDisappear()

        #expect(prefetchController.stopCallsCount == 1)
    }

    private func makeSUT(
        moviesService: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        posterPrefetchController: any PosterPrefetchControlling
    ) -> MovieCatalogViewModel {
        MovieCatalogViewModel(
            kind: .popular,
            moviesService: moviesService,
            watchlistStore: watchlistStore,
            uiAssets: MovieDBUIAssets.system,
            posterPrefetchController: posterPrefetchController,
            language: "en"
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
