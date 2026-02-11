import UIKit

public protocol MovieDBUIAssetsProtocol {
    var popularTabIcon: UIImage? { get }
    var popularTabSelectedIcon: UIImage? { get }
    var topRatedTabIcon: UIImage? { get }
    var topRatedTabSelectedIcon: UIImage? { get }
    var watchlistTabIcon: UIImage? { get }
    var watchlistTabSelectedIcon: UIImage? { get }
    var watchlistEmptyIcon: UIImage? { get }
    var heartIcon: UIImage? { get }
    var heartFilledIcon: UIImage? { get }
}

public struct MovieDBUIAssets: MovieDBUIAssetsProtocol {
    public let popularTabIcon: UIImage?
    public let popularTabSelectedIcon: UIImage?
    public let topRatedTabIcon: UIImage?
    public let topRatedTabSelectedIcon: UIImage?
    public let watchlistTabIcon: UIImage?
    public let watchlistTabSelectedIcon: UIImage?
    public let watchlistEmptyIcon: UIImage?
    public let heartIcon: UIImage?
    public let heartFilledIcon: UIImage?

    public init(
        popularTabIcon: UIImage?,
        popularTabSelectedIcon: UIImage?,
        topRatedTabIcon: UIImage?,
        topRatedTabSelectedIcon: UIImage?,
        watchlistTabIcon: UIImage?,
        watchlistTabSelectedIcon: UIImage?,
        watchlistEmptyIcon: UIImage?,
        heartIcon: UIImage?,
        heartFilledIcon: UIImage?
    ) {
        self.popularTabIcon = popularTabIcon
        self.popularTabSelectedIcon = popularTabSelectedIcon
        self.topRatedTabIcon = topRatedTabIcon
        self.topRatedTabSelectedIcon = topRatedTabSelectedIcon
        self.watchlistTabIcon = watchlistTabIcon
        self.watchlistTabSelectedIcon = watchlistTabSelectedIcon
        self.watchlistEmptyIcon = watchlistEmptyIcon
        self.heartIcon = heartIcon
        self.heartFilledIcon = heartFilledIcon
    }

    public static var system: MovieDBUIAssets {
        MovieDBUIAssets(
            popularTabIcon: UIImage(systemName: "film"),
            popularTabSelectedIcon: UIImage(systemName: "film.fill"),
            topRatedTabIcon: UIImage(systemName: "star"),
            topRatedTabSelectedIcon: UIImage(systemName: "star.fill"),
            watchlistTabIcon: UIImage(systemName: "heart"),
            watchlistTabSelectedIcon: UIImage(systemName: "heart.fill"),
            watchlistEmptyIcon: UIImage(systemName: "heart.slash"),
            heartIcon: UIImage(systemName: "heart"),
            heartFilledIcon: UIImage(systemName: "heart.fill")
        )
    }
}
