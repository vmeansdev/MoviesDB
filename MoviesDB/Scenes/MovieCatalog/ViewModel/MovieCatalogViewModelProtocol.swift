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

enum MovieCatalogViewModelState {
    case idle(items: [MovieCollectionViewModel])
    case initialLoading(items: [MovieCollectionViewModel])
    case loadingMore(items: [MovieCollectionViewModel])
    case error(items: [MovieCollectionViewModel], details: MovieCatalogErrorState)

    var items: [MovieCollectionViewModel] {
        switch self {
        case let .idle(items), let .initialLoading(items), let .loadingMore(items), let .error(items, _):
            return items
        }
    }

    func replacingItems(_ items: [MovieCollectionViewModel]) -> MovieCatalogViewModelState {
        switch self {
        case .idle:
            return .idle(items: items)
        case .initialLoading:
            return .initialLoading(items: items)
        case .loadingMore:
            return .loadingMore(items: items)
        case let .error(_, details):
            return .error(items: items, details: details)
        }
    }
}

extension Movie: @retroactive Identifiable {}
