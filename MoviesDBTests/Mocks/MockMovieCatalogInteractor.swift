@testable import MoviesDB
import CoreGraphics
import MovieDBUI

actor MockMovieCatalogInteractor: MovieCatalogInteractorProtocol {
    private(set) var viewDidLoadCalls = 0
    private(set) var viewWillUnloadCalls = 0
    private(set) var didSelectCalls: [Int] = []
    private(set) var didToggleWatchlistCalls: [Int] = []
    private(set) var loadMoreCalls = 0
    var canLoadMoreResult = false
    private(set) var didUpdateLayoutCalls = 0
    private(set) var didUpdateVisibleItemCalls: [(index: Int, isVisible: Bool, columns: Int)] = []
    private(set) var didUpdateItemsCalls: [Int] = []

    func viewDidLoad() async {
        viewDidLoadCalls += 1
    }

    func viewWillUnload() async {
        viewWillUnloadCalls += 1
    }

    func didSelect(item: Int) async {
        didSelectCalls.append(item)
    }

    func didToggleWatchlist(item: Int) async {
        didToggleWatchlistCalls.append(item)
    }

    func loadMore() async {
        loadMoreCalls += 1
    }

    func canLoadMore(item: Int) async -> Bool {
        canLoadMoreResult
    }

    func didUpdateLayout(containerSize: CGSize, columns: Int, itemHeight: CGFloat, minimumColumns: Int) async {
        didUpdateLayoutCalls += 1
    }

    func didUpdateVisibleItem(index: Int, isVisible: Bool, columns: Int) async {
        didUpdateVisibleItemCalls.append((index, isVisible, columns))
    }

    func didUpdateItems(columns: Int) async {
        didUpdateItemsCalls.append(columns)
    }
}
