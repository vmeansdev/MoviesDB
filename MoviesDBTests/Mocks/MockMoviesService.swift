import Foundation
import MovieDBData

final class MockMoviesService: MoviesServiceProtocol, @unchecked Sendable {
    private(set) var fetchPopularCalls: [MovieCatalogOptions] = []
    var fetchPopularResult: Result<MovieCatalog, Error> = .success(MovieCatalog())
    var fetchPopularHandler: ((MovieCatalogOptions) throws -> MovieCatalog)?

    private(set) var fetchTopRatedCalls: [MovieCatalogOptions] = []
    var fetchTopRatedResult: Result<MovieCatalog, Error> = .success(MovieCatalog())
    var fetchTopRatedHandler: ((MovieCatalogOptions) throws -> MovieCatalog)?
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

    func fetchPopular(options: MovieCatalogOptions) async throws -> MovieCatalog {
        fetchPopularCalls.append(options)
        if let handler = fetchPopularHandler {
            return try handler(options)
        }
        return try fetchPopularResult.get()
    }

    func fetchTopRated(options: MovieCatalogOptions) async throws -> MovieCatalog {
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
