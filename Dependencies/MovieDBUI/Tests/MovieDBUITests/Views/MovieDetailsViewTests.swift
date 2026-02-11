@testable import MovieDBUI
import SnapshotTesting
import Testing

struct MovieDetailsViewTests {
    @Test
    @MainActor
    func test_movieDetailsView_whenConfigured_displaysDetails() async {
        let environment = Environment()
        let size = UIScreen.main.bounds.size
        let sut = environment.createSUT(size)
        environment.contentSizes.forEach {
            assertSnapshot(
                of: sut,
                size: size,
                interfaceStyle: .both,
                preferredContentSizeCategory: $0
            )
        }
    }
}

private struct Environment {
    let contentSizes: [UIContentSizeCategory] = [.medium, .accessibilityMedium, .accessibilityExtraLarge]

    func createSUT(_ size: CGSize) -> MovieDetailsView {
        let view = MovieDetailsView(frame: .init(origin: .zero, size: size))
        view.configure(with: MovieDetailsView.PreviewData.viewModel)
        return view
    }
}
