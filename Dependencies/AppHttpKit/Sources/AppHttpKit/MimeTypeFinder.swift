import Foundation
import UniformTypeIdentifiers

public class MimeTypeFinder {
    public init() {}

    public func mimeType(forPathExtension pathExtension: String) -> String {
        if let type = UTType(filenameExtension: pathExtension, conformingTo: .data), let mimeType = type.preferredMIMEType  {
            return mimeType
        }
        return "application/octet-stream"
    }
}
