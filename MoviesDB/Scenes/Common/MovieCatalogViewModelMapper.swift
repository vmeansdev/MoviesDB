import MovieDBData
import MovieDBUI
import UIKit

typealias RetryAction = @MainActor @Sendable () -> Void

protocol MovieCatalogLoadedState {
    var movies: [Movie] { get }
    var watchlistIds: Set<Int> { get }
}

protocol MovieCatalogViewModelMapping: Sendable {
    func makeMovie(movie: Movie, isInWatchlist: Bool) -> MovieCollectionViewModel
    func makeMovies(from loaded: MovieCatalogLoadedState) -> [MovieCollectionViewModel]
}

struct MovieCatalogViewModelMapper: MovieCatalogViewModelMapping {
    let uiAssets: MovieDBUIAssetsProtocol
    let posterURLProvider: any PosterURLProviding

    func makeMovie(movie: Movie, isInWatchlist: Bool) -> MovieCollectionViewModel {
        let posterURL = posterURLProvider.makePosterOrBackdropURL(
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath
        )
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
