import MovieDBData

protocol StoreProviderProtocol {
    var watchlistStore: WatchlistStoreProtocol { get }
}

final class StoreProvider: StoreProviderProtocol {
    let watchlistStore: WatchlistStoreProtocol

    init(watchlistStore: WatchlistStoreProtocol = WatchlistStore()) {
        self.watchlistStore = watchlistStore
    }
}
