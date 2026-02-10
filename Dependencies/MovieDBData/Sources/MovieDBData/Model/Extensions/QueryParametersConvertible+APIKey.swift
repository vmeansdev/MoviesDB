import AnyCodable
import AppHttpKit

extension QueryParametersConvertible {
    func buildParams(with keyParams: KeyParameters) -> [String: AnyEncodable] {
        var params = self.params
        for (key, value) in keyParams.params {
            params[key] = value
        }
        return params
    }
}
