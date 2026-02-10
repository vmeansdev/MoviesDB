import Foundation
@testable import AppHttpKit

public final class MockURLProtocol: URLProtocol {
    public enum MockURLProtocolError: Error {
        case notFound
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        if let url = request.url,
           let fileName = url.lastPathComponent.components(separatedBy: ".").first,
           let filePath = Bundle.module.path(forResource: "\(fileName)", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        {
            let response = URLResponse(url: url, mimeType: "application/json", expectedContentLength: data.count, textEncodingName: nil)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } else {
            client?.urlProtocol(self, didFailWithError: MockURLProtocolError.notFound)
        }
    }

    public override func stopLoading() {
        // No cleanup necessary
    }
}

