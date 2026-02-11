import Foundation
import MovieDBData
import MovieDBUI

extension MovieDetailsViewModel {
    convenience init(movie: Movie, moviesService: MoviesServiceProtocol?) {
        let baseContent = Self.makeContent(movie: movie, details: nil)
        self.init(
            content: baseContent,
            loadDetails: {
                guard let moviesService else { return baseContent }
                let details = try await moviesService.fetchDetails(id: movie.id)
                return await Self.makeContent(movie: movie, details: details)
            }
        )
    }

    convenience init(movie: Movie) {
        self.init(movie: movie, moviesService: nil)
    }
}

private extension MovieDetailsViewModel {
    static func makeContent(movie: Movie, details: MovieDetails?) -> MovieDetailsContent {
        let title = details?.title ?? movie.title
        let overview = details?.overview ?? movie.overview
        let subtitle = makeSubtitle(movie: movie, details: details)
        let metadata = makeMetadata(movie: movie, details: details)
        let posterURL = makePosterURL(path: details?.posterPath ?? movie.posterPath)
        let backdropURL = makeBackdropURL(path: details?.backdropPath ?? movie.backdropPath)

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

    static func makePosterURL(path: String) -> URL? {
        guard !path.isEmpty else { return nil }
        return URL(string: "\(Constants.posterBaseURL)\(path)")
    }

    static func makeBackdropURL(path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "\(Constants.backdropBaseURL)\(path)")
    }

    enum Constants {
        static var posterBaseURL: String { "\(Environment.imageBaseURLString)/t/p/w500" }
        static var backdropBaseURL: String { "\(Environment.imageBaseURLString)/t/p/w780" }
    }
}
