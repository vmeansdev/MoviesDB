import Foundation
import MovieDBData
import MovieDBUI
import Observation

@MainActor
protocol MovieCatalogViewModelProtocol: AnyObject, Observable {
    var title: String { get }
    var items: [MovieCollectionViewModel] { get }
    var error: MovieCatalogErrorState? { get }
    var isInitialLoading: Bool { get }
    var isLoadingMore: Bool { get }

    func onAppear()
    func onDisappear()
    func movie(at index: Int) -> Movie?
    func toggleWatchlist(at index: Int)
    func loadMoreIfNeeded(currentIndex: Int)
    func dismissError()
    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int)
    func itemsCountChanged(columns: Int)
}

struct MovieCatalogErrorState: Identifiable {
    let id = UUID()
    let message: String
    let retry: (() -> Void)?
}

extension Movie: @retroactive Identifiable {}
