import Foundation
import Testing
@testable import MovieDBData

struct MovieDecodingTests {
    @Test
    func test_movieListDecode_allowsNullPosterPath() throws {
        let json = """
        {
          "page": 1,
          "results": [
            {
              "adult": false,
              "backdrop_path": null,
              "genre_ids": [28],
              "id": 123,
              "original_language": "en",
              "original_title": "Sample",
              "overview": "Overview",
              "popularity": 1.0,
              "poster_path": null,
              "release_date": "2025-01-01",
              "title": "Sample",
              "video": false,
              "vote_average": 7.0,
              "vote_count": 10
            }
          ],
          "total_pages": 1,
          "total_results": 1
        }
        """

        let movieList = try JSONDecoder().decode(MovieCatalog.self, from: Data(json.utf8))

        #expect(movieList.results.count == 1)
        #expect(movieList.results[0].posterPath == nil)
    }
}
