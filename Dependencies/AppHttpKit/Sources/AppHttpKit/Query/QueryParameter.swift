import AnyCodable
import Foundation

@propertyWrapper
public struct QueryParameter<T>: Sendable {
    public var wrappedValue: T
    public var key: String

    public init(_ wrappedValue: T, _ key: String) {
        self.wrappedValue = wrappedValue
        self.key = key
    }

    public var projectedValue: (String, T) {
        (key, wrappedValue)
    }
}
