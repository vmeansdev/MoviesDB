#if DEBUG
import MovieDBData
import MovieDBUI
import SwiftUI
import UIKit

private struct MockMoviesService: MoviesServiceProtocol {
    func fetchPopular(options: MovieListOptions) async throws -> MovieList {
        let movie = Movie(
            adult: false,
            backdropPath: nil,
            genreIDS: [18],
            id: 1,
            originalLanguage: "en",
            originalTitle: "The First Movie",
            overview: "",
            popularity: 1.0,
            posterPath: "/pup.jpg",
            releaseDate: "2026-01-01",
            title: "The First Movie",
            video: false,
            voteAverage: 7.8,
            voteCount: 120
        )
        return MovieList(page: 1, results: [movie, movie, movie], totalPages: 1, totalResults: 3)
    }

    func fetchTopRated(options: MovieListOptions) async throws -> MovieList {
        MovieList(page: 1, results: [], totalPages: 1, totalResults: 0)
    }

    func fetchDetails(id: Int) async throws -> MovieDetails {
        MovieDetails(
            id: id,
            title: "The First Movie",
            originalTitle: "The First Movie",
            originalLanguage: "en",
            overview: "Preview overview.",
            posterPath: "/pup.jpg",
            backdropPath: nil,
            releaseDate: "2026-01-01",
            runtime: 120,
            voteAverage: 7.8,
            voteCount: 120,
            genres: [],
            spokenLanguages: []
        )
    }
}

private final class MockOutput: PopularInteractorOutput {
    func didSelect(movie: Movie) {
        // no-op
    }
}

private actor MockWatchlistStore: WatchlistStoreProtocol {
    func items() async -> [Movie] { [] }
    func itemsStream() async -> AsyncStream<[Movie]> {
        AsyncStream { $0.yield([]) }
    }
    func isInWatchlist(id: Int) async -> Bool { false }
    func add(movie: Movie) async { }
    func remove(id: Int) async { }
    func toggle(movie: Movie) async { }
}

#Preview {
    UINavigationController(
        rootViewController: PopularViewController.build(
            moviesService: MockMoviesService(),
            watchlistStore: MockWatchlistStore(),
            uiAssets: MovieDBUIAssets.system,
            output: MockOutput()
        )
    )
}
#endif
