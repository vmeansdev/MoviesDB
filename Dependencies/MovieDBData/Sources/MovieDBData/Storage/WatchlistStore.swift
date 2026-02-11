import Foundation

public protocol WatchlistStoreProtocol: Sendable {
    func items() async -> [Movie]
    func itemsStream() async -> AsyncStream<[Movie]>
    func isInWatchlist(id: Int) async -> Bool
    func add(movie: Movie) async
    func remove(id: Int) async
    func toggle(movie: Movie) async
}

public actor WatchlistStore: WatchlistStoreProtocol {
    private var itemsList: [Movie]
    private let userDefaults: UserDefaults
    private let storageKey: String
    private var continuations: [UUID: AsyncStream<[Movie]>.Continuation] = [:]

    public init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "watchlist.movies"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.itemsList = Self.loadItems(from: userDefaults, storageKey: storageKey)
    }

    public func items() async -> [Movie] {
        itemsList
    }

    public func itemsStream() async -> AsyncStream<[Movie]> {
        AsyncStream { continuation in
            let id = UUID()
            continuation.yield(itemsList)
            continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id: id) }
            }
        }
    }

    public func isInWatchlist(id: Int) async -> Bool {
        itemsList.contains { $0.id == id }
    }

    public func add(movie: Movie) async {
        guard !itemsList.contains(where: { $0.id == movie.id }) else { return }
        itemsList.append(movie)
        persistAndNotify()
    }

    public func remove(id: Int) async {
        let updated = itemsList.filter { $0.id != id }
        guard updated.count != itemsList.count else { return }
        itemsList = updated
        persistAndNotify()
    }

    public func toggle(movie: Movie) async {
        if itemsList.contains(where: { $0.id == movie.id }) {
            await remove(id: movie.id)
        } else {
            await add(movie: movie)
        }
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }

    private func persistAndNotify() {
        persist()
        notify()
    }

    private func notify() {
        continuations.values.forEach { $0.yield(itemsList) }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(itemsList)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            userDefaults.removeObject(forKey: storageKey)
        }
    }

    private static func loadItems(from userDefaults: UserDefaults, storageKey: String) -> [Movie] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([Movie].self, from: data)) ?? []
    }
}
