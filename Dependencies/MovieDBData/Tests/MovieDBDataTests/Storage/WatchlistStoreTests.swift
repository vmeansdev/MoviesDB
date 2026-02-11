import Foundation
import Testing
@testable import MovieDBData

struct WatchlistStoreTests {
    @Test
    func test_addAndRemove_updatesItems() async {
        let store = WatchlistStore(userDefaults: makeUserDefaults(), storageKey: "watchlist.test.addremove")
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
        let store = WatchlistStore(userDefaults: makeUserDefaults(), storageKey: "watchlist.test.toggle")
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
        let userDefaults = makeUserDefaults()
        let key = "watchlist.test.persist"
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

        let store = WatchlistStore(userDefaults: userDefaults, storageKey: key)
        await store.add(movie: movie)

        let newStore = WatchlistStore(userDefaults: userDefaults, storageKey: key)
        let items = await newStore.items()
        #expect(items.count == 1)
        #expect(items.first?.id == 99)
    }
}

private func makeUserDefaults() -> UserDefaults {
    let suiteName = "watchlist.tests.\(UUID().uuidString)"
    return UserDefaults(suiteName: suiteName) ?? .standard
}
