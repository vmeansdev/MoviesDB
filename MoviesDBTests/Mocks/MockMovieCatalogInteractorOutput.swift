import MovieDBData
@testable import MoviesDB

@MainActor
final class MockMovieCatalogInteractorOutput: MovieCatalogInteractorOutput {
    private(set) var selectedMovies: [Movie] = []

    func didSelect(movie: Movie) {
        selectedMovies.append(movie)
    }
}
