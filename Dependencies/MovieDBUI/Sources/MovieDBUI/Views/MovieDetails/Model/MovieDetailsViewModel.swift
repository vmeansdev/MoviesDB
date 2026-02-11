import Foundation

@MainActor
public final class MovieDetailsViewModel: ObservableObject {
    @Published public private(set) var content: MovieDetailsContent
    private let loadDetails: (@Sendable () async throws -> MovieDetailsContent)?
    private var hasLoadedDetails = false

    public init(
        content: MovieDetailsContent,
        loadDetails: (@Sendable () async throws -> MovieDetailsContent)? = nil
    ) {
        self.content = content
        self.loadDetails = loadDetails
    }

    public func update(content: MovieDetailsContent) {
        self.content = content
    }

    public func loadDetailsIfNeeded() async {
        guard !hasLoadedDetails else { return }
        hasLoadedDetails = true
        guard let loadDetails else { return }
        if let updated = try? await loadDetails() {
            content = updated
        }
    }
}
