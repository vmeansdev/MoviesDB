import MovieDBData
import MovieDBUI
import Testing
@testable import MoviesDB

struct MovieDetailsViewControllerTests {
    @Test
    @MainActor
    func test_init_shouldCreateHostingController() async {
        let movie = Movie(
            adult: false,
            backdropPath: "/backdrop.jpg",
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
        let sut = MovieDetailsViewController(movie: movie)

        #expect(sut.rootView is MovieDetailsView)
    }
}
