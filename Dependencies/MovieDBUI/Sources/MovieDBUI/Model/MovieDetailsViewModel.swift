import UIKit

public struct MovieDetailsViewModel: Hashable {
    public let imageURL: URL?
    public let placeholderImage: UIImage?
    public let title: String
    public let subtitle: String
    public let overview: String?

    public init(
        imageURL: URL?,
        placeholderImage: UIImage?,
        title: String,
        subtitle: String,
        overview: String?
    ) {
        self.imageURL = imageURL
        self.placeholderImage = placeholderImage
        self.title = title
        self.subtitle = subtitle
        self.overview = overview
    }
}
