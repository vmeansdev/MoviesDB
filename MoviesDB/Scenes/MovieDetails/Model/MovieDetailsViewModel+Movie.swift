import Foundation
import MovieDBData
import MovieDBUI
import UIKit

extension MovieDetailsViewModel {
    convenience init(
        movie: Movie,
        moviesService: MoviesServiceProtocol?,
        watchlistStore: WatchlistStoreProtocol?,
        uiAssets: MovieDBUIAssetsProtocol?,
        posterURLProvider: any PosterURLProviding
    ) {
        let baseContent = Self.makeContent(movie: movie, details: nil, posterURLProvider: posterURLProvider)
        let watchlistUpdates: (@Sendable () async -> AsyncStream<Bool>)? = {
            guard let watchlistStore else { return AsyncStream { $0.finish() } }
            return AsyncStream { continuation in
                let task = Task {
                    let stream = await watchlistStore.itemsStream()
                    for await items in stream {
                        if Task.isCancelled { break }
                        continuation.yield(items.contains { $0.id == movie.id })
                    }
                    continuation.finish()
                }
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
        let toggleWatchlist: (@Sendable () async -> Void)? = {
            guard let watchlistStore else { return }
            await watchlistStore.toggle(movie: movie)
        }
        self.init(
            content: baseContent,
            isInWatchlist: false,
            watchlistIcon: uiAssets?.heartIcon,
            watchlistFilledIcon: uiAssets?.heartFilledIcon,
            watchlistActiveTintColor: .systemPink,
            watchlistInactiveTintColor: .white,
            watchlistUpdates: watchlistUpdates,
            toggleWatchlistAction: toggleWatchlist,
            loadDetails: {
                guard let moviesService else { return baseContent }
                let details = try await moviesService.fetchDetails(id: movie.id)
                return await Self.makeContent(movie: movie, details: details, posterURLProvider: posterURLProvider)
            }
        )
    }

    convenience init(movie: Movie) {
        self.init(movie: movie, moviesService: nil, watchlistStore: nil, uiAssets: nil, posterURLProvider: NilPosterURLProvider())
    }
}

private extension MovieDetailsViewModel {
    static func makeContent(movie: Movie, details: MovieDetails?, posterURLProvider: any PosterURLProviding) -> MovieDetailsContent {
        let title = details?.title ?? movie.title
        let overview = details?.overview ?? movie.overview
        let subtitle = makeSubtitle(movie: movie, details: details)
        let metadata = makeMetadata(movie: movie, details: details)
        let posterURL = posterURLProvider.makePosterURL(path: details?.posterPath ?? movie.posterPath)
        let backdropURL = posterURLProvider.makeBackdropURL(path: details?.backdropPath ?? movie.backdropPath)

        return MovieDetailsContent(
            title: title,
            subtitle: subtitle,
            overviewTitle: String.localizable.movieDetailsOverviewTitle,
            overview: overview,
            metadata: metadata,
            posterURL: posterURL,
            backdropURL: backdropURL
        )
    }

    static func makeMetadata(movie: Movie, details: MovieDetails?) -> [MovieDetailsMetadataItem] {
        var items: [MovieDetailsMetadataItem] = []

        let ratingValue = String(format: String.localizable.movieDetailsRatingValue, details?.voteAverage ?? movie.voteAverage)
        items.append(MovieDetailsMetadataItem(
            id: "rating",
            title: String.localizable.movieDetailsRatingLabel,
            value: ratingValue
        ))

        let voteCount = details?.voteCount ?? movie.voteCount
        if voteCount > 0 {
            let votesValue = String(format: String.localizable.movieDetailsVotesValue, voteCount)
            items.append(MovieDetailsMetadataItem(
                id: "votes",
                title: String.localizable.movieDetailsVotesLabel,
                value: votesValue
            ))
        }

        if let releaseDate = details?.releaseDate ?? movie.releaseDate, !releaseDate.isEmpty {
            items.append(MovieDetailsMetadataItem(
                id: "releaseDate",
                title: String.localizable.movieDetailsReleaseDateLabel,
                value: releaseDate
            ))
        }

        let language = details?.originalLanguage ?? movie.originalLanguage
        if !language.isEmpty {
            items.append(MovieDetailsMetadataItem(
                id: "language",
                title: String.localizable.movieDetailsLanguageLabel,
                value: language.uppercased()
            ))
        }

        let originalTitle = details?.originalTitle ?? movie.originalTitle
        if originalTitle != movie.title {
            items.append(MovieDetailsMetadataItem(
                id: "originalTitle",
                title: String.localizable.movieDetailsOriginalTitleLabel,
                value: originalTitle
            ))
        }

        if let runtime = details?.runtime, runtime > 0 {
            items.append(MovieDetailsMetadataItem(
                id: "runtime",
                title: String.localizable.movieDetailsRuntimeLabel,
                value: String(format: String.localizable.movieDetailsRuntimeValue, runtime)
            ))
        }

        if let genres = details?.genres, !genres.isEmpty {
            let names = genres.map(\.name).joined(separator: ", ")
            items.append(MovieDetailsMetadataItem(
                id: "genres",
                title: String.localizable.movieDetailsGenresLabel,
                value: names
            ))
        }

        return items
    }

    static func makeSubtitle(movie: Movie, details: MovieDetails?) -> String? {
        var parts: [String] = []
        if let releaseDate = details?.releaseDate ?? movie.releaseDate, !releaseDate.isEmpty {
            parts.append(releaseDate)
        }
        let language = details?.originalLanguage ?? movie.originalLanguage
        if !language.isEmpty {
            parts.append(language.uppercased())
        }
        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: String.localizable.movieDetailsSubtitleSeparator)
    }

}

private struct NilPosterURLProvider: PosterURLProviding {
    nonisolated func makePosterURL(path: String?) -> URL? { nil }
    nonisolated func makeBackdropURL(path: String?) -> URL? { nil }
    nonisolated func makePosterOrBackdropURL(posterPath: String?, backdropPath: String?) -> URL? { nil }
}
