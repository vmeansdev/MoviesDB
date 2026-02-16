import MovieDBData
import MovieDBUI
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class WatchlistViewModel {
    private(set) var state = WatchlistViewModelState()

    private let watchlistStore: WatchlistStoreProtocol
    private let uiAssets: MovieDBUIAssetsProtocol
    private let mapper: MovieCatalogViewModelMapper
    private let prefetchCommandGate: any PrefetchCommandGating

    @ObservationIgnored private var observationTask: Task<Void, Never>?

    init(
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        prefetchCommandGate: any PrefetchCommandGating
    ) {
        self.watchlistStore = watchlistStore
        self.uiAssets = uiAssets
        self.mapper = MovieCatalogViewModelMapper(uiAssets: uiAssets)
        self.prefetchCommandGate = prefetchCommandGate
    }

    var emptyStateIcon: UIImage? { uiAssets.watchlistEmptyIcon }

    func movie(at index: Int) -> Movie? {
        state.movies[safe: index]
    }

    func isInWatchlist(id: Int) -> Bool {
        state.movies.contains { $0.id == id }
    }

    func toggle(movie: Movie) {
        Task {
            await watchlistStore.toggle(movie: movie)
        }
    }

    func startObserveWatchlist() {
        prefetchCommandGate.markVisible()
        observationTask?.cancel()
        observationTask = Task { @MainActor in
            let stream = await watchlistStore.itemsStream()
            for await updatedItems in stream {
                guard updatedItems != state.movies else { continue }
                let loaded = LoadedMovieList(
                    movies: updatedItems,
                    watchlistIds: Set(updatedItems.map(\.id))
                )
                state.movies = updatedItems
                state.itemViewModels = mapper.makeMovies(from: loaded)
                state.phase = updatedItems.isEmpty ? .empty : .loaded
                reportItemsCount()
            }
        }
    }

    func stopObserveWatchlist() {
        observationTask?.cancel()
        observationTask = nil
        prefetchCommandGate.markHiddenAndStop()
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int) {
        prefetchCommandGate.itemVisibilityChanged(
            index: index,
            isVisible: isVisible,
            columns: columns,
            posterURLs: state.itemViewModels.map(\.posterURL)
        )
    }

    func updateVisibleColumns(_ columns: Int) {
        guard columns > 0 else { return }
        state.visibleColumns = columns
        reportItemsCount()
    }

    private func reportItemsCount() {
        prefetchCommandGate.itemCountChanged(
            columns: state.visibleColumns,
            posterURLs: state.itemViewModels.map(\.posterURL)
        )
    }

}

enum WatchlistViewPhase {
    case empty
    case loaded
}

struct WatchlistViewModelState {
    var phase: WatchlistViewPhase
    var movies: [Movie]
    var itemViewModels: [MovieCollectionViewModel]
    var visibleColumns: Int

    init(
        phase: WatchlistViewPhase = .empty,
        movies: [Movie] = [],
        itemViewModels: [MovieCollectionViewModel] = [],
        visibleColumns: Int = 1
    ) {
        self.phase = phase
        self.movies = movies
        self.itemViewModels = itemViewModels
        self.visibleColumns = visibleColumns
    }
}

private struct LoadedMovieList: MovieCatalogLoadedState {
    let movies: [Movie]
    let watchlistIds: Set<Int>
}
