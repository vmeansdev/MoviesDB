import Foundation
import MovieDBData
import MovieDBUI

struct LoadedPopular: Equatable {
    let currentPage: Int
    let totalPages: Int
    let totalResults: Int
    let movies: [Movie]

    var hasMoreItems: Bool {
        currentPage < totalPages
    }
}

typealias RetryAction = @MainActor @Sendable () -> Void

enum PopularState: Equatable {
    case loading(isInitial: Bool)
    case loaded(LoadedPopular)
    case error(Error, RetryAction?)

    static func == (lhs: PopularState, rhs: PopularState) -> Bool {
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
protocol PopularPresenterProtocol {
    func present(state: PopularState) async
}

final class PopularPresenter: PopularPresenterProtocol {
    weak var view: PopularPresentable?

    func present(state: PopularState) async {
        switch state {
        case let .loading(isInitial):
            view?.displayLoading(isInitial: isInitial)
        case let .loaded(popular):
            let movies: [MovieCollectionViewModel] = popular.movies.enumerated().map { index, movie in
                let posterURL = movie.posterPath.isEmpty ? nil : URL(string: "\(Constants.posterBaseURL)\(movie.posterPath)")
                return MovieCollectionViewModel(
                    id: "\(movie.id)-\(index)",
                    title: movie.title,
                    subtitle: movie.releaseDate ?? "",
                    posterURL: posterURL
                )
            }
            view?.displayTitle(Constants.title(popularCount: movies.count))
            view?.displayMovies(movies)
        case let .error(error, action):
            view?.displayError(ErrorViewModel(errorMessage: error.localizedDescription, retryAction: action))
        }
    }

    private enum Constants {
        static var posterBaseURL: String { "\(Environment.imageBaseURLString)/t/p/w500" }
        static func title(popularCount: Int) -> String {
            String(format: String.localizable.popularCountTitle, popularCount)
        }
    }
}
