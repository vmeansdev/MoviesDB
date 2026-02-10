import AnyCodable

public protocol QueryParametersConvertible {
    var params: [String: AnyEncodable] { get }
}

public extension QueryParametersConvertible {
    var params: [String: AnyEncodable] {
        extractParameters(self)
    }

    private func extractParameters<T>(_ instance: T) -> [String: AnyEncodable] {
        var result: [String: AnyEncodable] = [:]
        let mirror = Mirror(reflecting: instance)
        for child in mirror.children {
            guard let (key, wrappedValue) = extractQueryParameter(from: child.value) else { continue }
            result[key] = AnyEncodable(wrappedValue)
        }
        return result
    }

    private func extractQueryParameter(from value: Any) -> (key: String, wrappedValue: Any)? {
        let valueMirror = Mirror(reflecting: value)
        guard valueMirror.children.count == 2 else { return nil }
        var key: String?
        var wrappedValue: Any?

        for property in valueMirror.children {
            if property.label == Keys.key.rawValue {
                key = String(describing: property.value)
            }
            if property.label == Keys.wrappedValue.rawValue {
                wrappedValue = property.value
            }
        }
        if let key, let wrappedValue {
            return (key: key, wrappedValue: wrappedValue)
        }
        return nil
    }
}

extension Dictionary: QueryParametersConvertible where Key == String, Value == AnyEncodable {
    public var params: [String: AnyEncodable] { self }
}

private enum Keys: String {
    case key
    case wrappedValue
}
