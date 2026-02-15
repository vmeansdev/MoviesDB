import Foundation
import Testing
import MovieDBUI
import UIKit
@testable import MoviesDB

@MainActor
struct MovieCatalogViewControllerTests {
    @Test
    func test_viewDidLoad_shouldInvokeInteractor() async {
        let interactor = MockMovieCatalogInteractor()
        let sut = MovieCatalogViewController(interactor: interactor, kind: .popular)

        _ = sut.view

        await waitUntil { await interactor.viewDidLoadCalls == 1 }

        #expect(await interactor.viewDidLoadCalls == 1)
    }

    @Test
    func test_viewWillDisappear_shouldInvokeInteractor() async {
        let interactor = MockMovieCatalogInteractor()
        let sut = MovieCatalogViewController(interactor: interactor, kind: .topRated)

        _ = sut.view
        sut.beginAppearanceTransition(false, animated: false)
        sut.endAppearanceTransition()

        await waitUntil { await interactor.viewWillUnloadCalls == 1 }

        #expect(await interactor.viewWillUnloadCalls == 1)
    }

    @Test
    func test_displayTitle_shouldSetTitle() {
        let interactor = MockMovieCatalogInteractor()
        let sut = MovieCatalogViewController(interactor: interactor, kind: .popular)

        sut.loadViewIfNeeded()
        let title = "Popular 20"

        sut.displayTitle(title)

        #expect(sut.title == title)
    }
}
