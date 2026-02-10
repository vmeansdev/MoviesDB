import AnyCodable
import Foundation

public class MultipartParameterEncoder: ParameterEncoder {
    private typealias EncodingCharacters = BoundaryGenerator.EncodingCharacters

    private let boundaryGenerator: BoundaryGenerator
    private let jsonParameterEncoder: ParameterEncoder

    public init(jsonParameterEncoder: ParameterEncoder, boundaryGenerator: BoundaryGenerator = BoundaryGenerator()) {
        self.jsonParameterEncoder = jsonParameterEncoder
        self.boundaryGenerator = boundaryGenerator
    }

    public func contentType(request: Request?) -> String {
        (request?.bodyParams?.value as? MultipartFormData)?.contentType ?? "multipart/form-data"
    }

    public func stringEncode(_ parameters: [String: AnyEncodable]) throws -> String {
        try jsonParameterEncoder.stringEncode(parameters)
    }

    public func dataEncode(_ parameters: AnyEncodable) throws -> Data {
        guard let body = parameters.value as? MultipartFormData else {
            throw ParameterEncoderError.notEncodable
        }
        body.encloseBodyParts()
        var encoded = Data()
        for bodyPart in body.bodyParts {
            let encodedData = try encode(bodyPart, boundary: body.boundary)
            encoded.append(encodedData)
        }
        return encoded
    }

    private func encode(_ bodyPart: MultipartBodyPart, boundary: String) throws -> Data {
        var encoded = Data()
        encoded.append(bodyPart.hasInitialBoundary ? initialBoundaryData(boundary) : innerBoundaryData(boundary))
        encoded.append(encodeHeaders(for: bodyPart, boundary: boundary))
        encoded.append(bodyPart.data)
        if bodyPart.hasFinalBoundary {
            encoded.append(finalBoundaryData(boundary))
        }
        return encoded
    }

    private func encodeHeaders(for bodyPart: MultipartBodyPart, boundary: String) -> Data {
        let headerText = bodyPart.headers.map { "\($0.key): \($0.value)\(EncodingCharacters.crlf)" }.joined() + EncodingCharacters.crlf
        return Data(headerText.utf8)
    }

    private func initialBoundaryData(_ boundary: String) -> Data {
        boundaryGenerator.boundaryData(forBoundaryType: .initial, boundary: boundary)
    }

    private func innerBoundaryData(_ boundary: String) -> Data {
        boundaryGenerator.boundaryData(forBoundaryType: .inner, boundary: boundary)
    }

    private func finalBoundaryData(_ boundary: String) -> Data {
        boundaryGenerator.boundaryData(forBoundaryType: .final, boundary: boundary)
    }
}
