import CoreGraphics

@MainActor
public protocol PosterRenderSizeProviding: Sendable {
    func size(for containerSize: CGSize, columns: Int, itemHeight: CGFloat, minimumColumns: Int) -> CGSize
}

@MainActor
public final class PosterRenderSizeProvider: PosterRenderSizeProviding, @unchecked Sendable {
    private var portraitSize: CGSize?
    private var landscapeSize: CGSize?

    public init() {}

    public func size(for containerSize: CGSize, columns: Int, itemHeight: CGFloat, minimumColumns: Int = 1) -> CGSize {
        let isLandscape = containerSize.width > containerSize.height
        if isLandscape, let landscapeSize {
            return landscapeSize
        }
        if !isLandscape, let portraitSize {
            return portraitSize
        }

        let safeColumns = max(columns, minimumColumns)
        let computed = CGSize(
            width: containerSize.width / CGFloat(safeColumns),
            height: itemHeight
        )
        if isLandscape {
            landscapeSize = computed
        } else {
            portraitSize = computed
        }
        return computed
    }
}
