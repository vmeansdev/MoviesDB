import MovieDBUI
import Testing
import UIKit
@testable import MoviesDB

struct PopularViewControllerTests {
    @Test
    @MainActor
    func test_viewDidLoad_shouldInvokeInteractor() async {
        let interactor = MockPopularInteractor()
        let sut = PopularViewController(interactor: interactor)

        sut.loadViewIfNeeded()
        let didCall = await waitUntil { await interactor.viewDidLoadCalls == 1 }
        #expect(didCall)

        let calls = await interactor.viewDidLoadCalls
        #expect(calls == 1)
    }

    @Test
    @MainActor
    func test_viewWillDisappear_shouldInvokeInteractor() async {
        let interactor = MockPopularInteractor()
        let sut = PopularViewController(interactor: interactor)

        sut.loadViewIfNeeded()
        sut.viewWillDisappear(false)
        let didCall = await waitUntil { await interactor.viewWillUnloadCalls == 1 }
        #expect(didCall)

        let calls = await interactor.viewWillUnloadCalls
        #expect(calls == 1)
    }

    @Test
    @MainActor
    func test_displayTitle_shouldSetTitle() async {
        let interactor = MockPopularInteractor()
        let sut = PopularViewController(interactor: interactor)

        sut.loadViewIfNeeded()
        let expectedTitle = String(format: String.localizable.popularCountTitle, 10)
        sut.displayTitle(expectedTitle)

        #expect(sut.title == expectedTitle)
    }
}
