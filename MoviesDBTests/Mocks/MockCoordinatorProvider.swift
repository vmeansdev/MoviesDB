@testable import MoviesDB

@MainActor
final class MockCoordinator: Coordinator {
    private(set) var startCallCount = 0

    func start() {
        startCallCount += 1
    }
}

@MainActor
final class MockCoordinatorProvider: CoordinatorProviderProtocol {
    let root = MockCoordinator()
    let popular = MockCoordinator()
    let topRated = MockCoordinator()

    func rootCoordinator() -> Coordinator {
        root
    }

    func popularCoordinator() -> Coordinator {
        popular
    }

    func topRatedCoordinator() -> Coordinator {
        topRated
    }

    func allCoordinators() -> [Coordinator] {
        [root, popular, topRated]
    }
}
