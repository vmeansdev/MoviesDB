import Foundation
import Testing
@testable import MovieDBData

struct ResponseCacheTests {
    @Test
    func test_entry_whenStored_shouldReturnEntry() async {
        let cache = ResponseCache(directoryName: UUID().uuidString)
        let key = "movie/popular?page=1"
        let entry = ResponseCache.Entry(
            expiry: Date().addingTimeInterval(60),
            code: 200,
            headers: ["Etag": "abc"],
            body: Data("payload".utf8)
        )

        await cache.set(entry, for: key)
        let loaded = await cache.entry(for: key)

        #expect(loaded != nil)
        #expect(loaded?.code == 200)
        #expect(loaded?.headers["Etag"] == "abc")
        #expect(loaded?.body == Data("payload".utf8))
    }

    @Test
    func test_entry_whenExpired_shouldReturnNil() async {
        let cache = ResponseCache(directoryName: UUID().uuidString)
        let key = "movie/top_rated?page=1"
        let entry = ResponseCache.Entry(
            expiry: Date().addingTimeInterval(-10),
            code: 200,
            headers: [:],
            body: Data("payload".utf8)
        )

        await cache.set(entry, for: key)
        let loaded = await cache.entry(for: key)

        #expect(loaded == nil)
    }

    @Test
    func test_entry_whenStoredOnDisk_shouldLoadWithNewInstance() async {
        let directoryName = UUID().uuidString
        let key = "movie/details?id=1"
        let entry = ResponseCache.Entry(
            expiry: Date().addingTimeInterval(60),
            code: 200,
            headers: ["Cache": "disk"],
            body: Data("disk".utf8)
        )

        let firstCache = ResponseCache(directoryName: directoryName)
        await firstCache.set(entry, for: key)

        let secondCache = ResponseCache(directoryName: directoryName)
        let loaded = await secondCache.entry(for: key)

        #expect(loaded != nil)
        #expect(loaded?.headers["Cache"] == "disk")
        #expect(loaded?.body == Data("disk".utf8))
    }
}
