import MovieDBData
import MovieDBUI
import Testing
@testable import MoviesDB

struct MovieDetailsViewModelTests {
    @Test
    @MainActor
    func test_initWithMovie_shouldMapContent() async {
        let movie = Movie(
            adult: false,
            backdropPath: "/backdrop.jpg",
            genreIDS: [1],
            id: 1,
            originalLanguage: "en",
            originalTitle: "Original Title",
            overview: "Overview text",
            popularity: 1,
            posterPath: "/poster.jpg",
            releaseDate: "2026-01-07",
            title: "Movie Title",
            video: false,
            voteAverage: 6.8,
            voteCount: 505
        )

        let sut = MovieDetailsViewModel(movie: movie)
        let content = sut.content

        #expect(content.title == "Movie Title")
        #expect(content.overview == "Overview text")
        #expect(content.subtitle == ["2026-01-07", "EN"].joined(separator: String.localizable.movieDetailsSubtitleSeparator))
        #expect(content.metadata.contains(where: { $0.title == String.localizable.movieDetailsRatingLabel }) == true)
        #expect(content.metadata.contains(where: { $0.title == String.localizable.movieDetailsVotesLabel }) == true)
        #expect(content.metadata.contains(where: { $0.title == String.localizable.movieDetailsReleaseDateLabel }) == true)
        #expect(content.metadata.contains(where: { $0.title == String.localizable.movieDetailsLanguageLabel }) == true)
        #expect(content.metadata.contains(where: { $0.title == String.localizable.movieDetailsOriginalTitleLabel }) == true)
    }
}
