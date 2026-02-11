@testable import MoviesDB

actor MockPopularInteractor: PopularInteractorProtocol {
    private(set) var viewDidLoadCalls = 0
    private(set) var viewWillUnloadCalls = 0
    private(set) var didSelectCalls: [Int] = []
    private(set) var didToggleWatchlistCalls: [Int] = []
    private(set) var loadMoreCalls = 0
    var canLoadMoreResult = false

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
        return canLoadMoreResult
    }
}
