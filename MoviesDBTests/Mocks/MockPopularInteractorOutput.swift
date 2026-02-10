import MovieDBData
@testable import MoviesDB

@MainActor
final class MockPopularInteractorOutput: PopularInteractorOutput {
    private(set) var selectedMovies: [Movie] = []

    func didSelect(movie: Movie) {
        selectedMovies.append(movie)
    }
}
