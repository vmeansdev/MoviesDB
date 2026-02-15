#if DEBUG
import MovieDBData
import MovieDBUI
import SwiftUI
import UIKit

private struct PreviewMoviesService: MoviesServiceProtocol {
    func fetchPopular(options: MovieCatalogOptions) async throws -> MovieCatalog {
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
        return MovieCatalog(page: 1, results: [movie, movie, movie], totalPages: 1, totalResults: 3)
    }

    func fetchTopRated(options: MovieCatalogOptions) async throws -> MovieCatalog {
        let movie = Movie(
            adult: false,
            backdropPath: nil,
            genreIDS: [18],
            id: 2,
            originalLanguage: "en",
            originalTitle: "The Second Movie",
            overview: "",
            popularity: 1.0,
            posterPath: "/pup.jpg",
            releaseDate: "2026-01-01",
            title: "The Second Movie",
            video: false,
            voteAverage: 8.1,
            voteCount: 180
        )
        return MovieCatalog(page: 1, results: [movie, movie, movie], totalPages: 1, totalResults: 3)
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

@MainActor
private final class PreviewOutput: MovieCatalogInteractorOutput {
    func didSelect(movie: Movie) {
        // no-op
    }
}

private actor PreviewWatchlistStore: WatchlistStoreProtocol {
    func items() async -> [Movie] { [] }
    func itemsStream() async -> AsyncStream<[Movie]> {
        AsyncStream { $0.yield([]) }
    }
    func isInWatchlist(id: Int) async -> Bool { false }
    func add(movie: Movie) async { }
    func remove(id: Int) async { }
    func toggle(movie: Movie) async { }
}

#Preview("Popular") {
    UINavigationController(
        rootViewController: MovieCatalogViewController.build(
            kind: .popular,
            moviesService: PreviewMoviesService(),
            watchlistStore: PreviewWatchlistStore(),
            uiAssets: MovieDBUIAssets.system,
            output: PreviewOutput(),
            posterPrefetchController: PosterPrefetchController(posterImagePrefetcher: PosterImagePrefetcher.shared),
            posterRenderSizeProvider: PosterRenderSizeProvider(),
            posterURLProvider: PosterURLProvider(imageBaseURLString: "https://image.tmdb.org")
        )
    )
}

#Preview("Top Rated") {
    UINavigationController(
        rootViewController: MovieCatalogViewController.build(
            kind: .topRated,
            moviesService: PreviewMoviesService(),
            watchlistStore: PreviewWatchlistStore(),
            uiAssets: MovieDBUIAssets.system,
            output: PreviewOutput(),
            posterPrefetchController: PosterPrefetchController(posterImagePrefetcher: PosterImagePrefetcher.shared),
            posterRenderSizeProvider: PosterRenderSizeProvider(),
            posterURLProvider: PosterURLProvider(imageBaseURLString: "https://image.tmdb.org")
        )
    )
}
#endif
