import Foundation
@testable import MoviesDB

actor MockPosterImagePrefetcher: PosterImagePrefetching {
    private var updateCalls: [[URL]] = []
    private var stopCallsCount = 0

    func updatePrefetch(urls: [URL]) {
        updateCalls.append(urls)
    }

    func stop() {
        stopCallsCount += 1
    }

    func updateCallsSnapshot() -> [[URL]] {
        updateCalls
    }

    func stopCallsCountValue() -> Int {
        stopCallsCount
    }
}
