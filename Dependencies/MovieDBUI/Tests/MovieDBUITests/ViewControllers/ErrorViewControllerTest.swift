@testable import MovieDBUI
import Testing
import UIKit

@MainActor
struct ErrorViewControllerTests {
    @Test
    func test_errorViewController_whenHasRetryAction_showsRetryAndCloseButtons() {
        var didRetry = false
        let sut = ErrorViewController(viewModel: ErrorViewModel(errorMessage: "Something went wrong", retryAction: {
            didRetry = true
        }))

        sut.loadViewIfNeeded()

        let retryButton = expectButton(in: sut.view, title: MovieDBUILocalizable.string(.errorRetryTitle))
        let closeButton = expectButton(in: sut.view, title: MovieDBUILocalizable.string(.errorCloseTitle))

        #expect(retryButton.isHidden == false)
        #expect(closeButton.isHidden == false)

        _ = sut.perform(NSSelectorFromString("retryButtonTapped"))
        #expect(didRetry)
    }

    @Test
    func test_errorViewController_whenNoRetryAction_hidesRetryAndShowsClose() {
        let sut = ErrorViewController(viewModel: ErrorViewModel(errorMessage: "Something went wrong", retryAction: nil))

        sut.loadViewIfNeeded()

        let retryButton = expectButton(in: sut.view, title: MovieDBUILocalizable.string(.errorRetryTitle))
        let closeButton = expectButton(in: sut.view, title: MovieDBUILocalizable.string(.errorCloseTitle))

        #expect(retryButton.isHidden)
        #expect(closeButton.isHidden == false)
    }

    @Test
    func test_closeButtonTap_whenAttachedAsChild_detachesViewController() {
        let host = UIViewController()
        host.loadViewIfNeeded()

        let sut = ErrorViewController(viewModel: ErrorViewModel(errorMessage: "Something went wrong", retryAction: nil))
        host.attach(sut)
        sut.loadViewIfNeeded()

        _ = sut.perform(NSSelectorFromString("closeTapped"))

        #expect(sut.parent == nil)
    }
}

@MainActor
private func expectButton(in root: UIView, title: String) -> UIButton {
    guard let button = findButton(in: root, title: title) else {
        Issue.record("Button with title '\(title)' not found")
        return UIButton(type: .system)
    }
    return button
}

@MainActor
private func findButton(in view: UIView, title: String) -> UIButton? {
    if let button = view as? UIButton, button.title(for: .normal) == title {
        return button
    }
    for subview in view.subviews {
        if let found = findButton(in: subview, title: title) {
            return found
        }
    }
    return nil
}
