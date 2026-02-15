import Foundation
@testable import MoviesDB

@MainActor
final class MockPosterPrefetchController: PosterPrefetchControlling {
    struct VisibilityCall {
        let index: Int
        let isVisible: Bool
        let columns: Int
        let itemCount: Int
        let posterURLAt: (Int) -> URL?
    }

    struct ItemCountCall {
        let columns: Int
        let itemCount: Int
        let posterURLAt: (Int) -> URL?
    }

    private(set) var visibilityCalls: [VisibilityCall] = []
    private(set) var itemCountCalls: [ItemCountCall] = []
    private(set) var stopCallsCount = 0

    func itemVisibilityChanged(
        index: Int,
        isVisible: Bool,
        columns: Int,
        itemCount: Int,
        posterURLAt: @escaping (Int) -> URL?
    ) {
        visibilityCalls.append(
            VisibilityCall(
                index: index,
                isVisible: isVisible,
                columns: columns,
                itemCount: itemCount,
                posterURLAt: posterURLAt
            )
        )
    }

    func itemCountChanged(columns: Int, itemCount: Int, posterURLAt: @escaping (Int) -> URL?) {
        itemCountCalls.append(
            ItemCountCall(
                columns: columns,
                itemCount: itemCount,
                posterURLAt: posterURLAt
            )
        )
    }

    func stop() {
        stopCallsCount += 1
    }
}
