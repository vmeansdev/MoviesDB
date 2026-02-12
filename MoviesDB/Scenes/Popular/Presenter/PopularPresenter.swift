import Foundation
import MovieDBData
import MovieDBUI
import UIKit

struct LoadedPopular: Equatable, Sendable, MovieListLoadedState {
    let currentPage: Int
    let totalPages: Int
    let totalResults: Int
    let movies: [Movie]
    let watchlistIds: Set<Int>

    var hasMoreItems: Bool {
        currentPage < totalPages
    }
}

enum PopularState: Equatable, Sendable {
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
    weak var view: MovieListPresentable?
    private let mapper: MovieListViewModelMapper

    init(mapper: MovieListViewModelMapper) {
        self.mapper = mapper
    }

    func present(state: PopularState) async {
        switch state {
        case let .loading(isInitial):
            view?.displayLoading(isInitial: isInitial)
        case let .loaded(popular):
            let movies = mapper.makeMovies(from: popular)
            view?.displayTitle(Constants.title(popularCount: movies.count))
            view?.displayMovies(movies)
        case let .error(error, action):
            view?.displayError(ErrorViewModel(errorMessage: error.localizedDescription, retryAction: action))
        }
    }
}

private enum Constants {
    static func title(popularCount: Int) -> String {
        String(format: String.localizable.popularCountTitle, popularCount)
    }
}
