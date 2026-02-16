import SwiftUI
import Testing
@testable import MoviesDB

@MainActor
struct MovieGridLayoutTests {
    @Test
    func test_shouldUseGridLayout_regularSizeClass_usesGrid() {
        let useGrid = MovieGridLayout.shouldUseGridLayout(
            size: CGSize(width: 320, height: 640),
            horizontalSizeClass: .regular
        )

        #expect(useGrid)
    }

    @Test
    func test_shouldUseGridLayout_compactAndNarrow_usesList() {
        let useGrid = MovieGridLayout.shouldUseGridLayout(
            size: CGSize(width: 360, height: 800),
            horizontalSizeClass: .compact
        )

        #expect(useGrid == false)
    }

    @Test
    func test_shouldUseGridLayout_compactAndWide_usesGrid() {
        let useGrid = MovieGridLayout.shouldUseGridLayout(
            size: CGSize(width: 520, height: 800),
            horizontalSizeClass: .compact
        )

        #expect(useGrid)
    }

    @Test
    func test_gridColumnsCount_clampsWithinBounds() {
        #expect(MovieGridLayout.gridColumnsCount(size: CGSize(width: 100, height: 600)) == MovieGridLayout.minGridColumns)
        #expect(MovieGridLayout.gridColumnsCount(size: CGSize(width: 1800, height: 600)) == MovieGridLayout.maxGridColumns)
    }
}
