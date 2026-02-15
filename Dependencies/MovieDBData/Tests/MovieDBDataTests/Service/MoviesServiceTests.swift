import Foundation
import Testing
@testable import AppHttpKit
@testable import MovieDBData

struct MoviesServiceTests {
    @Test
    func test_fetchPopular_shouldReturnExpectedResults() async throws {
        let environment = Environment()
        let sut = environment.makeSUT()
        environment.mockClient.responseReturnValue = environment.mockMovieCatalogResponse

        let response = try await sut.fetchPopular(options: .init(page: 1, language: "en"))
        #expect(response.results.isEmpty == false)
    }

    @Test
    func test_fetchTopRated_shouldReturnExpectedResults() async throws {
        let environment = Environment()
        let sut = environment.makeSUT()
        environment.mockClient.responseReturnValue = environment.mockMovieCatalogResponse

        let response = try await sut.fetchTopRated(options: .init(page: 1, language: "en"))
        #expect(response.results.isEmpty == false)
    }

    @Test
    func test_fetchDetails_shouldReturnExpectedResult() async throws {
        let environment = Environment()
        let sut = environment.makeSUT()
        environment.mockClient.responseReturnValue = environment.mockMovieDetailsResponse

        let response = try await sut.fetchDetails(id: 550)

        #expect(response.id == 550)
        #expect(response.title == "Fight Club")
        #expect(response.runtime == 139)
        #expect(response.genres.first?.name == "Drama")
    }
}

private final class Environment {
    let mockClient = MockClient()

    @SampleFile(fileName: "sample_movie_list.json")
    var movieListJSONURL: URL

    lazy var mockMovieCatalogResponse: Response = {
        let data: Data
        do {
            data = try Data(contentsOf: movieListJSONURL)
        } catch {
            fatalError("Failed to load sample data: \(error)")
        }
        return Response(
            request: Request(url: "/movie/popular"),
            response: URLResponse(),
            body: data
        )
    }()

    lazy var mockMovieDetailsResponse: Response = {
        let json = """
        {
          "id": 550,
          "title": "Fight Club",
          "original_title": "Fight Club",
          "original_language": "en",
          "overview": "Overview",
          "poster_path": "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
          "backdrop_path": "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
          "release_date": "1999-10-15",
          "runtime": 139,
          "vote_average": 8.4,
          "vote_count": 26280,
          "genres": [
            { "id": 18, "name": "Drama" }
          ],
          "spoken_languages": [
            { "english_name": "English", "iso_639_1": "en", "name": "English" }
          ]
        }
        """
        let data = Data(json.utf8)
        return Response(
            request: Request(url: "/movie/550"),
            response: URLResponse(),
            body: data
        )
    }()

    func makeSUT() -> MoviesServiceProtocol {
        MoviesService(apiKey: "MOCK_API_KEY", client: mockClient)
    }
}
