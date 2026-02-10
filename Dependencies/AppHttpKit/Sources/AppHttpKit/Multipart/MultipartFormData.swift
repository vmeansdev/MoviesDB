import Foundation

class MultipartFormData {
    public lazy var contentType: String = "multipart/form-data; boundary=\(self.boundary)"
    public var contentLength: UInt64 { bodyParts.reduce(0) { $0 + $1.contentLength } }
    public let boundary: String
    public private(set) var bodyParts: [MultipartBodyPart]
    private var generatedBoundary: String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    public init(boundary: String? = nil, boundaryGenerator: BoundaryGenerator = BoundaryGenerator()) {
        self.boundary = boundary ?? boundaryGenerator.generatedBoundary
        self.bodyParts = []
    }

    public func append(_ data: Data, name: String, fileName: String? = nil, mimeType: String? = nil) {
        bodyParts.append(
            MultipartBodyPart(
                data: data,
                contentLength: UInt64(data.count),
                headers: contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
            )
        )
    }

    public func encloseBodyParts() {
        guard !bodyParts.isEmpty else { return }
        bodyParts[0].hasInitialBoundary = true
        bodyParts[bodyParts.count - 1].hasFinalBoundary = true
    }

    private func contentHeaders(withName name: String, fileName: String? = nil, mimeType: String? = nil) -> [String: String] {
        var disposition = "form-data; name=\"\(name)\""
        if let fileName = fileName {
            disposition += "; filename=\"\(fileName)\""
        }

        var headers: [String: String] = ["Content-Disposition": disposition]
        if let mimeType = mimeType {
            headers["Content-Type"] = mimeType
        }
        return headers
    }
}
