import Foundation

extension String {
    static let localizable = Localizable.instance
    static let empty = ""
}

extension Localizable {
    var popularCountTitle: String { string(forKey: "popular_count_title") }
    var topRatedCountTitle: String { string(forKey: "top_rated_count_title") }
    var tabPopularTitle: String { string(forKey: "tabitem_popular_title") }
    var tabTopRatedTitle: String { string(forKey: "tabitem_toprated_title") }
    var tabWatchlistTitle: String { string(forKey: "tabitem_watchlist_title") }
    var watchlistEmptyTitle: String { string(forKey: "watchlist_empty_title") }
    var watchlistEmptySubtitle: String { string(forKey: "watchlist_empty_subtitle") }
    var watchlistAccessibilityAdd: String { string(forKey: "watchlist_accessibility_add") }
    var watchlistAccessibilityRemove: String { string(forKey: "watchlist_accessibility_remove") }
    var watchlistAccessibilityHint: String { string(forKey: "watchlist_accessibility_hint") }
    var watchlistAccessibilityValueIn: String { string(forKey: "watchlist_accessibility_value_in") }
    var watchlistAccessibilityValueOut: String { string(forKey: "watchlist_accessibility_value_out") }
    var watchlistPosterAccessibilityFormat: String { string(forKey: "watchlist_poster_accessibility_format") }
    var watchlistEmptyIconAccessibilityLabel: String { string(forKey: "watchlist_empty_icon_accessibility_label") }
    var movieDetailsOverviewTitle: String { string(forKey: "movie_details_overview_title") }
    var movieDetailsRatingLabel: String { string(forKey: "movie_details_rating_label") }
    var movieDetailsRatingValue: String { string(forKey: "movie_details_rating_value") }
    var movieDetailsVotesLabel: String { string(forKey: "movie_details_votes_label") }
    var movieDetailsVotesValue: String { string(forKey: "movie_details_votes_value") }
    var movieDetailsReleaseDateLabel: String { string(forKey: "movie_details_release_date_label") }
    var movieDetailsLanguageLabel: String { string(forKey: "movie_details_language_label") }
    var movieDetailsOriginalTitleLabel: String { string(forKey: "movie_details_original_title_label") }
    var movieDetailsSubtitleSeparator: String { string(forKey: "movie_details_subtitle_separator") }
    var movieDetailsRuntimeLabel: String { string(forKey: "movie_details_runtime_label") }
    var movieDetailsRuntimeValue: String { string(forKey: "movie_details_runtime_value") }
    var movieDetailsGenresLabel: String { string(forKey: "movie_details_genres_label") }
}

final class Localizable {
    private lazy var bundles: [Bundle] = {
        let current = Bundle(for: type(of: self))
        return current == Bundle.main ? [Bundle.main] : [Bundle.main, current]
    }()

    private let table = "Localizable"

    private init() { }
}

private extension Localizable {
    static let instance = Localizable()

    func string(forKey key: String) -> String {
        for bundle in bundles {
            let result = String(localized: .init(String.LocalizationValue(key), table: table, bundle: bundle))
            if result != key {
                return result
            }
        }
        return .empty
    }
}

private extension Bundle {
    func localizedString(forKey key: String, table: String) -> String? { nil }
}
