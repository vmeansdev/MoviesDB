import AnyCodable
import Foundation

public enum ParameterEncoderError: Error {
    case invalidURL
    case invalidParamsFormat
    case notEncodable
}

public protocol ParameterEncoder {
    func contentType(request: Request?) -> String
    func stringEncode(_ parameters: [String: AnyEncodable]) throws -> String
    func dataEncode(_ parameters: AnyEncodable) throws -> Data
}

public extension ParameterEncoder {
    func contentType(request: Request? = nil) -> String {
        contentType(request: request)
    }
}
