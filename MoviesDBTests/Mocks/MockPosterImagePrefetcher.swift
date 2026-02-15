import Foundation
@testable import MoviesDB

@MainActor
final class MockPosterImagePrefetcher: PosterImagePrefetching {
    private(set) var updateCalls: [[URL]] = []
    private(set) var stopCallsCount = 0

    func updatePrefetch(urls: [URL]) {
        updateCalls.append(urls)
    }

    func stop() {
        stopCallsCount += 1
    }
}
