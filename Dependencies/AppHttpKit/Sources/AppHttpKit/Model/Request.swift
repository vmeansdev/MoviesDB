import AnyCodable
import Foundation

public struct Request {
    public let method: Method
    public let url: String
    public let queryParams: [String: AnyEncodable]?
    public let headers: [String: String]?
    public let bodyParams: AnyEncodable?

    public var contentType: String? {
        headers?["Content-Type"]
    }

    public init(
        method: Method = .get,
        url: String,
        queryParams: [String: AnyEncodable]? = nil,
        bodyParams: AnyEncodable? = nil,
        headers: [String: String]? = nil
    ) {
        self.method = method
        self.url = url
        self.queryParams = queryParams
        self.bodyParams = bodyParams
        self.headers = headers
    }
}
