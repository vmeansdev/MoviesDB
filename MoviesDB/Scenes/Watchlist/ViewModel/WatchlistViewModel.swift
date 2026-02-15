import Foundation
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
    private let posterURLProvider: any PosterURLProviding
    private let onSelect: (Movie) -> Void
    private var observationTask: Task<Void, Never>?

    init(
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        posterURLProvider: any PosterURLProviding,
        onSelect: @escaping (Movie) -> Void
    ) {
        self.watchlistStore = watchlistStore
        self.uiAssets = uiAssets
        self.posterURLProvider = posterURLProvider
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

    func posterURL(for movie: Movie) -> URL? {
        posterURLProvider.makePosterOrBackdropURL(posterPath: movie.posterPath, backdropPath: movie.backdropPath)
    }

    func startObserveWatchlist() {
        observationTask?.cancel()
        observationTask = Task { @MainActor in
            let stream = await watchlistStore.itemsStream()
            for await updatedItems in stream {
                withAnimation(Constants.itemsUpdateAnimation) {
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

private enum Constants {
    static let itemsUpdateAnimation: Animation = .easeInOut(duration: 0.2)
}
