import Foundation
import Testing
import MovieDBData
import MovieDBUI
@testable import MoviesDB

struct MovieCatalogPresenterTests {
    @Test
    @MainActor
    func test_presentLoaded_popular_shouldDisplayTitleAndMovies() async {
        let environment = Environment.make(kind: .popular)
        let state = MovieCatalogState.loaded(environment.loaded)

        await environment.sut.present(state: state)

        #expect(environment.view.titleCalls.first == environment.expectedTitle)
        #expect(environment.view.moviesCalls.first?.count == environment.loaded.movies.count)
    }

    @Test
    @MainActor
    func test_presentLoaded_topRated_shouldDisplayTitleAndMovies() async {
        let environment = Environment.make(kind: .topRated)

        await environment.sut.present(state: .loaded(environment.loaded))

        #expect(environment.view.titleCalls.first == environment.expectedTitle)
        #expect(environment.view.moviesCalls.first?.count == environment.loaded.movies.count)
    }

    @Test
    @MainActor
    func test_presentLoading_shouldDisplayLoading() async {
        let environment = Environment.make(kind: .popular)

        await environment.sut.present(state: .loading(isInitial: true))

        #expect(environment.view.loadingCalls == [true])
    }

    @Test
    @MainActor
    func test_presentError_shouldDisplayError() async {
        let environment = Environment.make(kind: .popular)
        let error = NSError(domain: "test", code: 1)

        await environment.sut.present(state: .error(error, nil))

        #expect(environment.view.errorCalls.count == 1)
    }
}

private struct Environment {
    let sut: MovieCatalogPresenter
    let view: MockMovieCatalogView
    let loaded: LoadedMovieCatalog
    let expectedTitle: String

    @MainActor
    static func make(kind: MovieCatalogKind) -> Environment {
        let view = MockMovieCatalogView()
        let mapper = MovieCatalogViewModelMapper(
            uiAssets: MovieDBUIAssets.system,
            posterURLProvider: PosterURLProvider(imageBaseURLString: "https://image.tmdb.org")
        )
        let presenter = MovieCatalogPresenter(mapper: mapper, kind: kind)
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
        let loaded = LoadedMovieCatalog(currentPage: 1, totalPages: 1, totalResults: 2, movies: movies, watchlistIds: [])
        let title = kind.title(count: movies.count)
        return Environment(sut: presenter, view: view, loaded: loaded, expectedTitle: title)
    }
}
