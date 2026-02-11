import Foundation
import UIKit

public struct MovieCollectionViewModel: Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let posterURL: URL?
    public let watchlistIcon: UIImage?
    public let watchlistSelectedIcon: UIImage?
    public let watchlistTintColor: UIColor
    public let isInWatchlist: Bool

    public init(
        id: String,
        title: String,
        subtitle: String,
        posterURL: URL?,
        watchlistIcon: UIImage?,
        watchlistSelectedIcon: UIImage?,
        watchlistTintColor: UIColor,
        isInWatchlist: Bool
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.posterURL = posterURL
        self.watchlistIcon = watchlistIcon
        self.watchlistSelectedIcon = watchlistSelectedIcon
        self.watchlistTintColor = watchlistTintColor
        self.isInWatchlist = isInWatchlist
    }

    public static func == (lhs: MovieCollectionViewModel, rhs: MovieCollectionViewModel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
