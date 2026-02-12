import MovieDBData
import MovieDBUI
import UIKit

typealias RetryAction = @MainActor @Sendable () -> Void

protocol MovieListLoadedState {
    var movies: [Movie] { get }
    var watchlistIds: Set<Int> { get }
}

struct MovieListViewModelMapper {
    let uiAssets: MovieDBUIAssetsProtocol

    func makeMovies(from loaded: MovieListLoadedState) -> [MovieCollectionViewModel] {
        loaded.movies.enumerated().map { index, movie in
            let posterURL = movie.posterPath.isEmpty ? nil : URL(string: "\(Constants.posterBaseURL)\(movie.posterPath)")
            let isInWatchlist = loaded.watchlistIds.contains(movie.id)
            let watchlistTintColor: UIColor = isInWatchlist ? .systemPink : .white
            let watchlistIcon = isInWatchlist ? uiAssets.heartFilledIcon : uiAssets.heartIcon
            return MovieCollectionViewModel(
                id: "\(movie.id)-\(index)",
                title: movie.title,
                subtitle: movie.releaseDate ?? "",
                posterURL: posterURL,
                watchlistIcon: watchlistIcon,
                watchlistSelectedIcon: nil,
                watchlistTintColor: watchlistTintColor,
                isInWatchlist: isInWatchlist
            )
        }
    }
}

private enum Constants {
    static var posterBaseURL: String { "\(Environment.imageBaseURLString)/t/p/w500" }
}
