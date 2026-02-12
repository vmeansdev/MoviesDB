import Foundation

public struct MovieDetailsContent: Equatable, Sendable {
    public let title: String
    public let subtitle: String?
    public let overviewTitle: String
    public let overview: String
    public let metadata: [MovieDetailsMetadataItem]
    public let posterURL: URL?
    public let backdropURL: URL?

    public init(
        title: String,
        subtitle: String?,
        overviewTitle: String,
        overview: String,
        metadata: [MovieDetailsMetadataItem],
        posterURL: URL?,
        backdropURL: URL?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.overviewTitle = overviewTitle
        self.overview = overview
        self.metadata = metadata
        self.posterURL = posterURL
        self.backdropURL = backdropURL
    }
}
