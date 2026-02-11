import MovieDBUI
import Testing
@testable import MoviesDB

struct MovieDetailsViewControllerTests {
    @Test
    @MainActor
    func test_init_shouldStoreRootView() async {
        let viewModel = MovieDetailsViewModel(
            content: MovieDetailsContent(
                title: "Title",
                subtitle: nil,
                overviewTitle: "Overview",
                overview: "Overview",
                metadata: [],
                posterURL: nil,
                backdropURL: nil
            )
        )
        let rootView = MovieDetailsView(viewModel: viewModel)
        let sut = MovieDetailsViewController(rootView: rootView)

        #expect(sut.rootView is MovieDetailsView)
    }
}
