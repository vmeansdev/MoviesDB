import MovieDBData
@testable import MoviesDB

final class MockServiceProvider: ServiceProviderProtocol {
    let moviesService: MoviesServiceProtocol

    init(moviesService: MoviesServiceProtocol) {
        self.moviesService = moviesService
    }
}
