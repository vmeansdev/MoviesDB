import Testing
@testable import MoviesDB

@MainActor
struct RenderProviderTests {
    @Test
    func test_defaultInit_buildsPrefetchCommandGate() {
        let sut = RenderProvider()
        let gate = sut.makePrefetchCommandGate()

        #expect(gate is PrefetchCommandGate)
    }
}
