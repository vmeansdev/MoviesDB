import AppHttpKit
import Foundation

public protocol MoviesServiceProtocol: Sendable {
    func fetchPopular(options: MovieCatalogOptions) async throws -> MovieCatalog
    func fetchTopRated(options: MovieCatalogOptions) async throws -> MovieCatalog
    func fetchDetails(id: Int) async throws -> MovieDetails
}

public final class MoviesService: MoviesServiceProtocol, @unchecked Sendable {
    private let apiKey: String
    private let client: Client
    private let decoder: JSONDecoder

    public init(apiKey: String, client: Client, decoder: JSONDecoder = JSONDecoder()) {
        self.apiKey = apiKey
        self.client = client
        self.decoder = decoder
    }

    public func fetchPopular(options: MovieCatalogOptions) async throws -> MovieCatalog {
        let response = try await client.get("movie/popular", queryParams: options.buildParams(with: .init(apiKey: apiKey)))
        return try decoder.decode(MovieCatalog.self, from: response)
    }

    public func fetchTopRated(options: MovieCatalogOptions) async throws -> MovieCatalog {
        let response = try await client.get("movie/top_rated", queryParams: options.buildParams(with: .init(apiKey: apiKey)))
        return try decoder.decode(MovieCatalog.self, from: response)
    }

    public func fetchDetails(id: Int) async throws -> MovieDetails {
        let response = try await client.get("movie/\(id)", queryParams: KeyParameters(apiKey: apiKey))
        return try decoder.decode(MovieDetails.self, from: response)
    }
}
