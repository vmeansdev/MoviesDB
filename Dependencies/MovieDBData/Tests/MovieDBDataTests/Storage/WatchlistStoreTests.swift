import Foundation
import Testing
@testable import MovieDBData

struct WatchlistStoreTests {
    @Test
    func test_addAndRemove_updatesItems() async {
        let store = WatchlistStore(storageKey: "watchlist.test.addremove.\(UUID().uuidString)")
        let movie = Movie(
            adult: false,
            backdropPath: nil,
            genreIDS: [1],
            id: 42,
            originalLanguage: "en",
            originalTitle: "Test",
            overview: "",
            popularity: 1,
            posterPath: "/poster.jpg",
            releaseDate: "2025-01-01",
            title: "Test",
            video: false,
            voteAverage: 5,
            voteCount: 1
        )

        await store.add(movie: movie)
        let afterAdd = await store.items()
        #expect(afterAdd.count == 1)
        #expect(afterAdd.first?.id == 42)

        await store.remove(id: 42)
        let afterRemove = await store.items()
        #expect(afterRemove.isEmpty)
    }

    @Test
    func test_toggle_addsAndRemoves() async {
        let store = WatchlistStore(storageKey: "watchlist.test.toggle.\(UUID().uuidString)")
        let movie = Movie(
            adult: false,
            backdropPath: nil,
            genreIDS: [2],
            id: 7,
            originalLanguage: "en",
            originalTitle: "Toggle",
            overview: "",
            popularity: 2,
            posterPath: "/poster2.jpg",
            releaseDate: "2025-02-01",
            title: "Toggle",
            video: false,
            voteAverage: 6,
            voteCount: 2
        )

        await store.toggle(movie: movie)
        #expect(await store.isInWatchlist(id: 7) == true)

        await store.toggle(movie: movie)
        #expect(await store.isInWatchlist(id: 7) == false)
    }

    @Test
    func test_persistsToUserDefaults() async {
        let key = "watchlist.test.persist.\(UUID().uuidString)"
        defer { UserDefaults.standard.removeObject(forKey: key) }
        let movie = Movie(
            adult: false,
            backdropPath: nil,
            genreIDS: [3],
            id: 99,
            originalLanguage: "en",
            originalTitle: "Persist",
            overview: "",
            popularity: 3,
            posterPath: "/poster3.jpg",
            releaseDate: "2025-03-01",
            title: "Persist",
            video: false,
            voteAverage: 7,
            voteCount: 3
        )

        let store = WatchlistStore(storageKey: key)
        await store.add(movie: movie)

        let newStore = WatchlistStore(storageKey: key)
        let items = await newStore.items()
        #expect(items.count == 1)
        #expect(items.first?.id == 99)
    }

    @Test
    func test_itemsStream_yieldsInitialAndUpdates() async {
        let store = WatchlistStore(storageKey: "watchlist.test.stream.\(UUID().uuidString)")
        let movie = Movie(
            adult: false,
            backdropPath: nil,
            genreIDS: [4],
            id: 123,
            originalLanguage: "en",
            originalTitle: "Stream",
            overview: "",
            popularity: 4,
            posterPath: "/poster4.jpg",
            releaseDate: "2025-04-01",
            title: "Stream",
            video: false,
            voteAverage: 8,
            voteCount: 4
        )

        let stream = await store.itemsStream()
        var iterator = stream.makeAsyncIterator()

        let initial = await iterator.next()
        #expect(initial?.isEmpty == true)

        await store.add(movie: movie)
        let afterAdd = await iterator.next()
        #expect(afterAdd?.count == 1)
        #expect(afterAdd?.first?.id == 123)

        await store.remove(id: 123)
        let afterRemove = await iterator.next()
        #expect(afterRemove?.isEmpty == true)
    }
}
