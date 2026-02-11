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
