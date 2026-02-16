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
    private let posterPrefetchController: any PosterPrefetchControlling

    @ObservationIgnored private var observationTask: Task<Void, Never>?

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
        Task { [posterPrefetchController] in
            await posterPrefetchController.stop()
        }
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int) {
        let posterURLs = state.itemViewModels.map(\.posterURL)
        let itemCount = posterURLs.count
        Task { [posterPrefetchController] in
            await posterPrefetchController.itemVisibilityChanged(
                index: index,
                isVisible: isVisible,
                columns: columns,
                itemCount: itemCount,
                posterURLAt: { index in
                    guard posterURLs.indices.contains(index) else { return nil }
                    return posterURLs[index]
                }
            )
        }
    }

    func updateVisibleColumns(_ columns: Int) {
        guard columns > 0 else { return }
        state.visibleColumns = columns
        reportItemsCount()
    }

    private func reportItemsCount() {
        let posterURLs = state.itemViewModels.map(\.posterURL)
        let itemCount = posterURLs.count
        let visibleColumns = state.visibleColumns
        Task { [posterPrefetchController] in
            await posterPrefetchController.itemCountChanged(
                columns: visibleColumns,
                itemCount: itemCount,
                posterURLAt: { index in
                    guard posterURLs.indices.contains(index) else { return nil }
                    return posterURLs[index]
                }
            )
        }
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
