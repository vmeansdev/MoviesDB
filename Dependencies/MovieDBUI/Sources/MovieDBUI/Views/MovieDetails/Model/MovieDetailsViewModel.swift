import Foundation
import Observation
import UIKit

@MainActor
@Observable
public final class MovieDetailsViewModel {
    public private(set) var content: MovieDetailsContent
    public private(set) var isInWatchlist: Bool
    public let watchlistIcon: UIImage?
    public let watchlistFilledIcon: UIImage?
    private let watchlistActiveTintColor: UIColor
    private let watchlistInactiveTintColor: UIColor
    private let loadDetails: (@Sendable () async throws -> MovieDetailsContent)?
    private let watchlistUpdates: (@Sendable () async -> AsyncStream<Bool>)?
    private let toggleWatchlistAction: (@Sendable () async -> Void)?
    private var hasLoadedDetails = false
    private var watchlistTask: Task<Void, Never>?

    public init(
        content: MovieDetailsContent,
        isInWatchlist: Bool = false,
        watchlistIcon: UIImage? = nil,
        watchlistFilledIcon: UIImage? = nil,
        watchlistActiveTintColor: UIColor = .systemPink,
        watchlistInactiveTintColor: UIColor = .white,
        watchlistUpdates: (@Sendable () async -> AsyncStream<Bool>)? = nil,
        toggleWatchlistAction: (@Sendable () async -> Void)? = nil,
        loadDetails: (@Sendable () async throws -> MovieDetailsContent)? = nil
    ) {
        self.content = content
        self.isInWatchlist = isInWatchlist
        self.watchlistIcon = watchlistIcon
        self.watchlistFilledIcon = watchlistFilledIcon
        self.watchlistActiveTintColor = watchlistActiveTintColor
        self.watchlistInactiveTintColor = watchlistInactiveTintColor
        self.loadDetails = loadDetails
        self.watchlistUpdates = watchlistUpdates
        self.toggleWatchlistAction = toggleWatchlistAction
        observeWatchlistIfNeeded()
    }

    @MainActor deinit {
        watchlistTask?.cancel()
    }

    public func update(content: MovieDetailsContent) {
        self.content = content
    }

    public var watchlistTintColor: UIColor {
        isInWatchlist ? watchlistActiveTintColor : watchlistInactiveTintColor
    }

    public func toggleWatchlist() async {
        await toggleWatchlistAction?()
    }

    public func loadDetailsIfNeeded() async {
        guard !hasLoadedDetails else { return }
        hasLoadedDetails = true
        guard let loadDetails else { return }
        if let updated = try? await loadDetails() {
            content = updated
        }
    }

    private func observeWatchlistIfNeeded() {
        guard let watchlistUpdates else { return }
        watchlistTask?.cancel()
        watchlistTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let stream = await watchlistUpdates()
            for await value in stream {
                self.isInWatchlist = value
            }
        }
    }
}
