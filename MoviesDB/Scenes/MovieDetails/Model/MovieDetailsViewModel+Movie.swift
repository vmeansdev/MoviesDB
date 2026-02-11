import Foundation
import MovieDBData
import MovieDBUI

extension MovieDetailsViewModel {
    convenience init(movie: Movie) {
        let content = MovieDetailsContent(
            title: movie.title,
            subtitle: Self.makeSubtitle(movie: movie),
            overviewTitle: String.localizable.movieDetailsOverviewTitle,
            overview: movie.overview,
            metadata: Self.makeMetadata(movie: movie),
            posterURL: Self.makePosterURL(path: movie.posterPath),
            backdropURL: Self.makeBackdropURL(path: movie.backdropPath)
        )
        self.init(content: content)
    }
}

private extension MovieDetailsViewModel {
    static func makeMetadata(movie: Movie) -> [MovieDetailsMetadataItem] {
        var items: [MovieDetailsMetadataItem] = []

        let ratingValue = String(format: String.localizable.movieDetailsRatingValue, movie.voteAverage)
        items.append(MovieDetailsMetadataItem(
            id: "rating",
            title: String.localizable.movieDetailsRatingLabel,
            value: ratingValue
        ))

        if movie.voteCount > 0 {
            let votesValue = String(format: String.localizable.movieDetailsVotesValue, movie.voteCount)
            items.append(MovieDetailsMetadataItem(
                id: "votes",
                title: String.localizable.movieDetailsVotesLabel,
                value: votesValue
            ))
        }

        if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
            items.append(MovieDetailsMetadataItem(
                id: "releaseDate",
                title: String.localizable.movieDetailsReleaseDateLabel,
                value: releaseDate
            ))
        }

        if !movie.originalLanguage.isEmpty {
            items.append(MovieDetailsMetadataItem(
                id: "language",
                title: String.localizable.movieDetailsLanguageLabel,
                value: movie.originalLanguage.uppercased()
            ))
        }

        if movie.originalTitle != movie.title {
            items.append(MovieDetailsMetadataItem(
                id: "originalTitle",
                title: String.localizable.movieDetailsOriginalTitleLabel,
                value: movie.originalTitle
            ))
        }

        return items
    }

    static func makeSubtitle(movie: Movie) -> String? {
        var parts: [String] = []
        if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
            parts.append(releaseDate)
        }
        if !movie.originalLanguage.isEmpty {
            parts.append(movie.originalLanguage.uppercased())
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
