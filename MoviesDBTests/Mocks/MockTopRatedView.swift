import MovieDBUI
@testable import MoviesDB

@MainActor
final class MockTopRatedView: MovieListPresentable {
    private(set) var loadingCalls: [Bool] = []
    private(set) var moviesCalls: [[MovieCollectionViewModel]] = []
    private(set) var errorCalls: [ErrorViewModel] = []
    private(set) var titleCalls: [String] = []

    func displayLoading(isInitial: Bool) {
        loadingCalls.append(isInitial)
    }

    func displayMovies(_ movies: [MovieCollectionViewModel]) {
        moviesCalls.append(movies)
    }

    func displayError(_ error: ErrorViewModel) {
        errorCalls.append(error)
    }

    func displayTitle(_ title: String) {
        titleCalls.append(title)
    }
}
