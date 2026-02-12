import AppHttpKit
import Foundation

public final class MovieDBCachePolicy: CachePolicy {
    private enum TTL {
        static let list: TimeInterval = 60 * 60
        static let details: TimeInterval = 24 * 60 * 60
    }

    public init() { }

    public func ttl(for request: Request) -> TimeInterval? {
        guard request.method == .get else { return nil }
        if request.url.hasPrefix("movie/popular") { return TTL.list }
        if request.url.hasPrefix("movie/top_rated") { return TTL.list }
        if request.url.hasPrefix("movie/") { return TTL.details }
        return nil
    }
}
