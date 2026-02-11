import UIKit
import Testing
@testable import MoviesDB

struct TopRatedViewControllerTests {
    @Test
    @MainActor
    func test_viewDidLoad_shouldInvokeInteractor() async {
        let interactor = MockTopRatedInteractor()
        let sut = TopRatedViewController(interactor: interactor)

        sut.loadViewIfNeeded()
        try? await Task.sleep(for: .milliseconds(10))

        let calls = await interactor.viewDidLoadCalls
        #expect(calls == 1)
    }

    @Test
    @MainActor
    func test_viewWillDisappear_shouldInvokeInteractor() async {
        let interactor = MockTopRatedInteractor()
        let sut = TopRatedViewController(interactor: interactor)

        sut.loadViewIfNeeded()
        sut.viewWillDisappear(false)
        try? await Task.sleep(for: .milliseconds(10))

        let calls = await interactor.viewWillUnloadCalls
        #expect(calls == 1)
    }

    @Test
    @MainActor
    func test_displayTitle_shouldSetTitle() async {
        let interactor = MockTopRatedInteractor()
        let sut = TopRatedViewController(interactor: interactor)

        sut.loadViewIfNeeded()
        let expectedTitle = String(format: String.localizable.topRatedCountTitle, 10)
        sut.displayTitle(expectedTitle)

        #expect(sut.title == expectedTitle)
    }
}
