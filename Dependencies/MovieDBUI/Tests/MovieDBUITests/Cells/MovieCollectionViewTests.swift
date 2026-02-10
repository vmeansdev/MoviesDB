@testable import MovieDBUI
import XCTest
import SnapshotTesting

final class MovieCollectionViewTests: XCTestCase {
    func test_movieCollectionViewCell_whenConfigured_thenDisplaysMovie() {
        let environment = Environment()
        let size = CGSize(width: UIScreen.main.bounds.width, height: 250.0)
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

    func createSUT(_ size: CGSize) -> MovieCollectionViewCell {
        let cell = MovieCollectionViewCell(frame: CGRect(origin: .zero, size: size))
        cell.configure(with: MovieCollectionViewCell.PreviewData.viewModel)
        return cell
    }
}
