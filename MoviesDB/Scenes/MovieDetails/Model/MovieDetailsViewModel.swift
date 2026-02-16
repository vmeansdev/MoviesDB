import Foundation
import MovieDBData
import MovieDBUI
import Observation
import UIKit

struct MovieDetailsContent: Equatable, Sendable {
    let title: String
    let subtitle: String?
    let overviewTitle: String
    let overview: String
    let metadata: [MovieDetailsMetadataItem]
    let posterURL: URL?
    let backdropURL: URL?
}

struct MovieDetailsMetadataItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let value: String
}

enum MovieDetailsViewModelState {
    case idle(content: MovieDetailsContent, isInWatchlist: Bool)
    case loading(content: MovieDetailsContent, isInWatchlist: Bool)

    var content: MovieDetailsContent {
        switch self {
        case let .idle(content, _), let .loading(content, _):
            return content
        }
    }

    var isInWatchlist: Bool {
        switch self {
        case let .idle(_, isInWatchlist), let .loading(_, isInWatchlist):
            return isInWatchlist
        }
    }

    func replacing(content: MovieDetailsContent) -> MovieDetailsViewModelState {
        switch self {
        case let .idle(_, isInWatchlist):
            return .idle(content: content, isInWatchlist: isInWatchlist)
        case let .loading(_, isInWatchlist):
            return .loading(content: content, isInWatchlist: isInWatchlist)
        }
    }

    func replacing(isInWatchlist: Bool) -> MovieDetailsViewModelState {
        switch self {
        case let .idle(content, _):
            return .idle(content: content, isInWatchlist: isInWatchlist)
        case let .loading(content, _):
            return .loading(content: content, isInWatchlist: isInWatchlist)
        }
    }

    func loading() -> MovieDetailsViewModelState {
        .loading(content: content, isInWatchlist: isInWatchlist)
    }

    func idle() -> MovieDetailsViewModelState {
        .idle(content: content, isInWatchlist: isInWatchlist)
    }
}

@MainActor
@Observable
final class MovieDetailsViewModel {
    private(set) var state: MovieDetailsViewModelState

    let watchlistIcon: UIImage?
    let watchlistFilledIcon: UIImage?
    private let movie: Movie
    private let moviesService: MoviesServiceProtocol?
    private let watchlistStore: WatchlistStoreProtocol?
    private let watchlistActiveTintColor: UIColor
    private let watchlistInactiveTintColor: UIColor
    @ObservationIgnored private var hasLoadedDetails = false
    @ObservationIgnored private var watchlistTask: Task<Void, Never>?

    init(
        movie: Movie,
        moviesService: MoviesServiceProtocol?,
        watchlistStore: WatchlistStoreProtocol?,
        uiAssets: MovieDBUIAssetsProtocol?
    ) {
        self.movie = movie
        self.moviesService = moviesService
        self.watchlistStore = watchlistStore
        self.watchlistIcon = uiAssets?.heartIcon
        self.watchlistFilledIcon = uiAssets?.heartFilledIcon
        self.watchlistActiveTintColor = uiAssets?.watchlistActiveTintColor ?? .systemPink
        self.watchlistInactiveTintColor = uiAssets?.watchlistInactiveTintColor ?? .white
        self.state = .idle(content: Self.makeContent(movie: movie, details: nil), isInWatchlist: false)
    }

    var content: MovieDetailsContent {
        state.content
    }

    var isInWatchlist: Bool {
        state.isInWatchlist
    }

    var watchlistTintColor: UIColor {
        isInWatchlist ? watchlistActiveTintColor : watchlistInactiveTintColor
    }

    func toggleWatchlist() async {
        guard watchlistStore != nil else { return }
        state = state.replacing(isInWatchlist: !state.isInWatchlist)
        await watchlistStore?.toggle(movie: movie)
    }

    func loadDetailsIfNeeded() async {
        guard !hasLoadedDetails else { return }
        hasLoadedDetails = true
        guard let moviesService else { return }

        state = state.loading()
        do {
            let details = try await moviesService.fetchDetails(id: movie.id)
            state = .idle(
                content: Self.makeContent(movie: movie, details: details),
                isInWatchlist: state.isInWatchlist
            )
        } catch {
            state = state.idle()
        }
    }

    func startObserveWatchlist() {
        guard let watchlistStore else { return }
        watchlistTask?.cancel()
        watchlistTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await watchlistStore.itemsStream()
            for await items in stream {
                self.state = self.state.replacing(isInWatchlist: items.contains { $0.id == self.movie.id })
            }
        }
    }

    func stopObserveWatchlist() {
        watchlistTask?.cancel()
        watchlistTask = nil
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

    static func makePosterURL(path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
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
