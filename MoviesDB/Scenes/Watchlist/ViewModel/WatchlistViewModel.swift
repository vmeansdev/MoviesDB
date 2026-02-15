import MovieDBData
import MovieDBUI
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class WatchlistViewModel {
    private(set) var items: [Movie] = []
    private(set) var itemViewModels: [MovieCollectionViewModel] = []

    private let watchlistStore: WatchlistStoreProtocol
    private let uiAssets: MovieDBUIAssetsProtocol
    private let mapper: MovieCatalogViewModelMapper
    private let posterPrefetchController: any PosterPrefetchControlling
    private var observationTask: Task<Void, Never>?

    init(
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        posterPrefetchController: any PosterPrefetchControlling
    ) {
        self.watchlistStore = watchlistStore
        self.uiAssets = uiAssets
        self.mapper = MovieCatalogViewModelMapper(uiAssets: uiAssets)
        self.posterPrefetchController = posterPrefetchController
    }

    var emptyStateIcon: UIImage? { uiAssets.watchlistEmptyIcon }

    func movie(at index: Int) -> Movie? {
        items[safe: index]
    }

    func isInWatchlist(id: Int) -> Bool {
        items.contains { $0.id == id }
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
                guard updatedItems != items else { continue }
                items = updatedItems
                let loaded = LoadedMovieList(
                    movies: updatedItems,
                    watchlistIds: Set(updatedItems.map(\.id))
                )
                itemViewModels = mapper.makeMovies(from: loaded)
            }
        }
    }

    func stopObserveWatchlist() {
        observationTask?.cancel()
        observationTask = nil
        posterPrefetchController.stop()
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int) {
        posterPrefetchController.itemVisibilityChanged(
            index: index,
            isVisible: isVisible,
            columns: columns,
            itemCount: itemViewModels.count,
            posterURLAt: { [weak self] index in
                self?.itemViewModels[safe: index]?.posterURL
            }
        )
    }

    func itemsCountChanged(columns: Int) {
        posterPrefetchController.itemCountChanged(
            columns: columns,
            itemCount: itemViewModels.count,
            posterURLAt: { [weak self] index in
                self?.itemViewModels[safe: index]?.posterURL
            }
        )
    }
}

private struct LoadedMovieList: MovieCatalogLoadedState {
    let movies: [Movie]
    let watchlistIds: Set<Int>
}
