import AnyCodable
import Foundation

public class DataParameterEncoder: ParameterEncoder {
    public init() { }

    public func contentType(request: Request?) -> String {
        "application/octet-stream"
    }

    public func stringEncode(_ parameters: [String: AnyEncodable]) throws -> String {
        throw ParameterEncoderError.invalidParamsFormat
    }

    public func dataEncode(_ parameters: AnyEncodable) throws -> Data {
        guard let data = parameters.value as? Data else {
            throw ParameterEncoderError.invalidParamsFormat
        }
        return data
    }
}