import AnyCodable
import Foundation

public class JSONParameterEncoder: ParameterEncoder {
    private let encoder: JSONEncoder

    public init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    public func contentType(request: Request?) -> String {
        "application/json"
    }

    public func stringEncode(_ parameters: [String: AnyEncodable]) throws -> String {
        String(data: try encoder.encode(parameters), encoding: .utf8) ?? ""
    }

    public func dataEncode(_ parameters: AnyEncodable) throws -> Data {
        try encoder.encode(parameters)
    }
}
