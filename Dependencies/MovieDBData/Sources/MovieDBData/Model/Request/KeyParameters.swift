import AppHttpKit

struct KeyParameters: QueryParametersConvertible {
    @QueryParameter("", "api_key") var apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }
}
