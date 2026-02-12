import Foundation

enum MovieDBUILocalizable {
    enum Key: String {
        case errorRetryTitle = "error_retry_title"
        case errorCloseTitle = "error_close_title"
        case loadingAccessibilityLabel = "loading_accessibility_label"
        case watchlistAccessibilityAdd = "watchlist_accessibility_add"
        case watchlistAccessibilityRemove = "watchlist_accessibility_remove"
        case watchlistAccessibilityHint = "watchlist_accessibility_hint"
        case watchlistAccessibilityValueIn = "watchlist_accessibility_value_in"
        case watchlistAccessibilityValueOut = "watchlist_accessibility_value_out"
        case posterAccessibilityFormat = "poster_accessibility_format"
        case backdropAccessibilityFormat = "backdrop_accessibility_format"
        case metadataAccessibilityFormat = "metadata_accessibility_format"
    }

    static func string(_ key: Key) -> String {
        String(localized: .init(key.rawValue), table: "Localizable", bundle: .module)
    }

    static func format(_ key: Key, _ arguments: CVarArg...) -> String {
        String(format: string(key), locale: Locale.current, arguments: arguments)
    }
}
