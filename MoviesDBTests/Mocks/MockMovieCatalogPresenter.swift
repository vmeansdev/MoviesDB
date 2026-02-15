import CoreGraphics
@testable import MoviesDB

@MainActor
final class MockMovieCatalogPresenter: MovieCatalogPresenterProtocol {
    private(set) var states: [MovieCatalogState] = []
    private(set) var posterRenderSizes: [CGSize] = []

    func present(state: MovieCatalogState) async {
        states.append(state)
    }

    func present(posterRenderSize: CGSize) async {
        posterRenderSizes.append(posterRenderSize)
    }
}
