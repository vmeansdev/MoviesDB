@testable import MoviesDB

@MainActor
final class MockPopularPresenter: PopularPresenterProtocol {
    private(set) var states: [PopularState] = []

    func present(state: PopularState) async {
        states.append(state)
    }
}
