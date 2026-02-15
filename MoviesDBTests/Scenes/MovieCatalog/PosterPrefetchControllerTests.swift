import Foundation
import Testing
@testable import MoviesDB

@MainActor
struct PosterPrefetchControllerTests {
    @Test
    func test_itemVisibilityChanged_prefetchesVisibleWindow() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        sut.itemVisibilityChanged(index: 5, isVisible: true, columns: 1, itemCount: 20) { index in
            URL(string: "https://example.com/\(index).jpg")
        }

        try? await Task.sleep(for: .milliseconds(180))
        let expected = (3...9).compactMap { URL(string: "https://example.com/\($0).jpg") }
        #expect(prefetcher.updateCalls.last == expected)
    }

    @Test
    func test_itemCountChanged_withoutVisibleIndices_doesNotPrefetch() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        sut.itemCountChanged(columns: 1, itemCount: 20) { index in
            URL(string: "https://example.com/\(index).jpg")
        }

        try? await Task.sleep(for: .milliseconds(180))
        #expect(prefetcher.updateCalls.isEmpty)
    }

    @Test
    func test_stop_resetsPrefetcher() {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        sut.stop()

        #expect(prefetcher.stopCallsCount == 1)
    }
}
