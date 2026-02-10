import Foundation
import MovieDBData

final class MockMoviesService: MoviesServiceProtocol {
    private(set) var fetchPopularCalls: [MovieListOptions] = []
    var fetchPopularResult: Result<MovieList, Error> = .success(MovieList())
    var fetchPopularHandler: ((MovieListOptions) throws -> MovieList)?

    private(set) var fetchTopRatedCalls: [MovieListOptions] = []
    var fetchTopRatedResult: Result<MovieList, Error> = .success(MovieList())
    var fetchTopRatedHandler: ((MovieListOptions) throws -> MovieList)?

    func fetchPopular(options: MovieListOptions) async throws -> MovieList {
        fetchPopularCalls.append(options)
        if let handler = fetchPopularHandler {
            return try handler(options)
        }
        return try fetchPopularResult.get()
    }

    func fetchTopRated(options: MovieListOptions) async throws -> MovieList {
        fetchTopRatedCalls.append(options)
        if let handler = fetchTopRatedHandler {
            return try handler(options)
        }
        return try fetchTopRatedResult.get()
    }
}
