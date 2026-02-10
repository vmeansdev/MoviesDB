@testable import MovieDBUI
import XCTest
import SnapshotTesting

final class ErrorViewControllerTests: XCTestCase {
    func test_errorViewController_whenHasRetryAction_showsRetryButtonAndNoClose() {
        let environment = Environment()
        let sut = environment.makeSUT(viewModel: environment.retryViewModel)
        environment.contentSizes.forEach {
            assertSnapshot(
                of: sut.view,
                size: environment.size,
                interfaceStyle: .both,
                preferredContentSizeCategory: $0
            )
        }
    }

    func test_errorViewController_whenDoesntHaveRetryAction_showsCloseButtonAndNoRetry() {
        let environment = Environment()
        let sut = environment.makeSUT(viewModel: environment.closeViewModel)
        environment.contentSizes.forEach {
            assertSnapshot(
                of: sut.view,
                size: environment.size,
                interfaceStyle: .both,
                preferredContentSizeCategory: $0
            )
        }
    }
}

private final class Environment {
    let contentSizes: [UIContentSizeCategory] = [.medium, .accessibilityMedium, .accessibilityExtraLarge]
    let size = UIScreen.main.bounds.size
    let message = "Something went wrong"
    lazy var retryViewModel = ErrorViewModel(errorMessage: message, retryAction: {})
    lazy var closeViewModel = ErrorViewModel(errorMessage: message, retryAction: nil)

    func makeSUT(viewModel: ErrorViewModel) -> UIViewController {
        ErrorViewController(viewModel: viewModel)
    }
}
