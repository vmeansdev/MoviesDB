import SwiftUI

@MainActor
struct MovieGridLayout {
    static let gridMinItemWidth: CGFloat = 200
    static let maxGridColumns = 6
    static let minGridColumns = 2

    static func shouldUseGridLayout(size: CGSize, horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        if horizontalSizeClass == .regular { return true }
        return estimatedGridColumns(for: size) >= minGridColumns
    }

    static func gridColumnsCount(size: CGSize) -> Int {
        let rawColumns = estimatedGridColumns(for: size)
        return min(maxGridColumns, max(minGridColumns, rawColumns))
    }

    static func gridColumns(count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 0), count: count)
    }

    private static func estimatedGridColumns(for size: CGSize) -> Int {
        let availableWidth = max(0, size.width)
        return Int(availableWidth / gridMinItemWidth)
    }
}
