import CoreGraphics

public protocol MovieCatalogInteractorProtocol: Actor {
    func viewDidLoad() async
    func viewWillUnload() async
    func didSelect(item: Int) async
    func didToggleWatchlist(item: Int) async
    func loadMore() async
    func canLoadMore(item: Int) async -> Bool
    func didUpdateLayout(containerSize: CGSize, columns: Int, itemHeight: CGFloat, minimumColumns: Int) async
    func didUpdateVisibleItem(index: Int, isVisible: Bool, columns: Int) async
    func didUpdateItems(columns: Int) async
}
