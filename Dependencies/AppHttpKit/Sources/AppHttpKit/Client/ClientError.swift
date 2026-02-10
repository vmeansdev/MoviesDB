import Foundation

public enum ClientError: Error {
    case incorrectURL
    case timeout
    case network(response: Response, error: Error?)
    case encoderNotFound
}
