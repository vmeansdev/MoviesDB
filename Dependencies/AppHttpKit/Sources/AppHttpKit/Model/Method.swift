import Foundation

public enum Method: String {
    case get
    case post
    case put
    case patch
    case delete
    case head
    case options

    var uppercased: String {
        self.rawValue.uppercased()
    }
}
