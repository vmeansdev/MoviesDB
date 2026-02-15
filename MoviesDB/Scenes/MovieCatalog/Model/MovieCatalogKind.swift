import Foundation
import MovieDBData

enum MovieCatalogKind: Sendable {
    case popular
    case topRated

    func fetch(using service: MoviesServiceProtocol, options: MovieCatalogOptions) async throws -> MovieCatalog {
        switch self {
        case .popular:
            try await service.fetchPopular(options: options)
        case .topRated:
            try await service.fetchTopRated(options: options)
        }
    }

    func title(count: Int) -> String {
        switch self {
        case .popular:
            String(format: String.localizable.popularCountTitle, count)
        case .topRated:
            String(format: String.localizable.topRatedCountTitle, count)
        }
    }
}
