import MovieDBUI
import Testing
@testable import MovieDBData
@testable import MoviesDB

struct MovieDetailsViewModelTests {
    private let posterURLProvider = PosterURLProvider(imageBaseURLString: "https://image.tmdb.org")

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

        let sut = MovieDetailsViewModel(
            movie: movie,
            moviesService: nil,
            watchlistStore: nil,
            uiAssets: nil,
            posterURLProvider: posterURLProvider
        )
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

    @Test
    @MainActor
    func test_loadDetailsIfNeeded_shouldUpdateContent() async {
        let movie = Movie(
            adult: false,
            backdropPath: "/backdrop.jpg",
            genreIDS: [18],
            id: 550,
            originalLanguage: "en",
            originalTitle: "Original Title",
            overview: "Overview text",
            popularity: 1,
            posterPath: "/poster.jpg",
            releaseDate: "1999-10-15",
            title: "Movie Title",
            video: false,
            voteAverage: 6.8,
            voteCount: 505
        )
        let service = MockMoviesService()
        service.fetchDetailsResult = .success(
            MovieDetails(
                id: 550,
                title: "Fight Club",
                originalTitle: "Fight Club",
                originalLanguage: "en",
                overview: "Detailed overview",
                posterPath: "/poster.jpg",
                backdropPath: "/backdrop.jpg",
                releaseDate: "1999-10-15",
                runtime: 139,
                voteAverage: 8.4,
                voteCount: 26280,
                genres: [MovieDetails.Genre(id: 18, name: "Drama")],
                spokenLanguages: []
            )
        )

        let sut = MovieDetailsViewModel(
            movie: movie,
            moviesService: service,
            watchlistStore: nil,
            uiAssets: nil,
            posterURLProvider: posterURLProvider
        )
        await sut.loadDetailsIfNeeded()
        let didFetch = await waitUntil { service.fetchDetailsCalls == [550] }
        #expect(didFetch)
        let content = sut.content

        #expect(content.title == "Fight Club")
        #expect(content.overview == "Detailed overview")
        #expect(content.metadata.contains(where: { $0.title == String.localizable.movieDetailsRuntimeLabel }) == true)
        #expect(content.metadata.contains(where: { $0.title == String.localizable.movieDetailsGenresLabel }) == true)
        #expect(service.fetchDetailsCalls == [550])
    }

    @Test
    @MainActor
    func test_loadDetailsIfNeeded_shouldOnlyLoadOnce() async {
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
        let service = MockMoviesService()
        let sut = MovieDetailsViewModel(
            movie: movie,
            moviesService: service,
            watchlistStore: nil,
            uiAssets: nil,
            posterURLProvider: posterURLProvider
        )

        await sut.loadDetailsIfNeeded()
        await sut.loadDetailsIfNeeded()

        let didFetchOnce = await waitUntil { service.fetchDetailsCalls.count == 1 }
        #expect(didFetchOnce)
    }
}
