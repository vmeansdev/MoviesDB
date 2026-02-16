import Foundation
import Testing
@testable import MoviesDB

@MainActor
struct PosterPrefetchControllerTests {
    @Test
    func test_itemVisibilityChanged_prefetchesVisibleWindow() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(
            posterImagePrefetcher: prefetcher,
            prefetchDebounceNanoseconds: 0
        )

        await sut.itemVisibilityChanged(index: 5, isVisible: true, columns: 1, itemCount: 20) { index in
            URL(string: "https://example.com/\(index).jpg")
        }

        let expected = (3...9).compactMap { URL(string: "https://example.com/\($0).jpg") }
        let didPrefetch = await waitUntil {
            await prefetcher.updateCallsSnapshot().last == expected
        }
        #expect(didPrefetch)
    }

    @Test
    func test_itemCountChanged_withoutVisibleIndices_doesNotPrefetch() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(
            posterImagePrefetcher: prefetcher,
            prefetchDebounceNanoseconds: 0
        )

        await sut.itemCountChanged(columns: 1, itemCount: 20) { index in
            URL(string: "https://example.com/\(index).jpg")
        }

        let stayedEmpty = await waitUntil(timeout: .milliseconds(120)) {
            await prefetcher.updateCallsSnapshot().isEmpty
        }
        #expect(stayedEmpty)
    }

    @Test
    func test_stop_resetsPrefetcher() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        await sut.stop()

        #expect(await prefetcher.stopCallsCountValue() == 1)
    }
}
