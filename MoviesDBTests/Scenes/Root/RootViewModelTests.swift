import Foundation
import MovieDBUI
import Testing
@testable import MovieDBData
@testable import MoviesDB

@MainActor
struct RootViewModelTests {
    @Test
    func test_init_buildsFeatureViewModelsUsingRenderProvider() {
        let moviesService = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let posterRenderSizeProvider = MockPosterRenderSizeProvider()
        let posterImagePrefetcher = MockPosterImagePrefetcher()
        let renderProvider = MockRenderProvider(
            posterRenderSizeProvider: posterRenderSizeProvider,
            posterImagePrefetcher: posterImagePrefetcher
        )
        let dependencies = MockDependenciesProvider(
            serviceProvider: MockServiceProvider(moviesService: moviesService),
            assetsProvider: MockAssetsProvider(uiAssets: MovieDBUIAssets.system),
            storeProvider: MockStoreProvider(watchlistStore: watchlistStore),
            renderProvider: renderProvider
        )

        let sut = RootViewModel(dependenciesProvider: dependencies)

        #expect(renderProvider.makePosterPrefetchControllerCallsCount == 3)
        #expect(sut.state.posterRenderSizeProvider as? MockPosterRenderSizeProvider === posterRenderSizeProvider)
    }

    @Test
    func test_makeMovieDetailsViewModel_buildsViewModelFromDependencies() {
        let moviesService = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let posterRenderSizeProvider = MockPosterRenderSizeProvider()
        let posterImagePrefetcher = MockPosterImagePrefetcher()
        let renderProvider = MockRenderProvider(
            posterRenderSizeProvider: posterRenderSizeProvider,
            posterImagePrefetcher: posterImagePrefetcher
        )
        let dependencies = MockDependenciesProvider(
            serviceProvider: MockServiceProvider(moviesService: moviesService),
            assetsProvider: MockAssetsProvider(uiAssets: MovieDBUIAssets.system),
            storeProvider: MockStoreProvider(watchlistStore: watchlistStore),
            renderProvider: renderProvider
        )
        let sut = RootViewModel(dependenciesProvider: dependencies)
        let movie = makeMovie(id: 101)

        let detailsViewModel = sut.makeMovieDetailsViewModel(movie: movie)

        #expect(detailsViewModel.content.title == "Movie 101")
        #expect(detailsViewModel.isInWatchlist == false)
    }

    private func makeMovie(id: Int) -> Movie {
        Movie(
            adult: false,
            backdropPath: "/backdrop\(id).jpg",
            genreIDS: [1],
            id: id,
            originalLanguage: "en",
            originalTitle: "Original \(id)",
            overview: "Overview \(id)",
            popularity: 1,
            posterPath: "/poster\(id).jpg",
            releaseDate: "2026-01-\(String(format: "%02d", min(id, 28)))",
            title: "Movie \(id)",
            video: false,
            voteAverage: 7.1,
            voteCount: 10
        )
    }
}
