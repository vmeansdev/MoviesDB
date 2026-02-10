import Foundation

public final class BoundaryGenerator {
    enum EncodingCharacters {
        static let crlf = "\r\n"
    }

    enum BoundaryType {
        case initial, inner, final
    }

    var generatedBoundary: String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    public init() {}

    func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
        let boundaryText: String

        switch boundaryType {
        case .initial:
            boundaryText = "--\(boundary)\(EncodingCharacters.crlf)"
        case .inner:
            boundaryText = "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
        case .final:
            boundaryText = "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
        }

        return Data(boundaryText.utf8)
    }
}
