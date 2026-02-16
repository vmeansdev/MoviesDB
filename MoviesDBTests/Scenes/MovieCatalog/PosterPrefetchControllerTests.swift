import Foundation
import Testing
@testable import MoviesDB

@MainActor
struct PosterPrefetchControllerTests {
    @Test
    func test_itemVisibilityChanged_prefetchesVisibleWindow() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        await sut.itemVisibilityChanged(index: 5, isVisible: true, columns: 1, itemCount: 20) { index in
            URL(string: "https://example.com/\(index).jpg")
        }

        try? await Task.sleep(for: .milliseconds(180))
        let expected = (3...9).compactMap { URL(string: "https://example.com/\($0).jpg") }
        #expect(await prefetcher.updateCallsSnapshot().last == expected)
    }

    @Test
    func test_itemCountChanged_withoutVisibleIndices_doesNotPrefetch() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        await sut.itemCountChanged(columns: 1, itemCount: 20) { index in
            URL(string: "https://example.com/\(index).jpg")
        }

        try? await Task.sleep(for: .milliseconds(180))
        #expect(await prefetcher.updateCallsSnapshot().isEmpty)
    }

    @Test
    func test_stop_resetsPrefetcher() async {
        let prefetcher = MockPosterImagePrefetcher()
        let sut = PosterPrefetchController(posterImagePrefetcher: prefetcher)

        await sut.stop()

        #expect(await prefetcher.stopCallsCountValue() == 1)
    }
}
