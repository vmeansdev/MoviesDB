import MovieDBData
import MovieDBUI
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class WatchlistViewModel {
    private(set) var items: [Movie] = []

    private let watchlistStore: WatchlistStoreProtocol
    private let uiAssets: MovieDBUIAssetsProtocol
    private let onSelect: (Movie) -> Void
    private var observationTask: Task<Void, Never>?

    init(
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        onSelect: @escaping (Movie) -> Void
    ) {
        self.watchlistStore = watchlistStore
        self.uiAssets = uiAssets
        self.onSelect = onSelect
    }

    var emptyStateIcon: UIImage? { uiAssets.watchlistEmptyIcon }
    var heartIcon: UIImage? { uiAssets.heartIcon }
    var heartFilledIcon: UIImage? { uiAssets.heartFilledIcon }
    var watchlistTintColor: UIColor { .systemPink }

    func select(movie: Movie) {
        onSelect(movie)
    }

    func toggle(movie: Movie) {
        Task {
            await watchlistStore.toggle(movie: movie)
        }
    }

    func startObserveWatchlist() {
        observationTask?.cancel()
        observationTask = Task { @MainActor in
            let stream = await watchlistStore.itemsStream()
            for await updatedItems in stream {
                withAnimation(.easeInOut(duration: 0.2)) {
                    items = updatedItems
                }
            }
        }
    }

    func stopObserveWatchlist() {
        observationTask?.cancel()
        observationTask = nil
    }
}
