import AppHttpKit
import MovieDBData

protocol ServiceProviderProtocol {
    var moviesService: MoviesServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
    private let apiKey: String
    private let httpClient: Client

    init(apiKey: String, httpClient: Client) {
        self.apiKey = apiKey
        self.httpClient = httpClient
    }

    var moviesService: MoviesServiceProtocol {
        MoviesService(apiKey: apiKey, client: httpClient)
    }
}
