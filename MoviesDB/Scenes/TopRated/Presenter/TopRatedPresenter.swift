import Foundation
import MovieDBData
import MovieDBUI
import UIKit

struct LoadedTopRated: Equatable {
    let currentPage: Int
    let totalPages: Int
    let totalResults: Int
    let movies: [Movie]
    let watchlistIds: Set<Int>

    var hasMoreItems: Bool {
        currentPage < totalPages
    }
}

enum TopRatedState: Equatable {
    case loading(isInitial: Bool)
    case loaded(LoadedTopRated)
    case error(Error, RetryAction?)

    static func == (lhs: TopRatedState, rhs: TopRatedState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.loaded(lhs), .loaded(rhs)):
            return lhs == rhs
        case let (.error(lhs, _), .error(rhs, _)):
            return lhs.localizedDescription == rhs.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
protocol TopRatedPresenterProtocol {
    func present(state: TopRatedState) async
}

final class TopRatedPresenter: TopRatedPresenterProtocol {
    weak var view: TopRatedPresentable?
    private let uiAssets: MovieDBUIAssetsProtocol

    init(uiAssets: MovieDBUIAssetsProtocol) {
        self.uiAssets = uiAssets
    }

    func present(state: TopRatedState) async {
        switch state {
        case let .loading(isInitial):
            view?.displayLoading(isInitial: isInitial)
        case let .loaded(topRated):
            let movies: [MovieCollectionViewModel] = topRated.movies.enumerated().map { index, movie in
                let posterURL = movie.posterPath.isEmpty ? nil : URL(string: "\(Constants.posterBaseURL)\(movie.posterPath)")
                let isInWatchlist = topRated.watchlistIds.contains(movie.id)
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
            view?.displayTitle(Constants.title(topRatedCount: movies.count))
            view?.displayMovies(movies)
        case let .error(error, action):
            view?.displayError(ErrorViewModel(errorMessage: error.localizedDescription, retryAction: action))
        }
    }

    private enum Constants {
        static var posterBaseURL: String { "\(Environment.imageBaseURLString)/t/p/w500" }
        static func title(topRatedCount: Int) -> String {
            String(format: String.localizable.topRatedCountTitle, topRatedCount)
        }
    }
}
