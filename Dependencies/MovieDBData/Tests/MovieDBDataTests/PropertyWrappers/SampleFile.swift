import Foundation
@testable import MovieDBData

@propertyWrapper
struct SampleFile {
    let fileName: String

    var wrappedValue: URL {
        let parts = fileName.split(separator: ".")
        guard parts.count == 2 else {
            fatalError("Invalid sample file name: \(fileName)")
        }
        let file = String(parts[0])
        let fileExtension = String(parts[1])
        guard let url = Bundle.module.url(forResource: file, withExtension: fileExtension) else {
            fatalError("Missing sample file in bundle: \(fileName)")
        }
        return url
    }

    var projectedValue: String {
        fileName
    }
}
