import AppHttpKit
import MovieDBData
import MovieDBUI

@MainActor
protocol DependenciesProviderProtocol {
    var serviceProvider: ServiceProviderProtocol { get }
    var assetsProvider: AssetsProviderProtocol { get }
    var storeProvider: StoreProviderProtocol { get }
    var renderProvider: RenderProviderProtocol { get }
}

final class DependenciesProvider: DependenciesProviderProtocol {
    let serviceProvider: ServiceProviderProtocol
    let assetsProvider: AssetsProviderProtocol
    let storeProvider: StoreProviderProtocol
    let renderProvider: RenderProviderProtocol

    init() {
        let baseURL = Environment.baseURLString
        let httpClient = HttpClient(baseURL: baseURL)
        let cache = ResponseCache()
        let policy = MovieDBCachePolicy()
        let cachingClient = CachingClient(
            baseURL: baseURL,
            client: httpClient,
            cache: cache,
            policy: policy
        )
        serviceProvider = ServiceProvider(apiKey: Environment.apiKey, httpClient: cachingClient)
        assetsProvider = AssetsProvider()
        storeProvider = StoreProvider()
        renderProvider = RenderProvider()
    }
}
