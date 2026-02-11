import Foundation
import Testing
import MovieDBData
import MovieDBUI
@testable import MoviesDB

struct TopRatedPresenterTests {
    @Test
    @MainActor
    func test_presentLoaded_shouldDisplayTitleAndMovies() async {
        let environment = Environment.make()
        let state = TopRatedState.loaded(environment.loadedTopRated)

        await environment.sut.present(state: state)

        #expect(environment.view.titleCalls.count == 1)
        #expect(environment.view.titleCalls.first == environment.expectedTitle)
        #expect(environment.view.moviesCalls.first?.count == environment.loadedTopRated.movies.count)
    }

    @Test
    @MainActor
    func test_presentLoading_shouldDisplayLoading() async {
        let environment = Environment.make()

        await environment.sut.present(state: .loading(isInitial: true))

        #expect(environment.view.loadingCalls == [true])
    }

    @Test
    @MainActor
    func test_presentError_shouldDisplayError() async {
        let environment = Environment.make()
        let error = NSError(domain: "test", code: 1)

        await environment.sut.present(state: .error(error, nil))

        #expect(environment.view.errorCalls.count == 1)
    }
}

private struct Environment {
    let sut: TopRatedPresenter
    let view: MockTopRatedView
    let loadedTopRated: LoadedTopRated
    let expectedTitle: String

    static func make() -> Environment {
        let view = MockTopRatedView()
        let presenter = TopRatedPresenter(uiAssets: MovieDBUIAssets.system)
        presenter.view = view

        let movies = [
            Movie(
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
            ),
            Movie(
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
        ]
        let loaded = LoadedTopRated(currentPage: 1, totalPages: 1, totalResults: 2, movies: movies, watchlistIds: [])
        let title = String(format: String.localizable.topRatedCountTitle, movies.count)
        return Environment(sut: presenter, view: view, loadedTopRated: loaded, expectedTitle: title)
    }
}
