import Foundation
import Testing
@testable import MovieDBUI

@MainActor
struct PosterPrefetchControllerTests {
    @Test
    func test_itemVisibilityChanged_updatesPrefetchRange() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)
        let urls = (0..<30).map { URL(string: "https://example.com/\($0).jpg")! }

        sut.itemVisibilityChanged(
            index: 5,
            isVisible: true,
            columns: 2,
            itemCount: urls.count,
            posterURLAt: { urls[$0] }
        )

        let didPrefetch = await waitUntil(timeoutNanoseconds: 15_000_000_000) {
            prefetcher.lastPrefetchURLs != nil
        }

        #expect(didPrefetch)
        #expect(prefetcher.lastPrefetchURLs?.first == urls[1])
        #expect(prefetcher.lastPrefetchURLs?.last == urls[13])
        #expect(prefetcher.lastPrefetchURLs?.count == 13)
    }

    @Test
    func test_stop_clearsPrefetch() {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        sut.stop()

        #expect(prefetcher.stopCalls == 1)
    }
}

@MainActor
private func waitUntil(
    timeoutNanoseconds: UInt64,
    pollNanoseconds: UInt64 = 20_000_000,
    condition: @MainActor @escaping () -> Bool
) async -> Bool {
    let start = DispatchTime.now().uptimeNanoseconds
    while DispatchTime.now().uptimeNanoseconds - start < timeoutNanoseconds {
        if condition() {
            return true
        }
        try? await Task.sleep(nanoseconds: pollNanoseconds)
    }
    return condition()
}

@MainActor
private final class MockPosterImagePrefetcher: PosterImagePrefetching {
    private(set) var lastPrefetchURLs: [URL]?
    private(set) var stopCalls = 0

    func updatePrefetch(urls: [URL]) {
        lastPrefetchURLs = urls
    }

    func stop() {
        stopCalls += 1
    }
}
