import Testing
@testable import MoviesDB

@MainActor
struct RenderProviderTests {
    @Test
    func test_defaultInit_usesSharedPosterImagePrefetcher() {
        let first = RenderProvider()
        let second = RenderProvider()
        let lhs = first.posterImagePrefetcher as? PosterImagePrefetcher
        let rhs = second.posterImagePrefetcher as? PosterImagePrefetcher

        #expect(lhs != nil)
        #expect(rhs != nil)
        #expect(lhs === rhs)
    }
}
