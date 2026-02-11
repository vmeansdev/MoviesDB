import UIKit

public protocol MovieDBUIAssetsProtocol {
    var popularTabIcon: UIImage? { get }
    var popularTabSelectedIcon: UIImage? { get }
    var topRatedTabIcon: UIImage? { get }
    var topRatedTabSelectedIcon: UIImage? { get }
}

public struct MovieDBUIAssets: MovieDBUIAssetsProtocol {
    public let popularTabIcon: UIImage?
    public let popularTabSelectedIcon: UIImage?
    public let topRatedTabIcon: UIImage?
    public let topRatedTabSelectedIcon: UIImage?

    public init(
        popularTabIcon: UIImage?,
        popularTabSelectedIcon: UIImage?,
        topRatedTabIcon: UIImage?,
        topRatedTabSelectedIcon: UIImage?
    ) {
        self.popularTabIcon = popularTabIcon
        self.popularTabSelectedIcon = popularTabSelectedIcon
        self.topRatedTabIcon = topRatedTabIcon
        self.topRatedTabSelectedIcon = topRatedTabSelectedIcon
    }

    public static var system: MovieDBUIAssets {
        MovieDBUIAssets(
            popularTabIcon: UIImage(systemName: "film"),
            popularTabSelectedIcon: UIImage(systemName: "film.fill"),
            topRatedTabIcon: UIImage(systemName: "star"),
            topRatedTabSelectedIcon: UIImage(systemName: "star.fill")
        )
    }
}
