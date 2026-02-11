import Foundation

public final class MovieDetailsViewModel: ObservableObject {
    @Published public private(set) var content: MovieDetailsContent

    public init(content: MovieDetailsContent) {
        self.content = content
    }

    public func update(content: MovieDetailsContent) {
        self.content = content
    }
}
