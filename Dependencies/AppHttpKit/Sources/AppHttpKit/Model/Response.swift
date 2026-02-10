import Foundation

public struct Response {
    public let request: Request
    public let headers: [String: String]
    public let code: Int
    public let body: Data

    public var isSuccessful: Bool {
        return code >= 200 && code < 400
    }
}

public extension Response {
    init(request: Request, response: URLResponse, body: Data?) {
        let httpResponse = response as? HTTPURLResponse
        self.init(
            request: request,
            headers: httpResponse?.allHeaderFields as? [String: String] ?? [:],
            code: httpResponse?.statusCode ?? 0,
            body: body ?? Data()
        )
    }
}
