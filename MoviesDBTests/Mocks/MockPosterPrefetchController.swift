import Foundation
@testable import MoviesDB

actor MockPosterPrefetchController: PosterPrefetchControlling {
    struct VisibilityCall {
        let index: Int
        let isVisible: Bool
        let columns: Int
        let itemCount: Int
        let posterURLAt: @Sendable (Int) -> URL?
    }

    struct ItemCountCall {
        let columns: Int
        let itemCount: Int
        let posterURLAt: @Sendable (Int) -> URL?
    }

    private var visibilityCalls: [VisibilityCall] = []
    private var itemCountCalls: [ItemCountCall] = []
    private var stopCallsCount = 0

    func itemVisibilityChanged(
        index: Int,
        isVisible: Bool,
        columns: Int,
        itemCount: Int,
        posterURLAt: @Sendable @escaping (Int) -> URL?
    ) async {
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

    func itemCountChanged(columns: Int, itemCount: Int, posterURLAt: @Sendable @escaping (Int) -> URL?) async {
        itemCountCalls.append(
            ItemCountCall(
                columns: columns,
                itemCount: itemCount,
                posterURLAt: posterURLAt
            )
        )
    }

    func stop() async {
        stopCallsCount += 1
    }

    func visibilityCallsSnapshot() -> [VisibilityCall] {
        visibilityCalls
    }

    func itemCountCallsSnapshot() -> [ItemCountCall] {
        itemCountCalls
    }

    func stopCallsCountValue() -> Int {
        stopCallsCount
    }
}
