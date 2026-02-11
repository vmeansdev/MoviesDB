import MovieDBData
import Testing
import UIKit
@testable import MoviesDB

struct MovieDetailsCoordinatorTests {
    @Test
    @MainActor
    func test_start_shouldPushMovieDetailsViewController() async {
        let navigationController = UINavigationController()
        let movie = Movie(
            adult: false,
            backdropPath: nil,
            genreIDS: [],
            id: 1,
            originalLanguage: "en",
            originalTitle: "Original",
            overview: "Overview",
            popularity: 1,
            posterPath: "/poster.jpg",
            releaseDate: "2026-01-01",
            title: "Title",
            video: false,
            voteAverage: 7.0,
            voteCount: 10
        )
        let dependenciesProvider = MockDependenciesProvider()
        let sut = MovieDetailsCoordinator(
            rootViewController: navigationController,
            movie: movie,
            dependenciesProvider: dependenciesProvider
        )

        sut.start()

        #expect(navigationController.topViewController is MovieDetailsViewController)
    }
}
