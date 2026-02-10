import Foundation

public struct MultipartBodyPart {
    public let data: Data
    public let contentLength: UInt64
    public let headers: [String: String]
    public var hasInitialBoundary = false
    public var hasFinalBoundary = false
}
