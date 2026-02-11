@testable import MoviesDB

@MainActor
final class MockTopRatedPresenter: TopRatedPresenterProtocol {
    private(set) var states: [TopRatedState] = []

    func present(state: TopRatedState) async {
        states.append(state)
    }
}
