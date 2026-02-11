import Foundation
import MovieDBData

final class MockMoviesService: MoviesServiceProtocol {
    private(set) var fetchPopularCalls: [MovieListOptions] = []
    var fetchPopularResult: Result<MovieList, Error> = .success(MovieList())
    var fetchPopularHandler: ((MovieListOptions) throws -> MovieList)?

    private(set) var fetchTopRatedCalls: [MovieListOptions] = []
    var fetchTopRatedResult: Result<MovieList, Error> = .success(MovieList())
    var fetchTopRatedHandler: ((MovieListOptions) throws -> MovieList)?
    private(set) var fetchDetailsCalls: [Int] = []
    var fetchDetailsResult: Result<MovieDetails, Error> = .success(
        MovieDetails(
            id: 0,
            title: "",
            originalTitle: "",
            originalLanguage: "",
            overview: "",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            runtime: nil,
            voteAverage: 0,
            voteCount: 0,
            genres: [],
            spokenLanguages: []
        )
    )
    var fetchDetailsHandler: ((Int) throws -> MovieDetails)?

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

    func fetchDetails(id: Int) async throws -> MovieDetails {
        fetchDetailsCalls.append(id)
        if let handler = fetchDetailsHandler {
            return try handler(id)
        }
        return try fetchDetailsResult.get()
    }
}
