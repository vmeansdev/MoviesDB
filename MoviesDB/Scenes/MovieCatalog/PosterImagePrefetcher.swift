import Foundation
import Kingfisher
import UIKit

protocol PosterImagePrefetching: Actor {
    func updatePrefetch(urls: [URL])
    func stop()
}

actor PosterImagePrefetcher: PosterImagePrefetching {
    static let shared = PosterImagePrefetcher()

    private var prefetcher: ImagePrefetcher?
    private var cachedURLs: Set<URL> = []

    private init() {
        Task { await configureKingfisherIfNeeded() }
    }

    func updatePrefetch(urls: [URL]) {
        let normalizedURLs = normalized(urls: urls)
        let urlSet = Set(normalizedURLs)
        guard urlSet != cachedURLs else { return }

        stop()
        cachedURLs = urlSet
        guard !normalizedURLs.isEmpty else { return }

        let prefetcher = ImagePrefetcher(urls: normalizedURLs)
        self.prefetcher = prefetcher
        prefetcher.start()
    }

    func stop() {
        prefetcher?.stop()
        prefetcher = nil
        cachedURLs.removeAll(keepingCapacity: true)
    }

    private func normalized(urls: [URL]) -> [URL] {
        var seen = Set<URL>()
        var result: [URL] = []
        result.reserveCapacity(min(urls.count, Constants.maxPrefetchURLs))

        for url in urls where !url.isFileURL {
            guard seen.insert(url).inserted else { continue }
            result.append(url)
            if result.count >= Constants.maxPrefetchURLs {
                break
            }
        }

        return result
    }

    private var didConfigureKingfisher = false

    private func configureKingfisherIfNeeded() {
        guard !didConfigureKingfisher else { return }
        didConfigureKingfisher = true

        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = Constants.memoryCacheTotalCostLimit
        cache.memoryStorage.config.countLimit = Constants.memoryCacheCountLimit
        cache.memoryStorage.config.cleanInterval = Constants.memoryCacheCleanInterval
        cache.diskStorage.config.sizeLimit = Constants.diskCacheSizeLimit

        ImageDownloader.default.downloadTimeout = Constants.downloadTimeout
    }
}

nonisolated private enum Constants {
    static let maxPrefetchURLs = 120
    static let memoryCacheTotalCostLimit = 320 * 1_024 * 1_024
    static let memoryCacheCountLimit = 600
    static let memoryCacheCleanInterval: TimeInterval = 30
    static let diskCacheSizeLimit = UInt(1_000 * 1_024 * 1_024)
    static let downloadTimeout: TimeInterval = 20
}
