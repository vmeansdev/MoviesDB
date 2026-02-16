import MovieDBData
import MovieDBUI
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class WatchlistViewModel {
    private(set) var state: WatchlistViewModelState = .empty

    private let watchlistStore: WatchlistStoreProtocol
    private let uiAssets: MovieDBUIAssetsProtocol
    private let mapper: MovieCatalogViewModelMapper
    private let posterPrefetchController: any PosterPrefetchControlling
    @ObservationIgnored private var observationTask: Task<Void, Never>?
    @ObservationIgnored private var visibleColumns = 1
    @ObservationIgnored private var lastReportedItemsCount: Int?

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
                let updatedItemViewModels = mapper.makeMovies(from: loaded)
                if updatedItems.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(movies: updatedItems, itemViewModels: updatedItemViewModels)
                }
                reportItemsCountIfNeeded()
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
        let didChange = visibleColumns != columns
        visibleColumns = columns
        reportItemsCountIfNeeded(force: didChange)
    }

    private func reportItemsCountIfNeeded(force: Bool = false) {
        let posterURLs = state.itemViewModels.map(\.posterURL)
        let itemCount = posterURLs.count
        guard force || lastReportedItemsCount != itemCount else { return }
        lastReportedItemsCount = itemCount
        Task { [posterPrefetchController, visibleColumns] in
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

enum WatchlistViewModelState {
    case empty
    case loaded(movies: [Movie], itemViewModels: [MovieCollectionViewModel])

    var movies: [Movie] {
        switch self {
        case .empty:
            return []
        case let .loaded(movies, _):
            return movies
        }
    }

    var itemViewModels: [MovieCollectionViewModel] {
        switch self {
        case .empty:
            return []
        case let .loaded(_, itemViewModels):
            return itemViewModels
        }
    }
}

private struct LoadedMovieList: MovieCatalogLoadedState {
    let movies: [Movie]
    let watchlistIds: Set<Int>
}
