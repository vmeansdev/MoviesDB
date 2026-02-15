import CoreGraphics
@testable import MoviesDB

@MainActor
final class MockPosterRenderSizeProvider: PosterRenderSizeProviding {
    var sizeResult: CGSize = .zero
    private(set) var capturedContainerSize: CGSize?
    private(set) var capturedColumns: Int?
    private(set) var capturedItemHeight: CGFloat?
    private(set) var capturedMinimumColumns: Int?

    func size(for containerSize: CGSize, columns: Int, itemHeight: CGFloat, minimumColumns: Int) -> CGSize {
        capturedContainerSize = containerSize
        capturedColumns = columns
        capturedItemHeight = itemHeight
        capturedMinimumColumns = minimumColumns
        return sizeResult
    }
}
