import Foundation
import Testing
import MovieDBData
@testable import MoviesDB

struct TopRatedInteractorTests {
    @Test
    @MainActor
    func test_viewDidLoad_whenInitial_shouldFetchTwoPagesAndPresentLoadedState() async throws {
        let environment = Environment.make()
        environment.service.fetchTopRatedHandler = { options in
            options.page == 1 ? environment.page1 : environment.page2
        }

        await environment.sut.viewDidLoad()
        let didFetch = await waitUntil { environment.service.fetchTopRatedCalls.count >= 2 }
        #expect(didFetch)

        let calls = environment.service.fetchTopRatedCalls
        #expect(calls.count == 2)
        #expect(calls[0].page == 1)
        #expect(calls[1].page == 2)

        let states = await MainActor.run { environment.presenter.states }
        let loadedStates = states.compactMap { state -> LoadedTopRated? in
            if case let .loaded(value) = state { return value }
            return nil
        }
        #expect(loadedStates.last?.movies.count == 4)
    }

    @Test
    @MainActor
    func test_didSelect_whenValidIndex_shouldNotifyOutput() async {
        let environment = Environment.make()
        environment.service.fetchTopRatedHandler = { _ in environment.page1 }

        await environment.sut.viewDidLoad()
        let didLoad = await waitUntil {
            await MainActor.run {
                environment.presenter.states.contains { state in
                    if case .loaded = state { return true }
                    return false
                }
            }
        }
        #expect(didLoad)

        await environment.sut.didSelect(item: 0)
        let selected = environment.output.selectedMovies
        #expect(selected.count == 1)
        #expect(selected.first?.id == environment.movie1.id)
    }

    @Test
    @MainActor
    func test_loadMore_whenNoMoreItems_shouldNotFetch() async {
        let environment = Environment.make()
        environment.service.fetchTopRatedHandler = { _ in environment.noMoreItemsPage }

        await environment.sut.viewDidLoad()
        let didFetch = await waitUntil { environment.service.fetchTopRatedCalls.count >= 1 }
        #expect(didFetch)

        await environment.sut.loadMore()
        let calls = environment.service.fetchTopRatedCalls
        #expect(calls.count == 1)
    }
}

private struct Environment {
    let sut: TopRatedInteractor
    let presenter: MockTopRatedPresenter
    let service: MockMoviesService
    let watchlistStore: MockWatchlistStore
    let output: MockTopRatedInteractorOutput

    let movie1 = Movie(
        adult: false,
        backdropPath: nil,
        genreIDS: [1],
        id: 1,
        originalLanguage: "en",
        originalTitle: "Movie 1",
        overview: "",
        popularity: 1,
        posterPath: "/poster1.jpg",
        releaseDate: "2025-01-01",
        title: "Movie 1",
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
        originalTitle: "Movie 2",
        overview: "",
        popularity: 2,
        posterPath: "/poster2.jpg",
        releaseDate: "2025-01-02",
        title: "Movie 2",
        video: false,
        voteAverage: 6,
        voteCount: 2
    )

    var page1: MovieList {
        MovieList(page: 1, results: [movie1, movie2], totalPages: 2, totalResults: 4)
    }

    var page2: MovieList {
        MovieList(page: 2, results: [movie1, movie2], totalPages: 2, totalResults: 4)
    }

    var noMoreItemsPage: MovieList {
        MovieList(page: 1, results: [movie1], totalPages: 1, totalResults: 1)
    }

    @MainActor
    static func make() -> Environment {
        let presenter = MockTopRatedPresenter()
        let service = MockMoviesService()
        let watchlistStore = MockWatchlistStore()
        let output = MockTopRatedInteractorOutput()
        let interactor = TopRatedInteractor(
            presenter: presenter,
            service: service,
            watchlistStore: watchlistStore,
            output: output,
            language: "en"
        )
        let environment = Environment(
            sut: interactor,
            presenter: presenter,
            service: service,
            watchlistStore: watchlistStore,
            output: output
        )
        environment.service.fetchTopRatedResult = .success(environment.page1)
        return environment
    }
}
