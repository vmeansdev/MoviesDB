import AnyCodable
import Foundation

public class URLParameterEncoder: ParameterEncoder {
    public init() { }

    public func contentType(request: Request?) -> String {
        "application/x-www-form-urlencoded"
    }

    public func stringEncode(_ parameters: [String: AnyEncodable]) throws -> String {
        guard var urlComponents = URLComponents(string: "") else {
            throw ParameterEncoderError.invalidURL
        }

        urlComponents.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }

        guard let queryString = urlComponents.percentEncodedQuery else {
            throw ParameterEncoderError.invalidParamsFormat
        }

        return queryString
    }

    public func dataEncode(_ parameters: AnyEncodable) throws -> Data {
        let queryString = try stringEncode(parameters.value as? [String: AnyEncodable] ?? [:])
        return queryString.data(using: .utf8) ?? Data()
    }
}
