import CoreGraphics
import Testing
@testable import MovieDBUI

@MainActor
struct PosterRenderSizeProviderTests {
    @Test
    func test_size_cachesPortraitAndLandscapeSeparately() {
        let sut = PosterRenderSizeProvider()

        let portraitInitial = sut.size(
            for: CGSize(width: 300, height: 700),
            columns: 1,
            itemHeight: 250,
            minimumColumns: 1
        )
        let portraitSecond = sut.size(
            for: CGSize(width: 400, height: 700),
            columns: 2,
            itemHeight: 250,
            minimumColumns: 1
        )

        #expect(portraitInitial == CGSize(width: 300, height: 250))
        #expect(portraitSecond == portraitInitial)

        let landscapeInitial = sut.size(
            for: CGSize(width: 700, height: 300),
            columns: 3,
            itemHeight: 250,
            minimumColumns: 1
        )
        let landscapeSecond = sut.size(
            for: CGSize(width: 900, height: 300),
            columns: 2,
            itemHeight: 250,
            minimumColumns: 1
        )

        #expect(abs(landscapeInitial.width - (700.0 / 3.0)) < 0.001)
        #expect(landscapeInitial.height == 250)
        #expect(landscapeSecond == landscapeInitial)
    }
}
