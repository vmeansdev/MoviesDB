import Foundation
import Testing
import MovieDBData
import MovieDBUI
@testable import MoviesDB

@MainActor
struct MovieCatalogInteractorTests {
    @Test
    func test_viewDidLoad_popular_shouldFetchTwoPagesAndPresentLoadedState() async {
        let environment = Environment.make(kind: .popular)
        environment.service.fetchPopularHandler = { options in
            switch options.page {
            case 1: environment.page1
            default: environment.page2
            }
        }

        await environment.sut.viewDidLoad()
        let didFetch = await waitUntil { environment.service.fetchPopularCalls.count >= 2 }

        #expect(didFetch)
        let calls = environment.service.fetchPopularCalls
        #expect(calls.count >= 2)
        #expect(calls[0].page == 1)
        #expect(calls[1].page == 2)

        let states = environment.presenter.states
        let loadedStates = states.compactMap { state -> LoadedMovieCatalog? in
            if case let .loaded(loaded) = state { return loaded }
            return nil
        }

        #expect(loadedStates.last?.movies.count == 2)
    }

    @Test
    func test_viewDidLoad_topRated_shouldUseTopRatedEndpoint() async {
        let environment = Environment.make(kind: .topRated)
        environment.service.fetchTopRatedHandler = { _ in environment.page1 }

        await environment.sut.viewDidLoad()
        let didFetch = await waitUntil { environment.service.fetchTopRatedCalls.count >= 1 }

        #expect(didFetch)
        #expect(environment.service.fetchPopularCalls.isEmpty)
        #expect(environment.service.fetchTopRatedCalls.count >= 1)
    }

    @Test
    func test_didSelect_whenValidIndex_shouldNotifyOutput() async {
        let environment = Environment.make(kind: .popular)
        environment.service.fetchPopularHandler = { _ in environment.page1 }
        await environment.sut.viewDidLoad()
        _ = await waitUntil { environment.service.fetchPopularCalls.count >= 1 }

        await environment.sut.didSelect(item: 0)

        #expect(environment.output.selectedMovies.count == 1)
        #expect(environment.output.selectedMovies.first?.id == environment.movie1.id)
    }

    @Test
    func test_loadMore_whenNoMoreItems_shouldNotFetch() async {
        let environment = Environment.make(kind: .popular)
        environment.service.fetchPopularHandler = { _ in environment.noMoreItemsPage }

        await environment.sut.viewDidLoad()
        _ = await waitUntil { environment.service.fetchPopularCalls.count >= 1 }

        await environment.sut.loadMore()

        #expect(environment.service.fetchPopularCalls.count == 1)
    }
}

private struct Environment {
    let sut: MovieCatalogInteractor
    let presenter: MockMovieCatalogPresenter
    let service: MockMoviesService
    let watchlistStore: MockWatchlistStore
    let output: MockMovieCatalogInteractorOutput

    let movie1 = Movie(
        adult: false,
        backdropPath: nil,
        genreIDS: [1],
        id: 1,
        originalLanguage: "en",
        originalTitle: "A",
        overview: "",
        popularity: 1,
        posterPath: "/a.jpg",
        releaseDate: "2024-01-01",
        title: "A",
        video: false,
        voteAverage: 5,
        voteCount: 1
    )

    let movie2 = Movie(
        adult: false,
        backdropPath: nil,
        genreIDS: [2],
        id: 2,
        originalLanguage: "en",
        originalTitle: "B",
        overview: "",
        popularity: 2,
        posterPath: "/b.jpg",
        releaseDate: "2024-01-02",
        title: "B",
        video: false,
        voteAverage: 6,
        voteCount: 2
    )

    var page1: MovieCatalog {
        MovieCatalog(page: 1, results: [movie1, movie2], totalPages: 2, totalResults: 4)
    }

    var page2: MovieCatalog {
        MovieCatalog(page: 2, results: [movie1, movie2], totalPages: 2, totalResults: 4)
    }

    var noMoreItemsPage: MovieCatalog {
        MovieCatalog(page: 1, results: [movie1], totalPages: 1, totalResults: 1)
    }

    @MainActor
    static func make(kind: MovieCatalogKind) -> Environment {
        let presenter = MockMovieCatalogPresenter()
        let service = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let output = MockMovieCatalogInteractorOutput()
        let interactor = MovieCatalogInteractor(
            kind: kind,
            presenter: presenter,
            service: service,
            watchlistStore: watchlistStore,
            output: output,
            posterPrefetchController: PosterPrefetchController(posterImagePrefetcher: PosterImagePrefetcher.shared),
            posterRenderSizeProvider: PosterRenderSizeProvider(),
            posterURLProvider: PosterURLProvider(imageBaseURLString: "https://image.tmdb.org"),
            language: "en"
        )
        return Environment(
            sut: interactor,
            presenter: presenter,
            service: service,
            watchlistStore: watchlistStore,
            output: output
        )
    }
}
