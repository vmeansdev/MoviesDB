import CoreGraphics
import Foundation
import MovieDBData
import MovieDBUI

nonisolated struct LoadedMovieCatalog: Equatable, Sendable, MovieCatalogLoadedState {
    let currentPage: Int
    let totalPages: Int
    let totalResults: Int
    let movies: [Movie]
    let watchlistIds: Set<Int>

    var hasMoreItems: Bool {
        currentPage < totalPages
    }

    init(currentPage: Int, totalPages: Int, totalResults: Int, movies: [Movie], watchlistIds: Set<Int>) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalResults = totalResults
        self.movies = movies
        self.watchlistIds = watchlistIds
    }

}

nonisolated enum MovieCatalogState: Equatable, Sendable {
    case loading(isInitial: Bool)
    case loaded(LoadedMovieCatalog)
    case error(Error, RetryAction?)

    static func == (lhs: MovieCatalogState, rhs: MovieCatalogState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            true
        case let (.loaded(lhs), .loaded(rhs)):
            lhs == rhs
        case let (.error(lhs, _), .error(rhs, _)):
            lhs.localizedDescription == rhs.localizedDescription
        default:
            false
        }
    }
}

@MainActor
protocol MovieCatalogPresenterProtocol: Sendable {
    func present(state: MovieCatalogState) async
    func present(posterRenderSize: CGSize) async
}

final class MovieCatalogPresenter: MovieCatalogPresenterProtocol, @unchecked Sendable {
    weak var view: MovieCatalogPresentable?
    private let mapper: any MovieCatalogViewModelMapping
    private let kind: MovieCatalogKind

    init(mapper: any MovieCatalogViewModelMapping, kind: MovieCatalogKind) {
        self.mapper = mapper
        self.kind = kind
    }

    func present(state: MovieCatalogState) async {
        switch state {
        case let .loading(isInitial):
            view?.displayLoading(isInitial: isInitial)
        case let .loaded(catalog):
            let movies = mapper.makeMovies(from: catalog)
            view?.displayTitle(kind.title(count: movies.count))
            view?.displayMovies(movies)
        case let .error(error, action):
            view?.displayError(ErrorViewModel(errorMessage: error.localizedDescription, retryAction: action))
        }
    }

    func present(posterRenderSize: CGSize) async {
        view?.displayPosterRenderSize(posterRenderSize)
    }
}
