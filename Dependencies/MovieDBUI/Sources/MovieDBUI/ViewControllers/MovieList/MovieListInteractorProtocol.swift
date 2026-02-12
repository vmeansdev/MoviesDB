public protocol MovieListInteractorProtocol: Actor {
    func viewDidLoad() async
    func viewWillUnload() async
    func didSelect(item: Int) async
    func didToggleWatchlist(item: Int) async
    func loadMore() async
    func canLoadMore(item: Int) async -> Bool
}
