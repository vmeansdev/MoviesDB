import Foundation
import Testing
@testable import MoviesDB

@MainActor
struct PrefetchCommandGateTests {
    @Test
    func test_itemCountChanged_whenHidden_doesNotForward() async {
        let controller = MockPosterPrefetchController()
        let sut = PrefetchCommandGate(controller: controller)

        sut.itemCountChanged(columns: 2, posterURLs: [URL(string: "https://example.com/1.jpg")])

        let stayedEmpty = await waitUntil(timeout: .milliseconds(120)) {
            await controller.itemCountCallsSnapshot().isEmpty
        }
        #expect(stayedEmpty)
    }

    @Test
    func test_itemVisibilityChanged_whenVisible_forwards() async {
        let controller = MockPosterPrefetchController()
        let sut = PrefetchCommandGate(controller: controller)

        sut.markVisible()
        sut.itemVisibilityChanged(
            index: 3,
            isVisible: true,
            columns: 2,
            posterURLs: [URL(string: "https://example.com/1.jpg")]
        )

        let didForward = await waitUntil {
            await controller.visibilityCallsSnapshot().count == 1
        }
        #expect(didForward)
    }

    @Test
    func test_markHiddenAndStop_cancelsPendingForwardAndStops() async {
        let controller = MockPosterPrefetchController()
        let sut = PrefetchCommandGate(controller: controller)

        sut.markVisible()
        sut.itemCountChanged(columns: 1, posterURLs: [URL(string: "https://example.com/1.jpg")])
        sut.markHiddenAndStop()

        let didStop = await waitUntil {
            await controller.stopCallsCountValue() == 1
        }
        #expect(didStop)

        let noForwardAfterStop = await waitUntil(timeout: .milliseconds(120)) {
            await controller.itemCountCallsSnapshot().isEmpty
        }
        #expect(noForwardAfterStop)
    }
}
