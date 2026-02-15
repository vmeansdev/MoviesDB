import MovieDBData
import MovieDBUI
import UIKit

typealias RetryAction = @MainActor @Sendable () -> Void

protocol MovieCatalogLoadedState {
    var movies: [Movie] { get }
    var watchlistIds: Set<Int> { get }
}

struct MovieCatalogViewModelMapper {
    let uiAssets: MovieDBUIAssetsProtocol

    func makeMovie(movie: Movie, isInWatchlist: Bool) -> MovieCollectionViewModel {
        let posterURL = makePosterURL(path: movie.posterPath) ?? makeBackdropURL(path: movie.backdropPath)
        let watchlistTintColor: UIColor = isInWatchlist ? .systemPink : .white
        let watchlistIcon = isInWatchlist ? uiAssets.heartFilledIcon : uiAssets.heartIcon
        return MovieCollectionViewModel(
            id: String(movie.id),
            title: movie.title,
            subtitle: movie.releaseDate ?? "",
            posterURL: posterURL,
            watchlistIcon: watchlistIcon,
            watchlistSelectedIcon: nil,
            watchlistTintColor: watchlistTintColor,
            isInWatchlist: isInWatchlist
        )
    }

    func makeMovies(from loaded: MovieCatalogLoadedState) -> [MovieCollectionViewModel] {
        loaded.movies.map { movie in
            makeMovie(movie: movie, isInWatchlist: loaded.watchlistIds.contains(movie.id))
        }
    }
}

private enum Constants {
    static var posterBaseURL: String { "\(Environment.imageBaseURLString)/t/p/w500" }
    static var backdropBaseURL: String { "\(Environment.imageBaseURLString)/t/p/w780" }
}

private func makePosterURL(path: String?) -> URL? {
    guard let path, !path.isEmpty else { return nil }
    return URL(string: "\(Constants.posterBaseURL)\(path)")
}

private func makeBackdropURL(path: String?) -> URL? {
    guard let path, !path.isEmpty else { return nil }
    return URL(string: "\(Constants.backdropBaseURL)\(path)")
}
