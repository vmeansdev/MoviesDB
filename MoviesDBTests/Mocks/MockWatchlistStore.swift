import Foundation
import MovieDBData
@testable import MoviesDB

actor MockWatchlistStore: WatchlistStoreProtocol {
    private var itemsList: [Movie] = []
    private var continuations: [UUID: AsyncStream<[Movie]>.Continuation] = [:]

    func items() async -> [Movie] {
        itemsList
    }

    func itemsStream() async -> AsyncStream<[Movie]> {
        AsyncStream { continuation in
            let id = UUID()
            continuation.yield(itemsList)
            continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id: id) }
            }
        }
    }

    func isInWatchlist(id: Int) async -> Bool {
        itemsList.contains { $0.id == id }
    }

    func add(movie: Movie) async {
        guard !itemsList.contains(where: { $0.id == movie.id }) else { return }
        itemsList.append(movie)
        notify()
    }

    func remove(id: Int) async {
        itemsList.removeAll { $0.id == id }
        notify()
    }

    func toggle(movie: Movie) async {
        if itemsList.contains(where: { $0.id == movie.id }) {
            itemsList.removeAll { $0.id == movie.id }
        } else {
            itemsList.append(movie)
        }
        notify()
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }

    private func notify() {
        continuations.values.forEach { $0.yield(itemsList) }
    }
}
