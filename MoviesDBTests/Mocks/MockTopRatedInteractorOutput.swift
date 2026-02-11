import MovieDBData
@testable import MoviesDB

@MainActor
final class MockTopRatedInteractorOutput: TopRatedInteractorOutput {
    private(set) var selectedMovies: [Movie] = []

    func didSelect(movie: Movie) {
        selectedMovies.append(movie)
    }
}
