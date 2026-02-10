import Foundation

public struct MovieCollectionViewModel: Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let posterURL: URL?

    public init(id: String, title: String, subtitle: String, posterURL: URL?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.posterURL = posterURL
    }
}
