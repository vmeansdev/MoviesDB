import AppHttpKit
import Foundation

public protocol CachePolicy {
    func ttl(for request: Request) -> TimeInterval?
}
