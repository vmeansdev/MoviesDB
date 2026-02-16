import Foundation
import MovieDBData
import MovieDBUI
import Observation

@MainActor
protocol MovieCatalogViewModelProtocol: AnyObject, Observable {
    var title: String { get }
    var state: MovieCatalogViewModelState { get }

    func onAppear()
    func onDisappear()
    func movie(at index: Int) -> Movie?
    func toggleWatchlist(at index: Int)
    func loadMoreIfNeeded(currentIndex: Int)
    func dismissError()
    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int)
    func updateVisibleColumns(_ columns: Int)
}

struct MovieCatalogErrorState: Identifiable {
    let id = UUID()
    let message: String
    let retry: (() -> Void)?
}

enum MovieCatalogViewPhase {
    case idle
    case initialLoading
    case loadingMore
    case error(MovieCatalogErrorState)
}

struct MovieCatalogViewModelState {
    var phase: MovieCatalogViewPhase
    var movies: [Movie]
    var items: [MovieCollectionViewModel]
    var watchlistIds: Set<Int>
    var currentPage: Int
    var totalPages: Int
    var visibleColumns: Int

    init(
        phase: MovieCatalogViewPhase = .idle,
        movies: [Movie] = [],
        items: [MovieCollectionViewModel] = [],
        watchlistIds: Set<Int> = [],
        currentPage: Int = 0,
        totalPages: Int = 1,
        visibleColumns: Int = 1
    ) {
        self.phase = phase
        self.movies = movies
        self.items = items
        self.watchlistIds = watchlistIds
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.visibleColumns = visibleColumns
    }

    var hasMoreItems: Bool {
        currentPage < totalPages
    }

    var errorDetails: MovieCatalogErrorState? {
        guard case let .error(details) = phase else { return nil }
        return details
    }
}

extension Movie: @retroactive Identifiable {}
