import Foundation
import MovieDBData
import MovieDBUI
import Testing
@testable import MoviesDB

@MainActor
struct WatchlistViewModelTests {
    @Test
    func test_startObserveWatchlist_shouldUpdateItems() async {
        let movie = makeMovie(id: 1, posterPath: "/poster.jpg", backdropPath: nil)
        let watchlistStore = MockWatchlistStore()
        let sut = makeSUT(watchlistStore: watchlistStore)

        sut.startObserveWatchlist()
        await watchlistStore.add(movie: movie)

        let didUpdate = await waitUntil {
            await MainActor.run { sut.items == [movie] }
        }

        #expect(didUpdate)
    }

    @Test
    func test_toggle_shouldUpdateWatchlist() async {
        let movie = makeMovie(id: 7, posterPath: "/poster.jpg", backdropPath: nil)
        let watchlistStore = MockWatchlistStore()
        let sut = makeSUT(watchlistStore: watchlistStore)

        sut.toggle(movie: movie)
        let didAdd = await waitUntil {
            await watchlistStore.isInWatchlist(id: movie.id)
        }

        #expect(didAdd)
    }

    @Test
    func test_select_shouldCallOnSelect() {
        let movie = makeMovie(id: 2, posterPath: nil, backdropPath: nil)
        var selectedMovie: Movie?
        let sut = WatchlistViewModel(
            watchlistStore: MockWatchlistStore(),
            uiAssets: MovieDBUIAssets.system,
            posterURLProvider: PosterURLProvider(imageBaseURLString: Constants.imageBaseURLString),
            onSelect: { selectedMovie = $0 }
        )

        sut.select(movie: movie)

        #expect(selectedMovie?.id == movie.id)
    }

    @Test
    func test_posterURL_whenPosterMissing_shouldUseBackdrop() {
        let movie = makeMovie(id: 3, posterPath: nil, backdropPath: "/backdrop.jpg")
        let sut = makeSUT(watchlistStore: MockWatchlistStore())

        let posterURL = sut.posterURL(for: movie)

        #expect(posterURL?.absoluteString == "\(Constants.imageBaseURLString)/t/p/w780/backdrop.jpg")
    }

    private func makeSUT(watchlistStore: MockWatchlistStore) -> WatchlistViewModel {
        WatchlistViewModel(
            watchlistStore: watchlistStore,
            uiAssets: MovieDBUIAssets.system,
            posterURLProvider: PosterURLProvider(imageBaseURLString: Constants.imageBaseURLString),
            onSelect: { _ in }
        )
    }

    private func makeMovie(id: Int, posterPath: String?, backdropPath: String?) -> Movie {
        Movie(
            adult: false,
            backdropPath: backdropPath,
            genreIDS: [1],
            id: id,
            originalLanguage: "en",
            originalTitle: "Original \(id)",
            overview: "Overview \(id)",
            popularity: 1,
            posterPath: posterPath,
            releaseDate: "2026-01-01",
            title: "Movie \(id)",
            video: false,
            voteAverage: 7.0,
            voteCount: 10
        )
    }
}

private enum Constants {
    static let imageBaseURLString = "https://image.tmdb.org"
}
