import SwiftUI
import UIKit

@MainActor
struct MovieGridLayout {
    static let gridMinItemWidth: CGFloat = 200
    static let maxGridColumns = 6
    static let minGridColumns = 2

    static func shouldUseGridLayout(size: CGSize, horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        if horizontalSizeClass == .regular {
            return true
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            return size.width > size.height
        }
        return false
    }

    static func gridColumnsCount(size: CGSize) -> Int {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 3
        }
        let availableWidth = max(0, size.width)
        let rawColumns = Int(availableWidth / gridMinItemWidth)
        let clamped = min(maxGridColumns, max(minGridColumns, rawColumns))
        return clamped
    }

    static func gridColumns(count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 0), count: count)
    }
}
