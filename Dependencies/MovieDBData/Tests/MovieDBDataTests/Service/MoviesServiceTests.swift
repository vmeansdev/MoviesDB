import Foundation
import Testing
@testable import AppHttpKit
@testable import MovieDBData

struct MoviesServiceTests {
    @Test
    func fetchPopular_returnsExpectedResults() async throws {
        let environment = Environment()
        let sut = environment.makeSUT()
        environment.mockClient.responseReturnValue = environment.mockMovieListResponse

        let response = try await sut.fetchPopular(options: .init(page: 1, language: "en"))
        #expect(response.results.isEmpty == false)
    }

    @Test
    func fetchTopRated_returnsExpectedResults() async throws {
        let environment = Environment()
        let sut = environment.makeSUT()
        environment.mockClient.responseReturnValue = environment.mockMovieListResponse

        let response = try await sut.fetchTopRated(options: .init(page: 1, language: "en"))
        #expect(response.results.isEmpty == false)
    }
}

private final class Environment {
    let mockClient = MockClient()

    @SampleFile(fileName: "sample_movie_list.json")
    var movieListJSONURL: URL

    lazy var mockMovieListResponse: Response = {
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

    func makeSUT() -> MoviesServiceProtocol {
        MoviesService(apiKey: "MOCK_API_KEY", client: mockClient)
    }
}
