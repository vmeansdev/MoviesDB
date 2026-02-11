import MovieDBUI
@testable import MoviesDB

final class MockDependenciesProvider: DependenciesProviderProtocol {
    let coordinatorProvider: CoordinatorProviderProtocol
    let serviceProvider: ServiceProviderProtocol
    let uiAssets: MovieDBUIAssetsProtocol

    init() {
        serviceProvider = MockServiceProvider(moviesService: MockMoviesService())
        coordinatorProvider = MockCoordinatorProvider()
        uiAssets = MovieDBUIAssets.system
    }
}
